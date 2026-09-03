package cash.truck.application.exception;

/**
 * Error de validación de una suscripción push. El mensaje se devuelve tal cual
 * al cliente, igual que hace DocumentValidationException con los documentos.
 */
public class PushValidationException extends RuntimeException {

    public PushValidationException(String message) {
        super(message);
    }
}
