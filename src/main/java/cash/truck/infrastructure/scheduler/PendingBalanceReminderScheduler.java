package cash.truck.infrastructure.scheduler;

import cash.truck.application.usecases.InAppNotificationUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.domain.repositories.TripRepository;
import cash.truck.domain.repositories.TripRepository.PendingBalanceTripRow;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.List;

/**
 * Avisa los viajes en Pendiente que llevan dias con saldo sin cobrar.
 *
 * Reemplaza al evento daily_pending_balance_check de la base de datos. El
 * aviso va al propietario y al conductor del viaje, cada uno con su fila y su
 * push. El seguimiento de cartera
 * que el evento mandaba al administrador se retiro a proposito.
 *
 * Igual que el evento, avisa todos los dias mientras el saldo siga sin pagar:
 * el aviso es un recordatorio de cobro, no un hito.
 */
@Component
public class PendingBalanceReminderScheduler {

    private static final Logger logger = LoggerFactory.getLogger(PendingBalanceReminderScheduler.class);

    private final TripRepository tripRepository;
    private final InAppNotificationUseCase inAppNotificationUseCase;

    public PendingBalanceReminderScheduler(TripRepository tripRepository,
                                           InAppNotificationUseCase inAppNotificationUseCase) {
        this.tripRepository = tripRepository;
        this.inAppNotificationUseCase = inAppNotificationUseCase;
    }

    @Scheduled(cron = "${truck.parameter.pending-balance-reminder-cron:" + Constants.PENDING_BALANCE_REMINDER_CRON + "}",
            zone = Constants.ZONE_BOGOTA)
    public void notifyPendingBalances() {
        LocalDate today = LocalDate.now(ZoneId.of(Constants.ZONE_BOGOTA));
        List<PendingBalanceTripRow> trips = tripRepository.findPendingBalanceTrips(Constants.TRIP_STATUS_PENDING,
                today.minusDays(Constants.PENDING_BALANCE_DAYS));
        if (trips.isEmpty()) {
            logger.info("Sin viajes con saldo pendiente de cobro hace {} dias o mas", Constants.PENDING_BALANCE_DAYS);
            return;
        }

        int sent = 0;
        for (PendingBalanceTripRow trip : trips) {
            // Un viaje que falle no puede dejar sin aviso a los demas.
            try {
                notifyTrip(trip, today);
                sent++;
            } catch (Exception e) {
                logger.error("No se pudo avisar el saldo pendiente del viaje {}: {}", trip.getTripId(),
                        e.getMessage());
            }
        }
        logger.info("Avisado el saldo pendiente de {} de {} viaje(s)", sent, trips.size());
    }

    private void notifyTrip(PendingBalanceTripRow trip, LocalDate today) {
        Long tripId = toLong(trip.getTripId());
        Long ownerId = toLong(trip.getOwnerId());
        long days = trip.getPendingSince() == null ? Constants.PENDING_BALANCE_DAYS
                : ChronoUnit.DAYS.between(toLocalDate(trip.getPendingSince()), today);

        if (ownerId == null) {
            // Sin propietario la fila quedaria en la bandeja del administrador.
            logger.warn("Viaje {} sin propietario: no se avisa el saldo pendiente", tripId);
            return;
        }

        inAppNotificationUseCase.notifyOwnerAndDriver(Constants.PENDING_BALANCE_EVENT_TYPE,
                ownerMessage(trip, days), ownerId, tripId, toLong(trip.getDriverId()));
    }

    private String ownerMessage(PendingBalanceTripRow trip, long days) {
        StringBuilder message = new StringBuilder("El viaje #").append(trip.getNumberTrip());
        if (trip.getManifestNumber() != null && !trip.getManifestNumber().isBlank()) {
            message.append(" (Manifiesto: ").append(trip.getManifestNumber()).append(")");
        }
        message.append(" lleva ").append(days).append(" días pendiente de cobro. Saldo: ")
                .append(formatMoney(trip.getBalance())).append(".");
        return message.toString();
    }

    /** Pesos sin decimales y con punto de miles: $1.250.000. */
    private String formatMoney(BigDecimal amount) {
        DecimalFormatSymbols symbols = new DecimalFormatSymbols();
        symbols.setGroupingSeparator('.');
        return "$" + new DecimalFormat("#,##0", symbols).format(amount == null ? BigDecimal.ZERO : amount);
    }

    private LocalDate toLocalDate(java.util.Date date) {
        // java.sql.Date no admite toInstant(); se pasa por el epoch.
        return java.time.Instant.ofEpochMilli(date.getTime()).atZone(ZoneId.of(Constants.ZONE_BOGOTA)).toLocalDate();
    }

    /** Las proyecciones nativas devuelven Number: MySQL no promete el tipo. */
    private Long toLong(Number value) {
        return value == null ? null : value.longValue();
    }
}
