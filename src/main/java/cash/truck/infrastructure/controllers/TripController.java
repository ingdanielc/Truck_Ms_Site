package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.PartnerException;
import cash.truck.application.exception.RoutePayloadTooLargeException;
import cash.truck.application.exception.TripValidationException;
import cash.truck.application.usecases.TollUseCase;
import cash.truck.application.usecases.TripUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.domain.dtos.tolls.TollQuoteRequest;
import cash.truck.domain.dtos.tolls.TollQuoteResponse;
import cash.truck.domain.entities.Trip;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.NestedExceptionUtils;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/trip", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = { "http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/", "https://truck.ccsoluciones.com.co/" })
public class TripController {

    @Autowired
    private TripUseCase tripUseCase;

    @Autowired
    private TollUseCase tollUseCase;

    @GetMapping("/getAllTrips")
    public ResponseEntity<Object> getAllTrips() {
        ResponseMessage responseMessage = new ResponseMessage(tripUseCase.getAllTrips(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.TRIP_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping("/save")
    public ResponseEntity<Object> save(@RequestBody Trip trip) {
        try {
            Trip saved = tripUseCase.save(trip);
            ResponseMessage responseMessage = new ResponseMessage(saved, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.TRIP_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (TripValidationException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.BAD_REQUEST.value(),
                    e.getMessage(), Constants.TRIP_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.BAD_REQUEST);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    Constants.TRIP_SEARCH_NOT_FOUND_ME, Constants.TRIP_SEARCH_NOT_FOUND);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (PartnerException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.CONFLICT.value(),
                    e.getMessage(), Constants.TRIP_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.CONFLICT);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.TRIP_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/filter")
    public ResponseEntity<Object> filter(@RequestBody FilterRequest filterRequest) {
        try {
            Page<Trip> page = tripUseCase.findWithFilterOptional(filterRequest);
            ResponseMessage responseMessage = new ResponseMessage(page, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.TRIP_SEARCH_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.TRIP_SEARCH_KO),
                    HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Peajes de un trayecto y su costo para el vehiculo indicado.
     *
     * Es una consulta y no una mutacion —no toca el viaje ni deja rastro—, pero
     * va por POST porque el trazado de la ruta llega en el cuerpo: codificado
     * son decenas de miles de caracteres, muy por encima de lo que un servidor
     * acepta en una URL.
     *
     * El bloque route es opcional: si el cliente no consiguio trazado, el caso
     * de uso responde igual en modo CORRIDOR. Un trazado demasiado grande si se
     * rechaza, con 413, para que el cliente reintente sin el en lugar de
     * recibir una cotizacion a medias.
     */
    @PostMapping("/tolls")
    public ResponseEntity<Object> tolls(@RequestBody TollQuoteRequest tollQuoteRequest) {
        try {
            TollQuoteResponse quote = tollUseCase.quote(tollQuoteRequest);
            ResponseMessage responseMessage = new ResponseMessage(quote, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.TRIP_TOLLS_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (RoutePayloadTooLargeException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.PAYLOAD_TOO_LARGE.value(), e.getMessage(), Constants.TRIP_TOLLS_TOO_LARGE);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.PAYLOAD_TOO_LARGE);
        } catch (TripValidationException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.BAD_REQUEST.value(),
                    e.getMessage(), Constants.TRIP_TOLLS_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.BAD_REQUEST);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    Constants.VEHICLE_SEARCH_NOT_FOUND_ME, Constants.VEHICLE_SEARCH_NOT_FOUND);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.TRIP_TOLLS_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Cuerpo ilegible: cubre los valores fuera de enum de tripType y currentLeg,
     * que fallan al deserializar antes de llegar al caso de uso. Se devuelve el
     * mensaje de la causa raíz para que el front lo muestre tal cual.
     */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    public ResponseEntity<Object> handleNotReadable(HttpMessageNotReadableException e) {
        Throwable rootCause = NestedExceptionUtils.getMostSpecificCause(e);
        String message = rootCause.getMessage() != null ? rootCause.getMessage() : HttpStatus.BAD_REQUEST.name();
        return new ResponseEntity<>(
                new ResponseErrorMessage(HttpStatus.BAD_REQUEST.value(), message, Constants.TRIP_KO),
                HttpStatus.BAD_REQUEST);
    }
}
