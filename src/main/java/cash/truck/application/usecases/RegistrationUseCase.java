package cash.truck.application.usecases;

import cash.truck.application.exception.RegistrationException;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.PhoneUtils;
import cash.truck.domain.dtos.AvailabilityResponse;
import cash.truck.domain.dtos.RegisterResponse;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.UsersRepository;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.Base64;
import java.util.List;

/**
 * Registro publico de cuenta. Es la puerta abierta del API, asi que aqui vive
 * todo lo que el alta desde el escritorio administrativo no necesita: decidir
 * que campos del cuerpo se descartan y validar la unicidad antes de tocar la
 * base.
 *
 * El alta en si no se reimplementa: se delega en OwnerUseCase.save con
 * callerIsAdmin en false, el mismo camino que ya usa /owner/save. De ahi salen
 * el usuario con rol Propietario, el estado Activo, el conductor espejo cuando
 * isDriver es true y la bienvenida por WhatsApp.
 */
@Service
@Transactional
public class RegistrationUseCase {

    private final OwnerUseCase ownerUseCase;
    private final OwnerRepository ownerRepository;
    private final DriverRepository driverRepository;
    private final UsersRepository usersRepository;

    public RegistrationUseCase(OwnerUseCase ownerUseCase,
            OwnerRepository ownerRepository,
            DriverRepository driverRepository,
            UsersRepository usersRepository) {
        this.ownerUseCase = ownerUseCase;
        this.ownerRepository = ownerRepository;
        this.driverRepository = driverRepository;
        this.usersRepository = usersRepository;
    }

    public RegisterResponse register(Owner owner) {
        if (owner == null) {
            throw RegistrationException.invalid(Constants.FIELD_PAYLOAD, Constants.REGISTER_PAYLOAD_REQUIRED);
        }

        discardServerOwnedFields(owner);
        validateRequired(owner);
        validateFormats(owner);
        validateAvailability(owner);

        Owner saved = ownerUseCase.save(owner, false, Constants.REGISTER_SUBSCRIPTION_MONTHS);
        return toResponse(saved);
    }

    /**
     * Lo que el servidor decide no se negocia con el cliente. El id se anula para
     * que el alta no pueda convertirse en la edicion de otra cuenta, y user para
     * que el propietario nuevo no quede colgando de un usuario existente. La
     * fecha de fin de suscripcion sale de REGISTER_SUBSCRIPTION_MONTHS.
     *
     * isDriver se apaga a proposito: el flujo de propietario que ademas conduce
     * esta pendiente de definir, y mientras tanto el registro no debe crear el
     * conductor espejo. El cupo de vehiculos si llega del formulario.
     */
    private void discardServerOwnedFields(Owner owner) {
        owner.setId(null);
        owner.setUser(null);
        owner.setSubscriptionEndDate(null);
        owner.setIsDriver(Boolean.FALSE);
    }

    private void validateRequired(Owner owner) {
        requireText(owner.getName(), Constants.FIELD_NAME);
        requireText(owner.getEmail(), Constants.FIELD_EMAIL);
        requireText(owner.getCellPhone(), Constants.FIELD_CELL_PHONE);
        requireText(owner.getDocumentNumber(), Constants.FIELD_DOCUMENT_NUMBER);
        requireText(owner.getPassword(), Constants.FIELD_PASSWORD);
        if (owner.getDocumentTypeId() == null) {
            throw RegistrationException.invalid(Constants.FIELD_DOCUMENT_TYPE_ID,
                    String.format(Constants.REGISTER_FIELD_REQUIRED, Constants.FIELD_DOCUMENT_TYPE_ID));
        }
    }

    private void validateFormats(Owner owner) {
        if (!owner.getEmail().trim().matches(Constants.EMAIL_PATTERN)) {
            throw RegistrationException.invalid(Constants.FIELD_EMAIL, Constants.REGISTER_EMAIL_INVALID);
        }
        if (localDigits(owner.getCellPhone()).length() != Constants.PHONE_LOCAL_LENGTH) {
            throw RegistrationException.invalid(Constants.FIELD_CELL_PHONE, Constants.REGISTER_CELL_PHONE_INVALID);
        }
        // El alta espera la contrasena en Base64 y la decodifica sin red: si llega
        // mal, sin esta validacion el error saldria como un 409 enganoso.
        try {
            Base64.getDecoder().decode(owner.getPassword());
        } catch (IllegalArgumentException e) {
            throw RegistrationException.invalid(Constants.FIELD_PASSWORD, Constants.REGISTER_PASSWORD_INVALID);
        }
        // El cupo lo elige el formulario, pero con techo: el endpoint es publico y
        // maxVehicles es lo que limita el plan. Si no viene, el alta usa su defecto.
        if (owner.getMaxVehicles() != null
                && (owner.getMaxVehicles() < 1 || owner.getMaxVehicles() > Constants.REGISTER_MAX_VEHICLES_LIMIT)) {
            throw RegistrationException.invalid(Constants.FIELD_MAX_VEHICLES,
                    String.format(Constants.REGISTER_MAX_VEHICLES_INVALID, Constants.REGISTER_MAX_VEHICLES_LIMIT));
        }
    }

    private void validateAvailability(Owner owner) {
        if (!isAvailable(Constants.FIELD_DOCUMENT_NUMBER, owner.getDocumentNumber())) {
            throw RegistrationException.duplicated(Constants.FIELD_DOCUMENT_NUMBER,
                    Constants.REGISTER_DUPLICATE_DOCUMENT_NUMBER);
        }
        if (!isAvailable(Constants.FIELD_EMAIL, owner.getEmail())) {
            throw RegistrationException.duplicated(Constants.FIELD_EMAIL, Constants.REGISTER_DUPLICATE_EMAIL);
        }
        if (!isAvailable(Constants.FIELD_CELL_PHONE, owner.getCellPhone())) {
            throw RegistrationException.duplicated(Constants.FIELD_CELL_PHONE,
                    Constants.REGISTER_DUPLICATE_CELL_PHONE);
        }
    }

    /**
     * Un mismo dato puede estar en varias tablas: el correo vive en users, owner
     * y driver, y el documento y el celular en owner y driver. Se consultan todas
     * porque cualquiera de ellas hace que la cuenta nueva sea inviable o ambigua.
     */
    public boolean isAvailable(String field, String value) {
        if (value == null || value.isBlank()) {
            throw RegistrationException.invalid(field, Constants.AVAILABILITY_VALUE_REQUIRED);
        }
        String clean = value.trim();

        if (Constants.FIELD_DOCUMENT_NUMBER.equals(field)) {
            return !ownerRepository.existsByDocumentNumber(clean)
                    && !driverRepository.existsByDocumentNumber(clean);
        }
        if (Constants.FIELD_EMAIL.equals(field)) {
            return !usersRepository.existsByEmailIgnoreCase(clean)
                    && !ownerRepository.existsByEmailIgnoreCase(clean)
                    && !driverRepository.existsByEmailIgnoreCase(clean);
        }
        if (Constants.FIELD_CELL_PHONE.equals(field)) {
            // El celular quedo guardado de varias formas segun quien lo cargo, asi
            // que se busca por todas ellas y no por igualdad exacta.
            List<String> candidates = PhoneUtils.candidates(clean);
            return !ownerRepository.existsByCellPhoneIn(candidates)
                    && !driverRepository.existsByCellPhoneIn(candidates);
        }
        throw RegistrationException.invalid(Constants.FIELD_PAYLOAD, Constants.AVAILABILITY_FIELD_INVALID);
    }

    public AvailabilityResponse checkAvailability(String field, String value) {
        return new AvailabilityResponse(field, isAvailable(field, value));
    }

    private RegisterResponse toResponse(Owner owner) {
        return new RegisterResponse(
                owner.getId(),
                owner.getUser() == null ? null : owner.getUser().getId(),
                owner.getName(),
                owner.getEmail(),
                owner.getDocumentNumber(),
                owner.getCellPhone(),
                owner.getIsDriver(),
                owner.getMaxVehicles(),
                owner.getSubscriptionEndDate(),
                owner.getUser() == null ? null : owner.getUser().getStatus());
    }

    /** Celular sin indicativo ni separadores, para contar digitos. */
    private String localDigits(String cellPhone) {
        String digits = cellPhone.replaceAll("[^0-9]", "");
        if (digits.startsWith(Constants.COUNTRY_CODE_CO) && digits.length() > Constants.PHONE_LOCAL_LENGTH) {
            digits = digits.substring(Constants.COUNTRY_CODE_CO.length());
        }
        return digits;
    }

    private void requireText(String value, String field) {
        if (isBlank(value)) {
            throw RegistrationException.invalid(field, String.format(Constants.REGISTER_FIELD_REQUIRED, field));
        }
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
