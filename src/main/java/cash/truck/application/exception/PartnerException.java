package cash.truck.application.exception;

public class PartnerException extends RuntimeException {

    public PartnerException(String message) {
        super(message);
    }

    public static PartnerException duplicateEntityException() {
        return new PartnerException("An entity with the same unique identifier or email already exists.");
    }

    public static PartnerException notificationNoAvailable(int notificationType) {
        return new PartnerException(String.format("The notificationType %d is not available", notificationType));
    }

    public static PartnerException partnerNoExist() {
        return new PartnerException("The partner does not exist");
    }

    public static PartnerException moreThanOnePartner() {
        return new PartnerException("More than one partner found with the parameters");
    }

}
