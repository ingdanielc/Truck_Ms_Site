package cash.truck.application.usecases.notifications;

import cash.truck.application.utility.Constants;
import cash.truck.application.utility.PhoneUtils;
import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.Driver;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.enums.MediumEnum;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

/**
 * Mensajes de WhatsApp dirigidos al conductor. Por ahora solo la bienvenida que
 * recibe cuando el propietario le da acceso a la app.
 *
 * Corre en una transaccion propia (REQUIRES_NEW) por la misma razon que la del
 * propietario: la creacion del conductor no puede caerse porque falle guardar
 * la trazabilidad del mensaje.
 */
@Service
public class DriverNotificationUseCase {

    private static final Logger logger = LoggerFactory.getLogger(DriverNotificationUseCase.class);

    private final WhatsappMessageUseCase whatsappMessageUseCase;
    private final String appUrl;

    public DriverNotificationUseCase(WhatsappMessageUseCase whatsappMessageUseCase,
            @Value("${truck.parameter.app-url:" + Constants.APP_URL_DEFAULT + "}") String appUrl) {
        this.whatsappMessageUseCase = whatsappMessageUseCase;
        this.appUrl = appUrl;
    }

    /**
     * Bienvenida con las credenciales y los primeros pasos. El conductor no crea
     * conductores ni vehiculos, asi que su recorrido arranca directamente en la
     * creacion de viajes.
     */
    @Transactional(Transactional.TxType.REQUIRES_NEW)
    public void sendWelcome(Driver driver, String plainPassword) {
        String phone = PhoneUtils.toE164(driver.getCellPhone());
        if (phone == null) {
            logger.warn("Conductor {} sin celular: no se envia la bienvenida", driver.getId());
            return;
        }

        List<MessageRequest.KeyValue> data = new ArrayList<>();
        data.add(keyValue("name", driver.getName()));
        data.add(keyValue("appUrl", appUrl));
        data.add(keyValue("email", driver.getEmail()));
        data.add(keyValue("password", plainPassword));

        MessageRequest messageRequest = new MessageRequest();
        messageRequest.setMedium(MediumEnum.WHATSAPP.getName());
        messageRequest.setMessageType(Constants.WELCOME_DRIVER_MESSAGE_TYPE);
        messageRequest.setPhone(phone);
        messageRequest.setRecipients(List.of(phone));
        messageRequest.setData(data);

        whatsappMessageUseCase.sendWhatsApp(messageRequest, new Audit());
        logger.info("Bienvenida enviada al conductor {}", driver.getId());
    }

    private MessageRequest.KeyValue keyValue(String key, String value) {
        MessageRequest.KeyValue keyValue = new MessageRequest.KeyValue();
        keyValue.setKey(key);
        keyValue.setValue(value == null ? "" : value);
        return keyValue;
    }
}
