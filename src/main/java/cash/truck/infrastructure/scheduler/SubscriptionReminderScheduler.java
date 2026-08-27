package cash.truck.infrastructure.scheduler;

import cash.truck.application.usecases.notifications.OwnerNotificationUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.repositories.OwnerRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

/**
 * Avisa a los propietarios cuya suscripcion vence en tres dias.
 *
 * Corre una vez al dia y busca la fecha de vencimiento exacta, no un rango, de
 * modo que a cada propietario le llega un solo aviso. Si el servicio estuvo
 * caido a la hora programada ese dia se pierde el aviso: no hay reintento,
 * porque repetirlo al dia siguiente cambiaria los dias de antelacion.
 */
@Component
public class SubscriptionReminderScheduler {

    private static final Logger logger = LoggerFactory.getLogger(SubscriptionReminderScheduler.class);

    private final OwnerRepository ownerRepository;
    private final OwnerNotificationUseCase ownerNotificationUseCase;

    public SubscriptionReminderScheduler(OwnerRepository ownerRepository,
                                         OwnerNotificationUseCase ownerNotificationUseCase) {
        this.ownerRepository = ownerRepository;
        this.ownerNotificationUseCase = ownerNotificationUseCase;
    }

    @Scheduled(cron = "${truck.parameter.subscription-reminder-cron:" + Constants.SUBSCRIPTION_REMINDER_CRON + "}",
            zone = Constants.ZONE_BOGOTA)
    public void notifyExpiringSubscriptions() {
        LocalDate target = LocalDate.now(ZoneId.of(Constants.ZONE_BOGOTA))
                .plusDays(Constants.SUBSCRIPTION_REMINDER_DAYS);

        List<Owner> expiring = ownerRepository.findBySubscriptionEndDate(target);
        if (expiring.isEmpty()) {
            logger.info("Sin suscripciones que venzan el {}", target);
            return;
        }

        logger.info("Avisando a {} propietario(s) por vencimiento el {}", expiring.size(), target);
        for (Owner owner : expiring) {
            // Un propietario que falle no puede dejar sin aviso a los demas.
            try {
                ownerNotificationUseCase.sendSubscriptionReminder(owner);
            } catch (Exception e) {
                logger.error("No se pudo avisar al propietario {}: {}", owner.getId(), e.getMessage());
            }
        }
    }
}
