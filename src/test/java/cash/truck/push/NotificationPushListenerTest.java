package cash.truck.push;

import cash.truck.application.usecases.push.NotificationPushListener;
import cash.truck.application.usecases.push.PushPayloadFactory;
import cash.truck.application.usecases.push.PushRecipientResolver;
import cash.truck.application.usecases.push.PushSenderUseCase;
import cash.truck.domain.dtos.NotificationCreatedEvent;
import cash.truck.domain.dtos.PushPayload;
import cash.truck.domain.repositories.DocumentFileRepository;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;

/**
 * Fija a quien sale el push de cada copia: la del conductor lleva su usuario y
 * el push es para el; la del propietario va sin usuario y el push es para el
 * propietario.
 */
class NotificationPushListenerTest {

    private final PushRecipientResolver resolver = mock(PushRecipientResolver.class);
    private final PushSenderUseCase sender = mock(PushSenderUseCase.class);
    private final NotificationPushListener listener = new NotificationPushListener(
            new PushPayloadFactory(mock(DocumentFileRepository.class)), resolver, sender);

    @Test
    void laCopiaDelConductorSoloLeLlegaAEl() {
        listener.onNotificationCreated(new NotificationCreatedEvent(1L, "TRIP_EVENT", "Mensaje", 7L, 55L, 20));

        verify(sender).send(eq(20), any(PushPayload.class));
        verify(resolver, never()).resolveOwnerUserId(any());
    }

    @Test
    void laCopiaDelPropietarioLeLlegaAlPropietario() {
        when(resolver.resolveOwnerUserId(7L)).thenReturn(Optional.of(30));

        listener.onNotificationCreated(new NotificationCreatedEvent(1L, "TRIP_EVENT", "Mensaje", 7L, 55L, null));

        verify(sender).send(eq(30), any(PushPayload.class));
    }

    @Test
    void quienRegistraElGastoNoRecibePushDeSuCopia() {
        listener.onNotificationCreated(
                new NotificationCreatedEvent(1L, "EXPENSE_EVENT", "Mensaje", 7L, 55L, 20, 20));

        verify(sender, never()).send(anyInt(), any(PushPayload.class));
    }
}
