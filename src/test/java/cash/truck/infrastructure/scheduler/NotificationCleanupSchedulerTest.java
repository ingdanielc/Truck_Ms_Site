package cash.truck.infrastructure.scheduler;

import cash.truck.domain.repositories.NotificationRepository;
import org.junit.jupiter.api.Test;

import java.util.Collection;
import java.util.Date;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

class NotificationCleanupSchedulerTest {

    private final NotificationRepository repository = mock(NotificationRepository.class);
    private final NotificationCleanupScheduler scheduler = new NotificationCleanupScheduler(repository);

    @Test
    void sigueBorrandoMientrasLosLotesVenganLlenos() {
        when(repository.deleteExpiredBatch(anyCollection(), any(Date.class), any(Date.class), eq(1000)))
                .thenReturn(1000, 1000, 250);

        scheduler.purgeOldNotifications();

        verify(repository, times(3)).deleteExpiredBatch(anyCollection(), any(Date.class), any(Date.class), eq(1000));
    }

    @Test
    void nuncaBorraLosAvisosDeUnaSolaVezPorViaje() {
        when(repository.deleteExpiredBatch(anyCollection(), any(Date.class), any(Date.class), anyInt()))
                .thenReturn(0);

        scheduler.purgeOldNotifications();

        verify(repository).deleteExpiredBatch(argThat((Collection<String> types) ->
                types.containsAll(List.of("TRIP_INACTIVITY_ALERT", "TRIP_STALLED_ALERT")) && types.size() == 2),
                any(Date.class), any(Date.class), anyInt());
    }

    @Test
    void lasBorradasVencenAntesQueElRestoDeLaBandeja() {
        when(repository.deleteExpiredBatch(anyCollection(), any(Date.class), any(Date.class), anyInt()))
                .thenReturn(0);

        scheduler.purgeOldNotifications();

        var deleted = org.mockito.ArgumentCaptor.forClass(Date.class);
        var created = org.mockito.ArgumentCaptor.forClass(Date.class);
        verify(repository, atLeastOnce()).deleteExpiredBatch(anyCollection(), deleted.capture(), created.capture(),
                anyInt());
        long days = (deleted.getValue().getTime() - created.getValue().getTime()) / 86_400_000L;
        assertEquals(60, days, 1);
    }
}
