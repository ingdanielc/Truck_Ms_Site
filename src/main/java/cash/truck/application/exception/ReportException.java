package cash.truck.application.exception;

import org.springframework.http.HttpStatus;

/**
 * Falla de un reporte. Lleva el estado consigo porque los tres motivos —sin
 * identidad, parametro invalido y grupo fuera de alcance— se distinguen solo
 * por el codigo y el controlador no tiene como deducirlo del mensaje.
 */
public class ReportException extends RuntimeException {

    private final transient HttpStatus status;

    public ReportException(HttpStatus status, String message) {
        super(message);
        this.status = status;
    }

    public HttpStatus getStatus() {
        return status;
    }

    public static ReportException unresolvedCaller() {
        return new ReportException(HttpStatus.UNAUTHORIZED,
                "No se pudo resolver la identidad de quien consulta el reporte.");
    }

    public static ReportException invalidParameter(String message) {
        return new ReportException(HttpStatus.BAD_REQUEST, message);
    }

    public static ReportException groupOutOfScope(String key) {
        return new ReportException(HttpStatus.FORBIDDEN,
                String.format("El grupo '%s' esta fuera del alcance de quien consulta.", key));
    }
}
