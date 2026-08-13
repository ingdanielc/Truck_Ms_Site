package cash.truck.application.exception;

/**
 * Error de validación de reglas de negocio de un viaje.
 * El mensaje se devuelve tal cual al cliente (se muestra en el toast del front).
 */
public class TripValidationException extends RuntimeException {

    public TripValidationException(String message) {
        super(message);
    }
}
