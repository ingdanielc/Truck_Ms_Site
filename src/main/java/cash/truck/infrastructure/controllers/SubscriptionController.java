package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.SubscriptionValidationException;
import cash.truck.application.usecases.SubscriptionUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.domain.dtos.SubscriptionPaymentRequest;
import cash.truck.domain.dtos.SubscriptionQuoteDTO;
import cash.truck.domain.entities.SubscriptionPayment;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Renovacion de la suscripcion, con comprobacion manual del pago.
 *
 * El recorrido son cuatro llamadas y en este orden: el propietario consulta
 * cuanto debe, sube el comprobante por /common/upload-document, registra el
 * pago con la URL que aquel devolvio, y un administrador lo confirma o lo
 * rechaza. La fecha de suscripcion solo se mueve en la confirmacion.
 *
 * El revisor se toma del header X-USER-ID, igual que en el controlador de push.
 * Vale la misma advertencia: hoy ese header no lo verifica nadie, asi que el
 * control de quien puede confirmar un pago sigue siendo del front. Endurecerlo
 * excede a este controlador, pero aqui pesa mas que en otros sitios porque la
 * operacion mueve dinero.
 */
@RestController
@RequestMapping(value = "/subscription", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = { "http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/",
        "https://truck.ccsoluciones.com.co/" })
public class SubscriptionController {

    private final SubscriptionUseCase subscriptionUseCase;

    public SubscriptionController(SubscriptionUseCase subscriptionUseCase) {
        this.subscriptionUseCase = subscriptionUseCase;
    }

    /**
     * Cuanto debe pagar el propietario, ya desglosado en las lineas de la
     * tabla. Es de solo lectura: consultarlo no compromete a nada.
     *
     * years es cuantas anualidades quiere comprar de una vez; omitirlo cotiza
     * una. No se aceptan periodos menores a un ano.
     */
    @GetMapping("/quote/{ownerId}")
    public ResponseEntity<Object> quote(@PathVariable Long ownerId,
            @RequestParam(value = "years", required = false) Integer years) {
        try {
            SubscriptionQuoteDTO quote = subscriptionUseCase.quote(ownerId, years);
            return ok(quote, Constants.SUBSCRIPTION_QUOTE_OK);
        } catch (SubscriptionValidationException e) {
            return error(HttpStatus.BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            return error(HttpStatus.INTERNAL_SERVER_ERROR, Constants.SUBSCRIPTION_KO);
        }
    }

    /**
     * El propietario declara que ya pago y adjunta el comprobante. Devuelve
     * 201 porque crea una fila nueva, que queda esperando comprobacion.
     */
    @PostMapping("/payment")
    public ResponseEntity<Object> registerPayment(@RequestBody SubscriptionPaymentRequest request) {
        try {
            SubscriptionPayment saved = subscriptionUseCase.registerPayment(request);
            ResponseMessage responseMessage = new ResponseMessage(saved, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.SUBSCRIPTION_PAYMENT_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (SubscriptionValidationException e) {
            return error(HttpStatus.BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            return error(HttpStatus.INTERNAL_SERVER_ERROR, Constants.SUBSCRIPTION_KO);
        }
    }

    /**
     * El administrador confirma el pago: corre la fecha de suscripcion y
     * dispara el WhatsApp de renovacion al propietario.
     */
    @PostMapping("/payment/{paymentId}/confirm")
    public ResponseEntity<Object> confirmPayment(@PathVariable Long paymentId,
            @RequestHeader(value = Constants.HEADER_USER_ID, required = false) Integer reviewerUserId) {
        try {
            SubscriptionPayment saved = subscriptionUseCase.confirmPayment(paymentId, reviewerUserId);
            return ok(saved, Constants.SUBSCRIPTION_CONFIRMED_OK);
        } catch (SubscriptionValidationException e) {
            return error(HttpStatus.BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            return error(HttpStatus.INTERNAL_SERVER_ERROR, Constants.SUBSCRIPTION_KO);
        }
    }

    /** El administrador no encontro el dinero. El motivo es obligatorio. */
    @PostMapping("/payment/{paymentId}/reject")
    public ResponseEntity<Object> rejectPayment(@PathVariable Long paymentId,
            @RequestHeader(value = Constants.HEADER_USER_ID, required = false) Integer reviewerUserId,
            @RequestBody Map<String, String> body) {
        try {
            String reason = body == null ? null : body.get("reason");
            SubscriptionPayment saved = subscriptionUseCase.rejectPayment(paymentId, reviewerUserId, reason);
            return ok(saved, Constants.SUBSCRIPTION_REJECTED_OK);
        } catch (SubscriptionValidationException e) {
            return error(HttpStatus.BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            return error(HttpStatus.INTERNAL_SERVER_ERROR, Constants.SUBSCRIPTION_KO);
        }
    }

    /** Historico del propietario: en que quedo cada intento de renovacion. */
    @GetMapping("/payments/owner/{ownerId}")
    public ResponseEntity<Object> paymentsByOwner(@PathVariable Long ownerId) {
        try {
            List<SubscriptionPayment> payments = subscriptionUseCase.findByOwner(ownerId);
            return ok(payments, Constants.SUBSCRIPTION_PAYMENTS_OK);
        } catch (Exception e) {
            return error(HttpStatus.INTERNAL_SERVER_ERROR, Constants.SUBSCRIPTION_KO);
        }
    }

    /** Bandeja del administrador: los pagos que esperan comprobacion. */
    @GetMapping("/payments/pending")
    public ResponseEntity<Object> pendingPayments() {
        try {
            List<SubscriptionPayment> payments = subscriptionUseCase.findPending();
            return ok(payments, Constants.SUBSCRIPTION_PAYMENTS_OK);
        } catch (Exception e) {
            return error(HttpStatus.INTERNAL_SERVER_ERROR, Constants.SUBSCRIPTION_KO);
        }
    }

    private ResponseEntity<Object> ok(Object data, String i18n) {
        ResponseMessage responseMessage = new ResponseMessage(data, HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, i18n);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    private ResponseEntity<Object> error(HttpStatus status, String message) {
        ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(status.value(), status.name(),
                message);
        return new ResponseEntity<>(responseErrorMessage, status);
    }
}
