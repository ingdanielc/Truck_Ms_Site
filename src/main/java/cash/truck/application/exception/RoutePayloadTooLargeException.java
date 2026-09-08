package cash.truck.application.exception;

/**
 * El trazado enviado supera el tamano maximo aceptado por el endpoint de
 * peajes.
 *
 * Es una excepcion propia y no una validacion mas porque se traduce a 413 y no
 * a 400: el cliente no envio un dato invalido, envio uno correcto pero
 * demasiado grande, y la accion que le corresponde es distinta —reintentar sin
 * el trazado, no corregirlo—.
 */
public class RoutePayloadTooLargeException extends RuntimeException {

    public RoutePayloadTooLargeException(String message) {
        super(message);
    }
}
