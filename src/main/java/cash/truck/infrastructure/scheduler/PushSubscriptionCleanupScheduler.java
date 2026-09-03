package cash.truck.infrastructure.scheduler;

import cash.truck.application.utility.Constants;
import cash.truck.domain.repositories.PushSubscriptionRepository;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Date;

/**
 * Retira las suscripciones muertas.
 *
 * No es un adorno. Un endpoint revocado responde 410 en cada envio, y sin este
 * aseo la tabla acumula filas que solo sirven para gastar una llamada fallida
 * por aviso: el sistema se degrada solo a medida que rota el parque de
 * celulares. Se borran las que acumularon demasiados fallos seguidos y las que
 * llevan un mes inactivas, que ya no aportan ni como historico.
 *
 * Corre los domingos de madrugada porque es un DELETE en bloque y no hay razon
 * para cruzarlo con el uso normal de la aplicacion.
 */
@Component
public class PushSubscriptionCleanupScheduler {

    private static final Logger logger = LoggerFactory.getLogger(PushSubscriptionCleanupScheduler.class);

    private final PushSubscriptionRepository pushSubscriptionRepository;

    public PushSubscriptionCleanupScheduler(PushSubscriptionRepository pushSubscriptionRepository) {
        this.pushSubscriptionRepository = pushSubscriptionRepository;
    }

    @Transactional
    @Scheduled(cron = "${truck.push.cleanup-cron:" + Constants.PUSH_CLEANUP_CRON + "}",
            zone = Constants.ZONE_BOGOTA)
    public void cleanUpDeadSubscriptions() {
        Date inactiveBefore = Date.from(LocalDate.now(ZoneId.of(Constants.ZONE_BOGOTA))
                .minusDays(Constants.PUSH_CLEANUP_INACTIVE_DAYS)
                .atStartOfDay(ZoneId.of(Constants.ZONE_BOGOTA))
                .toInstant());

        int removed = pushSubscriptionRepository.deleteDeadSubscriptions(
                Constants.PUSH_MAX_FAILURES, inactiveBefore);

        if (removed > 0) {
            logger.info("Aseo de push: {} suscripcion(es) retirada(s)", removed);
        } else {
            logger.debug("Aseo de push: nada que retirar");
        }
    }
}
