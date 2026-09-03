package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.PushValidationException;
import cash.truck.application.usecases.push.PushSubscriptionUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.domain.dtos.PushSubscriptionRequest;
import cash.truck.domain.entities.PushSubscription;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * Alta y baja de dispositivos para las notificaciones push.
 *
 * El usuario se toma del header X-USER-ID y no del cuerpo. Conviene tener
 * presente que ese header hoy no lo verifica nadie —CustomHeaderAuthFilter solo
 * valida la X-API-KEY, que ademas es una sola para todos—, asi que quien tenga
 * la llave puede suscribir dispositivos a nombre de otro. Endurecerlo es una
 * decision pendiente que excede a este controlador.
 */
@RestController
@RequestMapping(value = "/push", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = { "http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/",
        "https://truck.ccsoluciones.com.co/" })
public class PushController {

    private final PushSubscriptionUseCase pushSubscriptionUseCase;
    private final String vapidPublicKey;

    public PushController(PushSubscriptionUseCase pushSubscriptionUseCase,
                          @Qualifier("vapidPublicKey") String vapidPublicKey) {
        this.pushSubscriptionUseCase = pushSubscriptionUseCase;
        this.vapidPublicKey = vapidPublicKey;
    }

    /**
     * La llave publica con la que el navegador crea la suscripcion. Se sirve
     * desde aqui y no desde el environment del front para poder rotarla sin
     * volver a construir el frontend.
     */
    @GetMapping("/public-key")
    public ResponseEntity<Object> publicKey() {
        if (vapidPublicKey == null || vapidPublicKey.isBlank()) {
            // 503 y no 500: no es un fallo, es que el push no esta configurado
            // en este entorno. El front debe saber no ofrecer la suscripcion.
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.SERVICE_UNAVAILABLE.value(), HttpStatus.SERVICE_UNAVAILABLE.name(),
                    Constants.PUSH_DISABLED);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.SERVICE_UNAVAILABLE);
        }

        ResponseMessage responseMessage = new ResponseMessage(vapidPublicKey, HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.PUSH_PUBLIC_KEY_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping("/subscribe")
    public ResponseEntity<Object> subscribe(
            @RequestHeader(value = Constants.HEADER_USER_ID, required = false) Integer userId,
            @RequestBody PushSubscriptionRequest request) {
        try {
            PushSubscription saved = pushSubscriptionUseCase.subscribe(userId, request);
            ResponseMessage responseMessage = new ResponseMessage(Map.of(Constants.PARAMETER_ID, saved.getId()),
                    HttpStatus.OK.value(), HttpStatus.OK.name(), null, Constants.PUSH_SUBSCRIBED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (PushValidationException e) {
            return badRequest(e.getMessage());
        } catch (EntityNotFoundException e) {
            return notFound(e.getMessage());
        } catch (Exception e) {
            return serverError();
        }
    }

    @PostMapping("/unsubscribe")
    public ResponseEntity<Object> unsubscribe(@RequestBody PushSubscriptionRequest request) {
        try {
            pushSubscriptionUseCase.unsubscribe(request == null ? null : request.getEndpoint());
            ResponseMessage responseMessage = new ResponseMessage(true, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.PUSH_UNSUBSCRIBED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (PushValidationException e) {
            return badRequest(e.getMessage());
        } catch (EntityNotFoundException e) {
            return notFound(e.getMessage());
        } catch (Exception e) {
            return serverError();
        }
    }

    private ResponseEntity<Object> badRequest(String message) {
        return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.BAD_REQUEST.value(), message,
                Constants.PUSH_KO), HttpStatus.BAD_REQUEST);
    }

    private ResponseEntity<Object> notFound(String message) {
        return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(), message,
                Constants.PUSH_KO), HttpStatus.NOT_FOUND);
    }

    private ResponseEntity<Object> serverError() {
        return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.PUSH_KO), HttpStatus.INTERNAL_SERVER_ERROR);
    }
}
