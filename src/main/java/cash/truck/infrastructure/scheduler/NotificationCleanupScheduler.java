package cash.truck.infrastructure.scheduler;

import cash.truck.application.utility.Constants;
import cash.truck.domain.repositories.NotificationRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Date;

/**
 * Borra las notificaciones internas viejas.
 *
 * Nada mas las elimina: limpiar la bandeja solo las marca como borradas, y los
 * avisos programados agregan filas todos los dias. Sin este aseo la tabla crece
 * sin techo y la consulta de la bandeja, que el front repite cada cinco
 * minutos, se vuelve lenta con el tiempo.
 *
 * Reglas:
 *  - las borradas por el usuario, a los 30 dias,
 *  - cualquier otra, leida o no, a los 90 dias,
 *  - nunca los avisos de una sola vez por viaje (sin viaje nuevo y viaje sin
 *    cerrar): su fila es la que impide que se repitan.
 *
 * Borra en lotes de 1.000, cada uno en su propia transaccion, para no retener
 * bloqueos sobre la tabla. Corre los domingos de madrugada, fuera de uso.
 */
@Component
public class NotificationCleanupScheduler {

    private static final Logger logger = LoggerFactory.getLogger(NotificationCleanupScheduler.class);

    private final NotificationRepository notificationRepository;

    public NotificationCleanupScheduler(NotificationRepository notificationRepository) {
        this.notificationRepository = notificationRepository;
    }

    @Scheduled(cron = "${truck.parameter.notification-cleanup-cron:" + Constants.NOTIFICATION_CLEANUP_CRON + "}",
            zone = Constants.ZONE_BOGOTA)
    public void purgeOldNotifications() {
        Date deletedBefore = daysAgo(Constants.NOTIFICATION_CLEANUP_DELETED_DAYS);
        Date createdBefore = daysAgo(Constants.NOTIFICATION_CLEANUP_RETENTION_DAYS);

        int total = 0;
        try {
            int batch;
            do {
                batch = notificationRepository.deleteExpiredBatch(
                        Constants.NOTIFICATION_CLEANUP_EXCLUDED_EVENT_TYPES, deletedBefore, createdBefore,
                        Constants.NOTIFICATION_CLEANUP_BATCH_SIZE);
                total += batch;
            } while (batch == Constants.NOTIFICATION_CLEANUP_BATCH_SIZE);
        } catch (Exception e) {
            // Los lotes ya confirmados se quedan; el domingo siguiente sigue.
            logger.error("Aseo de notificaciones interrumpido tras {} fila(s): {}", total, e.getMessage());
            return;
        }

        if (total > 0) {
            logger.info("Aseo de notificaciones: {} fila(s) eliminada(s)", total);
        } else {
            logger.debug("Aseo de notificaciones: nada que eliminar");
        }
    }

    private Date daysAgo(int days) {
        ZoneId zone = ZoneId.of(Constants.ZONE_BOGOTA);
        return Date.from(LocalDate.now(zone).minusDays(days).atStartOfDay(zone).toInstant());
    }
}
