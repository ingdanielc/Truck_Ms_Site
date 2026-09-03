package cash.truck.application.usecases.push;

import cash.truck.domain.dtos.NotificationCreatedEvent;
import cash.truck.domain.dtos.PushPayload;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.transaction.event.TransactionPhase;
import org.springframework.transaction.event.TransactionalEventListener;

import java.util.List;
import java.util.Optional;

/**
 * Reparte por push la notificacion que ya se guardo.
 *
 * Escucha despues del commit y no dentro de la transaccion: si el guardado del
 * viaje termina revirtiendose, el propietario no puede haber recibido ya el
 * aviso de un viaje que no existe. fallbackExecution queda en true porque tres
 * de los casos de uso que crean notificaciones no son transaccionales; sin eso,
 * sus eventos se descartarian en silencio.
 *
 * Nada de lo que pase aqui puede escalar al flujo de negocio: la notificacion
 * interna ya quedo guardada y es la fuente de verdad. El push es un transporte
 * de conveniencia y su fallo se registra, no se propaga.
 */
@Component
public class NotificationPushListener {

    private static final Logger logger = LoggerFactory.getLogger(NotificationPushListener.class);

    private final PushPayloadFactory pushPayloadFactory;
    private final PushRecipientResolver pushRecipientResolver;
    private final PushSenderUseCase pushSenderUseCase;

    public NotificationPushListener(PushPayloadFactory pushPayloadFactory,
                                    PushRecipientResolver pushRecipientResolver,
                                    PushSenderUseCase pushSenderUseCase) {
        this.pushPayloadFactory = pushPayloadFactory;
        this.pushRecipientResolver = pushRecipientResolver;
        this.pushSenderUseCase = pushSenderUseCase;
    }

    @TransactionalEventListener(phase = TransactionPhase.AFTER_COMMIT, fallbackExecution = true)
    public void onNotificationCreated(NotificationCreatedEvent event) {
        try {
            Optional<PushPayload> payload = pushPayloadFactory.build(event);
            if (payload.isEmpty()) {
                // Evento que no sale por push; queda solo como aviso interno.
                return;
            }

            List<Integer> recipients = resolveRecipients(event);
            if (recipients.isEmpty()) {
                logger.debug("Notificacion {} sin destinatario push", event.notificationId());
                return;
            }

            // El envio en si es @Async: esto no bloquea al hilo que confirmo.
            for (Integer userId : recipients) {
                pushSenderUseCase.send(userId, payload.get());
            }
        } catch (Exception e) {
            logger.error("No se pudo repartir por push la notificacion {}: {}",
                    event == null ? null : event.notificationId(), e.getMessage());
        }
    }

    private List<Integer> resolveRecipients(NotificationCreatedEvent event) {
        // El usuario explicito manda cuando viene. Hoy no lo usa nadie —todas
        // las notificaciones se direccionan por propietario o por rol— pero el
        // dia que se use, el push tiene que respetarlo.
        if (event.targetUserId() != null) {
            return List.of(event.targetUserId());
        }

        return switch (pushPayloadFactory.audienceFor(event.eventType())) {
            case ADMIN -> pushRecipientResolver.resolveAdminUserIds();
            case OWNER -> pushRecipientResolver.resolveOwnerUserId(event.ownerId())
                    .map(List::of)
                    .orElseGet(List::of);
            case NONE -> List.of();
        };
    }
}
