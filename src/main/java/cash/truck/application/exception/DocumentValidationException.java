package cash.truck.application.exception;

/**
 * Error de validación de reglas de negocio de un documento archivado.
 * El mensaje se devuelve tal cual al cliente (se muestra en el toast del front).
 */
public class DocumentValidationException extends RuntimeException {

    public DocumentValidationException(String message) {
        super(message);
    }
}
