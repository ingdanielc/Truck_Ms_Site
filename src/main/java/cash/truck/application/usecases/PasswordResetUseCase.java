package cash.truck.application.usecases;

import cash.truck.application.usecases.notifications.WhatsappMessageUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.dtos.PasswordResetResponse;
import cash.truck.domain.entities.Driver;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.entities.PasswordReset;
import cash.truck.domain.entities.Users;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.enums.MediumEnum;
import cash.truck.domain.enums.PasswordResetStatusEnum;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.PasswordResetRepository;
import cash.truck.domain.repositories.UsersRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.UUID;

/**
 * Recuperacion de contrasena en tres pasos:
 *
 * 1. /forgotPassword  celular -> se genera un codigo temporal y se envia por WhatsApp.
 * 2. /verify          celular + codigo -> se valida y se emite un token de cambio.
 * 3. /reset           token + contrasena nueva -> se guarda y la solicitud queda invalidada.
 *
 * El usuario se ubica por el celular del propietario o del conductor asociado,
 * porque la tabla users no almacena celular.
 */
@Service
@Transactional
public class PasswordResetUseCase {

    private static final Logger logger = LoggerFactory.getLogger(PasswordResetUseCase.class);
    private static final SecureRandom RANDOM = new SecureRandom();

    private final UsersRepository usersRepository;
    private final PasswordResetRepository passwordResetRepository;
    private final OwnerRepository ownerRepository;
    private final DriverRepository driverRepository;
    private final WhatsappMessageUseCase whatsappMessageUseCase;

    public PasswordResetUseCase(UsersRepository usersRepository,
                                PasswordResetRepository passwordResetRepository,
                                OwnerRepository ownerRepository,
                                DriverRepository driverRepository,
                                WhatsappMessageUseCase whatsappMessageUseCase) {
        this.usersRepository = usersRepository;
        this.passwordResetRepository = passwordResetRepository;
        this.ownerRepository = ownerRepository;
        this.driverRepository = driverRepository;
        this.whatsappMessageUseCase = whatsappMessageUseCase;
    }

    /**
     * Paso 1: genera el codigo, lo envia por WhatsApp y responde con el celular
     * enmascarado para que el front indique a donde llego el mensaje.
     */
    public PasswordResetResponse forgotPassword(String cellPhone) {
        if (cellPhone == null || cellPhone.isBlank()) {
            throw new IllegalArgumentException(Constants.PASSWORD_RESET_PHONE_REQUIRED);
        }

        String phone = normalizePhone(cellPhone);
        Users user = findUserByPhone(cellPhone)
                .orElseThrow(() -> new EntityNotFoundException(Constants.PASSWORD_RESET_PHONE_NOT_FOUND));

        cancelPreviousRequests(user.getId());

        String code = generateCode();
        PasswordReset passwordReset = new PasswordReset();
        passwordReset.setUserId(user.getId());
        passwordReset.setPhone(phone);
        passwordReset.setCode(SecurityUseCase.getHashSHA512(code));
        passwordReset.setStatus(PasswordResetStatusEnum.PENDING.getName());
        passwordReset.setAttempts(0);
        passwordReset.setExpirationDate(minutesFromNow(Constants.PASSWORD_RESET_CODE_MINUTES));
        passwordResetRepository.save(passwordReset);

        sendWhatsApp(user, phone, code);
        return new PasswordResetResponse(maskPhone(phone), Constants.PASSWORD_RESET_CODE_MINUTES, null);
    }

    /**
     * Paso 2: valida el codigo y su vigencia. Al acertar entrega el token con el
     * que se autoriza el cambio; el codigo por si solo ya no sirve.
     */
    public PasswordResetResponse verify(String cellPhone, String code) {
        if (cellPhone == null || cellPhone.isBlank() || code == null || code.isBlank()) {
            throw new IllegalArgumentException(Constants.PASSWORD_RESET_CODE_REQUIRED);
        }

        String phone = normalizePhone(cellPhone);
        PasswordReset passwordReset = passwordResetRepository
                .findFirstByPhoneAndStatusOrderByIdDesc(phone, PasswordResetStatusEnum.PENDING.getName())
                .orElseThrow(() -> new IllegalArgumentException(Constants.PASSWORD_RESET_NO_REQUEST));

        if (isExpired(passwordReset)) {
            cancel(passwordReset);
            throw new IllegalArgumentException(Constants.PASSWORD_RESET_CODE_EXPIRED);
        }

        if (!passwordReset.getCode().equals(SecurityUseCase.getHashSHA512(code.trim()))) {
            passwordReset.setAttempts(passwordReset.getAttempts() + 1);
            if (passwordReset.getAttempts() >= Constants.PASSWORD_RESET_MAX_ATTEMPTS) {
                cancel(passwordReset);
                throw new IllegalArgumentException(Constants.PASSWORD_RESET_MAX_ATTEMPTS_REACHED);
            }
            passwordResetRepository.save(passwordReset);
            throw new IllegalArgumentException(Constants.PASSWORD_RESET_CODE_INVALID);
        }

        String resetToken = UUID.randomUUID().toString();
        passwordReset.setStatus(PasswordResetStatusEnum.VERIFIED.getName());
        passwordReset.setResetToken(resetToken);
        passwordReset.setExpirationDate(minutesFromNow(Constants.PASSWORD_RESET_TOKEN_MINUTES));
        passwordResetRepository.save(passwordReset);

        logger.info("Password reset code verified for user {}", passwordReset.getUserId());
        return new PasswordResetResponse(null, Constants.PASSWORD_RESET_TOKEN_MINUTES, resetToken);
    }

    /**
     * Paso 3: guarda la contrasena nueva y deja la solicitud usada, de modo que
     * el codigo y el token quedan invalidados para siempre.
     *
     * La contrasena llega ya cifrada desde el front, igual que en el login, que
     * compara el valor recibido contra el almacenado sin transformarlo. Por eso
     * aqui se guarda tal cual: volver a cifrarla dejaria al usuario sin poder
     * entrar.
     */
    public void reset(String resetToken, String password) {
        if (resetToken == null || resetToken.isBlank()) {
            throw new IllegalArgumentException(Constants.PASSWORD_RESET_TOKEN_REQUIRED);
        }
        if (!isHashed(password)) {
            throw new IllegalArgumentException(Constants.PASSWORD_RESET_PASSWORD_INVALID);
        }

        PasswordReset passwordReset = passwordResetRepository
                .findFirstByResetTokenAndStatus(resetToken, PasswordResetStatusEnum.VERIFIED.getName())
                .orElseThrow(() -> new IllegalArgumentException(Constants.PASSWORD_RESET_TOKEN_INVALID));

        if (isExpired(passwordReset)) {
            cancel(passwordReset);
            throw new IllegalArgumentException(Constants.PASSWORD_RESET_TOKEN_EXPIRED);
        }

        Users user = usersRepository.findById(passwordReset.getUserId())
                .orElseThrow(() -> new EntityNotFoundException(Constants.USER_SEARCH_NOT_FOUND_ME));
        user.setPassword(password.trim());
        usersRepository.save(user);

        passwordReset.setStatus(PasswordResetStatusEnum.USED.getName());
        passwordReset.setResetToken(null);
        passwordResetRepository.save(passwordReset);

        logger.info("Password changed for user {}", user.getId());
    }

    /**
     * Rechaza lo que no tenga forma de SHA-512 en hexadecimal. Es la senal de que
     * el front mando la contrasena en claro: guardarla asi la dejaria legible en
     * la base y ademas el login nunca coincidiria.
     */
    private boolean isHashed(String password) {
        return password != null && password.trim().matches(Constants.PASSWORD_HASH_PATTERN);
    }

    /** Un codigo nuevo deja sin efecto los anteriores del mismo usuario. */
    private void cancelPreviousRequests(Integer userId) {
        List<PasswordReset> pending = passwordResetRepository.findByUserIdAndStatusIn(userId,
                List.of(PasswordResetStatusEnum.PENDING.getName(), PasswordResetStatusEnum.VERIFIED.getName()));
        for (PasswordReset previous : pending) {
            cancel(previous);
        }
    }

    private void cancel(PasswordReset passwordReset) {
        passwordReset.setStatus(PasswordResetStatusEnum.CANCELLED.getName());
        passwordReset.setResetToken(null);
        passwordResetRepository.save(passwordReset);
    }

    private boolean isExpired(PasswordReset passwordReset) {
        return passwordReset.getExpirationDate().before(new Date());
    }

    private Date minutesFromNow(int minutes) {
        return new Date(System.currentTimeMillis() + (long) minutes * 60 * 1000);
    }

    /** Codigo numerico de 6 digitos, comodo de leer y de teclear desde el mensaje. */
    private String generateCode() {
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < Constants.PASSWORD_RESET_CODE_LENGTH; i++) {
            code.append(RANDOM.nextInt(10));
        }
        return code.toString();
    }

    private void sendWhatsApp(Users user, String phone, String code) {
        MessageRequest messageRequest = new MessageRequest();
        messageRequest.setMedium(MediumEnum.WHATSAPP.getName());
        messageRequest.setMessageType(Constants.PASSWORD_RESET_MESSAGE_TYPE);
        messageRequest.setPhone(phone);
        messageRequest.setRecipients(List.of(phone));

        List<MessageRequest.KeyValue> data = new ArrayList<>();
        data.add(keyValue("name", user.getName()));
        data.add(keyValue("code", code));
        data.add(keyValue("minutes", String.valueOf(Constants.PASSWORD_RESET_CODE_MINUTES)));
        messageRequest.setData(data);

        whatsappMessageUseCase.sendWhatsApp(messageRequest, new Audit());
        logger.info("Password reset code sent to user {}", user.getId());
    }

    private MessageRequest.KeyValue keyValue(String key, String value) {
        MessageRequest.KeyValue keyValue = new MessageRequest.KeyValue();
        keyValue.setKey(key);
        keyValue.setValue(value == null ? "" : value);
        return keyValue;
    }

    /**
     * El celular vive en owner o en driver, nunca en users. Se busca contra todas
     * las formas en que pudo quedar guardado (con y sin indicativo).
     */
    private Optional<Users> findUserByPhone(String cellPhone) {
        List<String> candidates = phoneCandidates(cellPhone);

        Optional<Owner> owner = ownerRepository.findFirstByCellPhoneInAndUserIsNotNull(candidates);
        if (owner.isPresent()) {
            return Optional.of(owner.get().getUser());
        }

        Optional<Driver> driver = driverRepository.findFirstByCellPhoneInAndUserIsNotNull(candidates);
        return driver.map(Driver::getUser);
    }

    /** Los celulares se guardan sin criterio fijo: se comparan todas las variantes. */
    private List<String> phoneCandidates(String cellPhone) {
        String digits = cellPhone.replaceAll("[^0-9]", "");
        if (digits.startsWith(Constants.COUNTRY_CODE_CO) && digits.length() > Constants.PHONE_LOCAL_LENGTH) {
            digits = digits.substring(Constants.COUNTRY_CODE_CO.length());
        }

        Set<String> candidates = new LinkedHashSet<>();
        candidates.add(digits);
        candidates.add(Constants.COUNTRY_CODE_CO + digits);
        candidates.add("+" + Constants.COUNTRY_CODE_CO + digits);
        candidates.add(cellPhone.trim());
        return new ArrayList<>(candidates);
    }

    /** Twilio exige formato E.164; los celulares se guardan sin indicativo. */
    private String normalizePhone(String phone) {
        String clean = phone.replaceAll("[^0-9+]", "");
        if (clean.startsWith("+")) {
            return clean;
        }
        if (clean.startsWith(Constants.COUNTRY_CODE_CO) && clean.length() > Constants.PHONE_LOCAL_LENGTH) {
            return "+" + clean;
        }
        return "+" + Constants.COUNTRY_CODE_CO + clean;
    }

    private String maskPhone(String phone) {
        if (phone.length() <= 4) {
            return phone;
        }
        return "*".repeat(phone.length() - 4) + phone.substring(phone.length() - 4);
    }
}
