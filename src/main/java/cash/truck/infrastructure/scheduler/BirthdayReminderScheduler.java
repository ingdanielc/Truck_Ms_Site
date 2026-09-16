package cash.truck.infrastructure.scheduler;

import cash.truck.application.usecases.InAppNotificationUseCase;
import cash.truck.application.usecases.push.PushRecipientResolver;
import cash.truck.application.utility.Constants;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.OwnerRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.Month;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

/**
 * Saluda a los propietarios y conductores que cumplen anos hoy.
 *
 * Reemplaza al evento daily_birthday_check de la base de datos. El saludo y
 * el push son solo para quien cumple anos.
 *
 * Solo se saluda a quien tiene acceso a la app, como hacia el evento: sin
 * usuario activo no hay quien lea el saludo ni dispositivo al que enviarlo.
 * Un propietario que tambien conduce tiene un conductor espejo con el mismo
 * usuario y la misma fecha: recibe un solo saludo, el de propietario.
 *
 * Quien nacio un 29 de febrero se saluda el 28 en los anos no bisiestos; de lo
 * contrario pasarian tres anos sin saludo.
 */
@Component
public class BirthdayReminderScheduler {

    private static final Logger logger = LoggerFactory.getLogger(BirthdayReminderScheduler.class);
    private static final DateTimeFormatter MONTH_DAY = DateTimeFormatter.ofPattern("MM-dd");

    private final OwnerRepository ownerRepository;
    private final DriverRepository driverRepository;
    private final InAppNotificationUseCase inAppNotificationUseCase;
    private final PushRecipientResolver pushRecipientResolver;

    public BirthdayReminderScheduler(OwnerRepository ownerRepository,
                                     DriverRepository driverRepository,
                                     InAppNotificationUseCase inAppNotificationUseCase,
                                     PushRecipientResolver pushRecipientResolver) {
        this.ownerRepository = ownerRepository;
        this.driverRepository = driverRepository;
        this.inAppNotificationUseCase = inAppNotificationUseCase;
        this.pushRecipientResolver = pushRecipientResolver;
    }

    @Scheduled(cron = "${truck.parameter.birthday-reminder-cron:" + Constants.BIRTHDAY_REMINDER_CRON + "}",
            zone = Constants.ZONE_BOGOTA)
    public void notifyBirthdays() {
        List<String> monthDays = birthdayMonthDays(LocalDate.now(ZoneId.of(Constants.ZONE_BOGOTA)));
        // Usuarios ya saludados en este pase: evita el doble saludo del
        // propietario que tambien conduce.
        Set<Integer> greetedUserIds = new HashSet<>();

        int owners = 0;
        for (Number id : ownerRepository.findIdsByBirthdayIn(monthDays)) {
            Long ownerId = id.longValue();
            // Una persona que falle no puede dejar sin saludo a las demas.
            try {
                Optional<Integer> userId = pushRecipientResolver.resolveActiveOwnerUserId(ownerId);
                if (userId.isEmpty() || !greetedUserIds.add(userId.get())) {
                    continue;
                }
                String name = ownerRepository.findById(ownerId).map(Owner::getName).orElse("");
                String message = "¡Feliz cumpleaños, " + name
                        + "! Todo el equipo de CashTruck te desea un excelente día.";
                inAppNotificationUseCase.notifyOwnersAndDrivers(Constants.BIRTHDAY_EVENT_TYPE, message,
                        List.of(ownerId), ownerId, List.of(), null);
                owners++;
            } catch (Exception e) {
                logger.error("No se pudo saludar al propietario {}: {}", ownerId, e.getMessage());
            }
        }

        int drivers = 0;
        for (Number id : driverRepository.findIdsByBirthdayIn(monthDays)) {
            Long driverId = id.longValue();
            try {
                Optional<Integer> userId = pushRecipientResolver.resolveDriverUserId(driverId);
                if (userId.isEmpty() || !greetedUserIds.add(userId.get())) {
                    continue;
                }
                var driver = driverRepository.findById(driverId);
                if (driver.isEmpty()) {
                    continue;
                }
                String message = "¡Feliz cumpleaños, " + driver.get().getName()
                        + "! Te deseamos un viaje seguro y un gran día de celebración.";
                inAppNotificationUseCase.notifyOwnersAndDrivers(Constants.BIRTHDAY_EVENT_TYPE, message,
                        List.of(), driverId, List.of(driverId), null);
                drivers++;
            } catch (Exception e) {
                logger.error("No se pudo saludar al conductor {}: {}", driverId, e.getMessage());
            }
        }

        logger.info("Saludos de cumpleaños enviados: {} propietario(s) y {} conductor(es)", owners, drivers);
    }

    /** Hoy como MM-dd, y el 29 de febrero cuando hoy es 28 en un ano no bisiesto. */
    static List<String> birthdayMonthDays(LocalDate today) {
        List<String> monthDays = new ArrayList<>();
        monthDays.add(today.format(MONTH_DAY));
        if (today.getMonth() == Month.FEBRUARY && today.getDayOfMonth() == 28 && !today.isLeapYear()) {
            monthDays.add("02-29");
        }
        return monthDays;
    }
}
