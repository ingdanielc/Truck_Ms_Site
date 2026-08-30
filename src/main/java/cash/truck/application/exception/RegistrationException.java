package cash.truck.application.exception;

import cash.truck.application.utility.Constants;

/**
 * Error del registro publico de cuenta. Lleva el campo del formulario que lo
 * origino para que el front pueda pintarlo donde corresponde: el i18n se arma
 * como register.invalid.<campo> o register.duplicate.<campo>.
 */
public class RegistrationException extends RuntimeException {

    private final String field;
    private final boolean duplicate;

    private RegistrationException(String field, String message, boolean duplicate) {
        super(message);
        this.field = field;
        this.duplicate = duplicate;
    }

    /** Dato ausente o mal formado: se responde 400. */
    public static RegistrationException invalid(String field, String message) {
        return new RegistrationException(field, message, false);
    }

    /** El valor ya esta tomado por otra cuenta: se responde 409. */
    public static RegistrationException duplicated(String field, String message) {
        return new RegistrationException(field, message, true);
    }

    public String getField() {
        return field;
    }

    public boolean isDuplicate() {
        return duplicate;
    }

    public String getI18n() {
        return (duplicate ? Constants.REGISTER_DUPLICATE_PREFIX : Constants.REGISTER_INVALID_PREFIX) + field;
    }
}
