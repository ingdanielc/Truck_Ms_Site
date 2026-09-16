package cash.truck.push;

import cash.truck.application.usecases.push.PushAudience;
import cash.truck.application.usecases.push.PushPayloadFactory;
import cash.truck.domain.dtos.NotificationCreatedEvent;
import cash.truck.domain.dtos.PushPayload;
import cash.truck.domain.repositories.DocumentFileRepository;
import org.junit.jupiter.api.Test;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

/**
 * Fija la matriz de canales: que evento sale por push y a que pantalla lleva.
 *
 * Importa sobre todo lo que NO sale. Que el vencimiento de documento se quede
 * en la bandeja interna es una decision de negocio, no un olvido, y sin una
 * prueba que lo sostenga es justo el tipo de regla que alguien "arregla" mas
 * adelante creyendo que falta un caso.
 */
class PushPayloadFactoryTest {

    private final DocumentFileRepository documentFileRepository = mock(DocumentFileRepository.class);
    private final PushPayloadFactory factory = new PushPayloadFactory(documentFileRepository);

    private NotificationCreatedEvent event(String eventType) {
        return new NotificationCreatedEvent(99L, eventType, "Mensaje de prueba", 7L, 1234L, null);
    }

    @Test
    void elVencimientoDeDocumentoVaAlPropietario() {
        // Sigue sin salir por WhatsApp; el push si, por decision posterior.
        assertEquals(PushAudience.OWNER, factory.audienceFor("DOCUMENT_EVENT"));
        when(documentFileRepository.existsByIdAndVehicleIdIsNotNull(1234L)).thenReturn(true);

        PushPayload payload = factory.build(event("DOCUMENT_EVENT")).orElseThrow();
        assertEquals("Documento por vencer", payload.getTitle());
        // Al listado y no a la ficha: el referenceId aqui es el id del
        // documento, no el del vehiculo.
        assertEquals("/truck/site/vehicles", payload.getData().get("url"));
    }

    @Test
    void elVencimientoDeDocumentoDeConductorOPropietarioLlevaAlInicio() {
        when(documentFileRepository.existsByIdAndVehicleIdIsNotNull(1234L)).thenReturn(false);

        assertEquals("/truck/site/home",
                factory.build(event("DOCUMENT_EVENT")).orElseThrow().getData().get("url"));
    }

    @Test
    void laCuentaNuevaVaAlAdministrador() {
        // Se guarda sin owner_id porque el destinatario no es el propietario
        // recien creado, sino quien administra.
        assertEquals(PushAudience.ADMIN, factory.audienceFor("OWNER_EVENT"));
        assertEquals("Cuenta nueva", factory.build(event("OWNER_EVENT")).orElseThrow().getTitle());
    }

    @Test
    void elViajeSalePorPushConSuEnlaceProfundo() {
        PushPayload payload = factory.build(event("TRIP_EVENT")).orElseThrow();

        assertEquals("Viaje", payload.getTitle());
        assertEquals("Mensaje de prueba", payload.getBody());
        assertEquals("/truck/site/trips/1234", payload.getData().get("url"));
        assertEquals(99L, payload.getData().get("notificationId"));
        assertEquals("trip_event-1234", payload.getTag());
    }

    @Test
    void elConductorYElVehiculoLlevanASuFicha() {
        assertEquals("/truck/site/drivers/1234",
                factory.build(event("DRIVER_EVENT")).orElseThrow().getData().get("url"));
        assertEquals("/truck/site/vehicles/1234",
                factory.build(event("VEHICLE_EVENT")).orElseThrow().getData().get("url"));
    }

    @Test
    void elGastoLlevaAlListadoPorqueNoTieneDetalle() {
        assertEquals("/truck/site/expenses",
                factory.build(event("EXPENSE_EVENT")).orElseThrow().getData().get("url"));
    }

    @Test
    void unEventoDesconocidoNoSalePorPush() {
        assertEquals(PushAudience.NONE, factory.audienceFor("ALGO_NUEVO"));
        assertEquals(Optional.empty(), factory.build(event("ALGO_NUEVO")));
        assertEquals(Optional.empty(), factory.build(null));
        assertEquals(PushAudience.NONE, factory.audienceFor(null));
    }

    @Test
    void losAvisosProgramadosSalenPorPushConSuTituloYEnlace() {
        assertEquals("¡Feliz cumpleaños!", factory.build(event("BIRTHDAY_EVENT")).orElseThrow().getTitle());
        assertEquals("/truck/site/home",
                factory.build(event("BIRTHDAY_EVENT")).orElseThrow().getData().get("url"));

        assertEquals("Suscripción por vencer",
                factory.build(event("SUBSCRIPTION_EXPIRATION")).orElseThrow().getTitle());

        PushPayload balance = factory.build(event("PENDING_BALANCE_ALERT")).orElseThrow();
        assertEquals("Saldo pendiente de cobro", balance.getTitle());
        assertEquals("/truck/site/trips/1234", balance.getData().get("url"));

        // El seguimiento de cartera para el administrador se retiro.
        assertEquals(PushAudience.NONE, factory.audienceFor("PORTFOLIO_ALERT"));
    }

    @Test
    void losEventosDelPropietarioVanAlPropietario() {
        for (String eventType : new String[] { "TRIP_EVENT", "EXPENSE_EVENT", "VEHICLE_EVENT", "DRIVER_EVENT" }) {
            assertEquals(PushAudience.OWNER, factory.audienceFor(eventType), eventType);
        }
    }
}
