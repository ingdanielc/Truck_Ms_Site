package cash.truck.application.usecases.notifications;

import cash.truck.application.utility.Constants;
import cash.truck.application.utility.PhoneUtils;
import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.enums.MediumEnum;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

/**
 * Mensajes de WhatsApp dirigidos al propietario: la bienvenida al crearlo y el
 * aviso de suscripcion proxima a vencer.
 *
 * Ambos metodos corren en una transaccion propia (REQUIRES_NEW) para que un
 * fallo guardando la trazabilidad del mensaje no arrastre a la transaccion que
 * los invoca; la creacion del propietario y el barrido programado tienen que
 * sobrevivir a cualquier problema de mensajeria.
 */
@Service
public class OwnerNotificationUseCase {

    private static final Logger logger = LoggerFactory.getLogger(OwnerNotificationUseCase.class);
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final WhatsappMessageUseCase whatsappMessageUseCase;
    private final String appUrl;

    public OwnerNotificationUseCase(WhatsappMessageUseCase whatsappMessageUseCase,
                                    @Value("${truck.parameter.app-url:" + Constants.APP_URL_DEFAULT + "}") String appUrl) {
        this.whatsappMessageUseCase = whatsappMessageUseCase;
        this.appUrl = appUrl;
    }

    /**
     * Bienvenida con las credenciales y los primeros pasos. Si el propietario
     * tambien conduce se usa la plantilla sin el paso de crear conductor, porque
     * ese conductor ya se creo solo.
     */
    @Transactional(Transactional.TxType.REQUIRES_NEW)
    public void sendWelcome(Owner owner, String plainPassword) {
        String phone = PhoneUtils.toE164(owner.getCellPhone());
        if (phone == null) {
            logger.warn("Propietario {} sin celular: no se envia la bienvenida", owner.getId());
            return;
        }

        String messageType = Boolean.TRUE.equals(owner.getIsDriver())
                ? Constants.WELCOME_OWNER_DRIVER_MESSAGE_TYPE
                : Constants.WELCOME_OWNER_MESSAGE_TYPE;

        List<MessageRequest.KeyValue> data = new ArrayList<>();
        data.add(keyValue("name", owner.getName()));
        data.add(keyValue("appUrl", appUrl));
        data.add(keyValue("email", owner.getEmail()));
        data.add(keyValue("password", plainPassword));

        send(messageType, phone, data);
        logger.info("Bienvenida enviada al propietario {}", owner.getId());
    }

    /** Aviso de vencimiento, con la fecha exacta y cuantos dias faltan. */
    @Transactional(Transactional.TxType.REQUIRES_NEW)
    public void sendSubscriptionReminder(Owner owner) {
        String phone = PhoneUtils.toE164(owner.getCellPhone());
        if (phone == null) {
            logger.warn("Propietario {} sin celular: no se envia el aviso de suscripcion", owner.getId());
            return;
        }

        LocalDate endDate = owner.getSubscriptionEndDate();
        List<MessageRequest.KeyValue> data = new ArrayList<>();
        data.add(keyValue("name", owner.getName()));
        data.add(keyValue("endDate", endDate == null ? "" : endDate.format(DATE_FORMAT)));
        data.add(keyValue("days", String.valueOf(Constants.SUBSCRIPTION_REMINDER_DAYS)));

        send(Constants.SUBSCRIPTION_REMINDER_MESSAGE_TYPE, phone, data);
        logger.info("Aviso de suscripcion enviado al propietario {}", owner.getId());
    }

    private void send(String messageType, String phone, List<MessageRequest.KeyValue> data) {
        MessageRequest messageRequest = new MessageRequest();
        messageRequest.setMedium(MediumEnum.WHATSAPP.getName());
        messageRequest.setMessageType(messageType);
        messageRequest.setPhone(phone);
        messageRequest.setRecipients(List.of(phone));
        messageRequest.setData(data);

        whatsappMessageUseCase.sendWhatsApp(messageRequest, new Audit());
    }

    private MessageRequest.KeyValue keyValue(String key, String value) {
        MessageRequest.KeyValue keyValue = new MessageRequest.KeyValue();
        keyValue.setKey(key);
        keyValue.setValue(value == null ? "" : value);
        return keyValue;
    }
}
