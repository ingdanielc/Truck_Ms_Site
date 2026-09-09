package cash.truck.infrastructure.scheduler;

import cash.truck.application.usecases.InAppNotificationUseCase;
import cash.truck.application.usecases.push.PushRecipientResolver;
import cash.truck.application.utility.Constants;
import cash.truck.domain.repositories.NotificationRepository;
import cash.truck.domain.repositories.TripRepository;
import cash.truck.domain.repositories.TripRepository.InactiveTripRow;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;
import java.util.List;
import java.util.Optional;

/**
 * Avisa cuando un viaje se queda quieto.
 *
 * Cubre dos silencios que hoy nadie detecta:
 *
 *  - un viaje en curso que lleva 12 horas sin un solo gasto registrado,
 *  - un viaje cerrado hace 24 horas sin que se haya abierto el siguiente, y
 *  - un viaje que lleva 5 dias en curso sin pasar a Pendiente ni a Completado.
 *
 * Los tres avisos van al propietario y al conductor a la vez, porque cualquiera
 * de los dos puede ser quien tenga que actuar: el conductor registra el gasto,
 * crea el viaje o lo cierra, y el propietario es quien nota que su vehiculo
 * esta parado. Al conductor solo se le avisa si tiene acceso a la app; si no lo
 * tiene no se le crea ni la notificacion interna ni el push.
 *
 * Corre cada hora y no una vez al dia porque el umbral se mide en horas: con un
 * solo pase diario, un viaje que cumple las 12 horas por la manana esperaria
 * hasta el dia siguiente. Repetir el pase no duplica avisos: antes de crear
 * ninguno se comprueba que no exista ya uno del mismo tipo para ese viaje.
 *
 * El aviso es interno y sale ademas por push; no se envia por WhatsApp, igual
 * que el vencimiento de documentos.
 */
@Component
public class InactivityReminderScheduler {

    private static final Logger logger = LoggerFactory.getLogger(InactivityReminderScheduler.class);

    private final TripRepository tripRepository;
    private final NotificationRepository notificationRepository;
    private final InAppNotificationUseCase inAppNotificationUseCase;
    private final PushRecipientResolver pushRecipientResolver;

    public InactivityReminderScheduler(TripRepository tripRepository,
                                       NotificationRepository notificationRepository,
                                       InAppNotificationUseCase inAppNotificationUseCase,
                                       PushRecipientResolver pushRecipientResolver) {
        this.tripRepository = tripRepository;
        this.notificationRepository = notificationRepository;
        this.inAppNotificationUseCase = inAppNotificationUseCase;
        this.pushRecipientResolver = pushRecipientResolver;
    }

    @Scheduled(cron = "${truck.parameter.inactivity-reminder-cron:" + Constants.INACTIVITY_REMINDER_CRON + "}",
            zone = Constants.ZONE_BOGOTA)
    public void notifyInactivity() {
        notifyTripsWithoutExpenses();
        notifyClosedTripsWithoutFollowUp();
        notifyStalledTrips();
    }

    /** Viaje que lleva 5 dias en curso sin que nadie lo pase de estado. */
    private void notifyStalledTrips() {
        Date threshold = daysAgo(Constants.TRIP_STALLED_DAYS);
        List<InactiveTripRow> trips = tripRepository.findStalledInProgressTrips(
                Constants.TRIP_STATUS_IN_PROGRESS, threshold);

        if (trips.isEmpty()) {
            logger.info("Sin viajes en curso de mas de {} dias", Constants.TRIP_STALLED_DAYS);
            return;
        }

        int sent = 0;
        for (InactiveTripRow trip : trips) {
            try {
                if (notify(trip, Constants.TRIP_STALLED_EVENT_TYPE, stalledMessage(trip))) {
                    sent++;
                }
            } catch (Exception e) {
                logger.error("No se pudo avisar el estancamiento del viaje {}: {}", trip.getTripId(),
                        e.getMessage());
            }
        }
        logger.info("Avisado el estancamiento en {} de {} viaje(s) en curso", sent, trips.size());
    }

    /** Viaje en curso que lleva 12 horas sin que nadie cargue un gasto. */
    private void notifyTripsWithoutExpenses() {
        Date threshold = hoursAgo(Constants.EXPENSE_INACTIVITY_HOURS);
        List<InactiveTripRow> trips = tripRepository.findInProgressTripsWithoutExpenses(
                Constants.TRIP_STATUS_IN_PROGRESS, threshold);

        if (trips.isEmpty()) {
            logger.info("Sin viajes en curso de mas de {} horas sin gastos", Constants.EXPENSE_INACTIVITY_HOURS);
            return;
        }

        int sent = 0;
        for (InactiveTripRow trip : trips) {
            // Un viaje que falle no puede dejar sin aviso a los demas.
            try {
                if (notify(trip, Constants.EXPENSE_INACTIVITY_EVENT_TYPE, expenseMessage(trip))) {
                    sent++;
                }
            } catch (Exception e) {
                logger.error("No se pudo avisar la falta de gastos del viaje {}: {}", trip.getTripId(),
                        e.getMessage());
            }
        }
        logger.info("Avisada la falta de gastos en {} de {} viaje(s) en curso", sent, trips.size());
    }

    /** Viaje cerrado hace 24 horas y ningun viaje nuevo despues. */
    private void notifyClosedTripsWithoutFollowUp() {
        Date threshold = hoursAgo(Constants.TRIP_INACTIVITY_HOURS);
        List<InactiveTripRow> trips = tripRepository.findClosedTripsWithoutFollowUp(
                Constants.TRIP_STATUS_IN_PROGRESS, Constants.TRIP_STATUS_CANCELLED, threshold);

        if (trips.isEmpty()) {
            logger.info("Sin viajes cerrados hace mas de {} horas sin relevo", Constants.TRIP_INACTIVITY_HOURS);
            return;
        }

        int sent = 0;
        for (InactiveTripRow trip : trips) {
            try {
                if (notify(trip, Constants.TRIP_INACTIVITY_EVENT_TYPE, tripMessage(trip))) {
                    sent++;
                }
            } catch (Exception e) {
                logger.error("No se pudo avisar la falta de viaje nuevo tras el viaje {}: {}", trip.getTripId(),
                        e.getMessage());
            }
        }
        logger.info("Avisada la falta de viaje nuevo en {} de {} caso(s)", sent, trips.size());
    }

    /**
     * Crea el aviso para el propietario y el del conductor, y devuelve si hubo
     * algo que crear.
     *
     * Son dos filas y no una porque la bandeja de notificaciones se consulta
     * por destinatario: una sola fila la veria uno de los dos. La del conductor
     * lleva target_user_id, que es lo que hace que su push le llegue a el y no
     * al propietario.
     *
     * El corte por reference_id se hace antes de las dos y no dentro de cada
     * una: asi el estado es siempre el mismo, o estan las dos o no esta
     * ninguna, y el pase de la hora siguiente no rellena la que falte.
     */
    private boolean notify(InactiveTripRow trip, String eventType, String message) {
        Long tripId = toLong(trip.getTripId());
        if (tripId == null) {
            return false;
        }
        if (notificationRepository.existsByEventTypeAndReferenceId(eventType, tripId)) {
            // Ya se aviso en un pase anterior; la condicion sigue vigente pero
            // el aviso no se repite.
            return false;
        }

        Long ownerId = toLong(trip.getOwnerId());
        inAppNotificationUseCase.createNotification(eventType, message, Constants.ROLE_ID_OWNER, null,
                ownerId, tripId);

        // Un conductor sin acceso a la app —sin usuario, o con el usuario
        // inactivo— no recibe nada: ni push, porque no tiene dispositivo
        // suscrito, ni notificacion interna, porque no puede entrar a leerla.
        Optional<Integer> driverUserId = pushRecipientResolver.resolveDriverUserId(toLong(trip.getDriverId()));
        driverUserId.ifPresent(userId -> inAppNotificationUseCase.createNotification(eventType, message,
                Constants.ROLE_ID_DRIVER, userId, ownerId, tripId));

        return true;
    }

    /**
     * El numero de viaje y la placa son lo que situa al propietario cuando
     * tiene varios vehiculos rodando a la vez.
     */
    private String expenseMessage(InactiveTripRow trip) {
        return "El viaje " + trip.getNumberTrip() + " del vehículo de placa " + trip.getPlate()
                + " lleva más de " + Constants.EXPENSE_INACTIVITY_HOURS
                + " horas en curso sin gastos registrados.";
    }

    private String tripMessage(InactiveTripRow trip) {
        return "Pasaron más de " + Constants.TRIP_INACTIVITY_HOURS + " horas desde el cierre del viaje "
                + trip.getNumberTrip() + " del vehículo de placa " + trip.getPlate()
                + " y aún no se ha creado uno nuevo.";
    }

    /**
     * Nombra los dos estados que se esperan porque el aviso pide una accion
     * concreta: el destinatario tiene que saber a que debe pasar el viaje.
     */
    private String stalledMessage(InactiveTripRow trip) {
        return "El viaje " + trip.getNumberTrip() + " del vehículo de placa " + trip.getPlate()
                + " lleva más de " + Constants.TRIP_STALLED_DAYS + " días en curso sin pasar a "
                + Constants.TRIP_STATUS_PENDING + " ni a " + Constants.TRIP_STATUS_COMPLETED + ".";
    }

    private Date hoursAgo(int hours) {
        return Date.from(Instant.now().minus(hours, ChronoUnit.HOURS));
    }

    private Date daysAgo(int days) {
        return Date.from(Instant.now().minus(days, ChronoUnit.DAYS));
    }

    /** Las proyecciones nativas devuelven Number: MySQL no promete el tipo. */
    private Long toLong(Number value) {
        return value == null ? null : value.longValue();
    }
}
