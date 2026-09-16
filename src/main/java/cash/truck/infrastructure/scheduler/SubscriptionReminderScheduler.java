package cash.truck.infrastructure.scheduler;

import cash.truck.application.usecases.InAppNotificationUseCase;
import cash.truck.application.usecases.notifications.OwnerNotificationUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.entities.Driver;
import cash.truck.domain.entities.Users;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.UserRoleRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * Avisa a los propietarios que su suscripcion esta por vencer, por dos vias
 * independientes:
 *
 *  - WhatsApp al propietario tres dias antes,
 *  - notificacion interna y push 10, 5 y 1 dia antes. Reemplaza al evento
 *    daily_subscription_expiry_check de la base de datos: al propietario y a
 *    cada uno de sus conductores con acceso a la app, con su propia fila y su
 *    push. El administrador queda fuera.
 *
 * Corre una vez al dia y busca la fecha de vencimiento exacta, no un rango, de
 * modo que a cada propietario le llega un solo aviso. Si el servicio estuvo
 * caido a la hora programada ese dia se pierde el aviso: no hay reintento,
 * porque repetirlo al dia siguiente cambiaria los dias de antelacion.
 */
@Component
public class SubscriptionReminderScheduler {

    private static final Logger logger = LoggerFactory.getLogger(SubscriptionReminderScheduler.class);

    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final OwnerRepository ownerRepository;
    private final OwnerNotificationUseCase ownerNotificationUseCase;
    private final InAppNotificationUseCase inAppNotificationUseCase;
    private final DriverRepository driverRepository;
    private final UserRoleRepository userRoleRepository;

    public SubscriptionReminderScheduler(OwnerRepository ownerRepository,
                                         OwnerNotificationUseCase ownerNotificationUseCase,
                                         InAppNotificationUseCase inAppNotificationUseCase,
                                         DriverRepository driverRepository,
                                         UserRoleRepository userRoleRepository) {
        this.ownerRepository = ownerRepository;
        this.ownerNotificationUseCase = ownerNotificationUseCase;
        this.inAppNotificationUseCase = inAppNotificationUseCase;
        this.driverRepository = driverRepository;
        this.userRoleRepository = userRoleRepository;
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
    @Scheduled(cron = "${truck.parameter.subscription-expiration-notice-cron:"
            + Constants.SUBSCRIPTION_EXPIRATION_NOTICE_CRON + "}", zone = Constants.ZONE_BOGOTA)
    public void notifyExpiringSubscriptionsInApp() {
        LocalDate today = LocalDate.now(ZoneId.of(Constants.ZONE_BOGOTA));
        Set<Integer> adminUserIds = new HashSet<>(userRoleRepository.findUserIdsByRoleId(Constants.ROLE_ID_ADMIN));

        for (Integer days : Constants.SUBSCRIPTION_EXPIRATION_NOTICE_DAYS) {
            List<Owner> expiring = ownerRepository.findBySubscriptionEndDate(today.plusDays(days));
            int sent = 0;
            for (Owner owner : expiring) {
                // Un propietario que falle no puede dejar sin aviso a los demas.
                try {
                    if (notifyInApp(owner, days, adminUserIds)) {
                        sent++;
                    }
                } catch (Exception e) {
                    logger.error("No se pudo crear el aviso de suscripcion del propietario {}: {}", owner.getId(),
                            e.getMessage());
                }
            }
            logger.info("Aviso interno de suscripcion a {} dia(s): {} propietario(s)", days, sent);
        }
    }

    /**
     * Mismas reglas que el evento al que reemplaza: se omite al administrador y
     * al propietario con usuario inactivo; el propietario sin usuario si se
     * avisa, porque sus conductores si pueden entrar a la app.
     */
    private boolean notifyInApp(Owner owner, int days, Set<Integer> adminUserIds) {
        Users user = owner.getUser();
        if (user != null && (adminUserIds.contains(user.getId())
                || !Constants.STATUS_ACTIVE.equals(user.getStatus()))) {
            return false;
        }

        List<Long> driverIds = driverRepository.findByOwnerId(owner.getId()).stream()
                .map(Driver::getId)
                .toList();
        inAppNotificationUseCase.notifyOwnersAndDrivers(Constants.SUBSCRIPTION_EXPIRATION_EVENT_TYPE,
                inAppMessage(owner, days), List.of(owner.getId()), owner.getId(), driverIds, null);
        return true;
    }

    private String inAppMessage(Owner owner, int days) {
        String when = days == 1 ? "mañana" : "en " + days + " días";
        return "La suscripción de " + owner.getName() + " vence " + when
                + " (" + owner.getSubscriptionEndDate().format(DATE_FORMAT) + "). "
                + "Al vencer no será posible ingresar a la aplicación. "
                + "Contacta al administrador por WhatsApp para renovarla.";
    }
}
