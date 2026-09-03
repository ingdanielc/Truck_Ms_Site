package cash.truck.application.usecases.push;

import cash.truck.application.utility.Constants;
import cash.truck.domain.dtos.NotificationCreatedEvent;
import cash.truck.domain.dtos.PushPayload;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * Traduce una notificacion interna al aviso que se muestra en el celular.
 *
 * Aqui vive la matriz de canales: que evento sale por push, a quien y a que
 * pantalla lleva. Es deliberado que la decision este en un solo lugar y no
 * repartida por los casos de uso, para que cambiar un canal no obligue a
 * revisar cinco archivos.
 */
@Component
public class PushPayloadFactory {

    /** A quien va cada evento. Lo que no este aqui no sale por push. */
    public PushAudience audienceFor(String eventType) {
        if (eventType == null) {
            return PushAudience.NONE;
        }
        return switch (eventType) {
            case Constants.TRIP_EVENT_TYPE,
                 Constants.EXPENSE_EVENT_TYPE,
                 Constants.VEHICLE_EVENT_TYPE,
                 Constants.DRIVER_EVENT_TYPE,
                 Constants.DOCUMENT_EXPIRY_EVENT_TYPE -> PushAudience.OWNER;
            // Se guarda sin owner_id porque avisa al administrador que hay una
            // cuenta nueva, venga del alta administrativa o del registro
            // publico. El propietario recien creado no es el destinatario: al
            // momento del alta ni siquiera tiene un dispositivo suscrito.
            case Constants.OWNER_EVENT_TYPE -> PushAudience.ADMIN;
            default -> PushAudience.NONE;
        };
    }

    public Optional<PushPayload> build(NotificationCreatedEvent event) {
        if (event == null || audienceFor(event.eventType()) == PushAudience.NONE) {
            return Optional.empty();
        }

        PushPayload payload = new PushPayload();
        payload.setTitle(title(event.eventType()));
        payload.setBody(event.message());
        payload.setIcon(Constants.PUSH_ICON);
        payload.setBadge(Constants.PUSH_ICON);
        // Agrupa los avisos del mismo objeto: tres cambios de un viaje muestran
        // una sola notificacion actualizada en vez de apilar tres.
        payload.setTag(event.eventType().toLowerCase() + "-" + event.referenceId());

        Map<String, Object> data = new HashMap<>();
        data.put("notificationId", event.notificationId());
        data.put("eventType", event.eventType());
        data.put("url", deepLink(event.eventType(), event.referenceId()));
        payload.setData(data);

        return Optional.of(payload);
    }

    private String title(String eventType) {
        return switch (eventType) {
            case Constants.TRIP_EVENT_TYPE -> "Viaje";
            case Constants.EXPENSE_EVENT_TYPE -> "Gasto registrado";
            case Constants.VEHICLE_EVENT_TYPE -> "Vehículo";
            case Constants.DRIVER_EVENT_TYPE -> "Conductor";
            case Constants.DOCUMENT_EXPIRY_EVENT_TYPE -> "Documento por vencer";
            case Constants.OWNER_EVENT_TYPE -> "Cuenta nueva";
            default -> "Aviso";
        };
    }

    /** Ruta real de la app: el basePath es /truck y las vistas cuelgan de /site. */
    private String deepLink(String eventType, Long referenceId) {
        return switch (eventType) {
            case Constants.TRIP_EVENT_TYPE -> Constants.PUSH_DEEP_LINK_BASE + "/trips/" + referenceId;
            case Constants.VEHICLE_EVENT_TYPE -> Constants.PUSH_DEEP_LINK_BASE + "/vehicles/" + referenceId;
            case Constants.DRIVER_EVENT_TYPE -> Constants.PUSH_DEEP_LINK_BASE + "/drivers/" + referenceId;
            // El listado de gastos no tiene vista de detalle por id.
            case Constants.EXPENSE_EVENT_TYPE -> Constants.PUSH_DEEP_LINK_BASE + "/expenses";
            // Al listado y no a la ficha del vehiculo: el referenceId de este
            // evento es el id del documento, no el del vehiculo, y cambiarlo
            // alteraria el reference_id que ya guardan las filas existentes.
            case Constants.DOCUMENT_EXPIRY_EVENT_TYPE -> Constants.PUSH_DEEP_LINK_BASE + "/vehicles";
            case Constants.OWNER_EVENT_TYPE -> Constants.PUSH_DEEP_LINK_BASE + "/owners/" + referenceId;
            default -> Constants.PUSH_DEEP_LINK_BASE + "/home";
        };
    }
}
