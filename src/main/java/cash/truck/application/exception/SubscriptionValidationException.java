package cash.truck.application.exception;

/**
 * Error de validación al cotizar, registrar o revisar un pago de suscripción.
 * El mensaje se devuelve tal cual al cliente, igual que hace
 * PushValidationException con las suscripciones push.
 */
public class SubscriptionValidationException extends RuntimeException {

    public SubscriptionValidationException(String message) {
        super(message);
    }
}
