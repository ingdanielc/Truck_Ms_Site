package cash.truck.application.exception;

public class MembershipException extends RuntimeException {

    public MembershipException(String message) {
        super(message);
    }

    public static MembershipException duplicateEntityException() {
        return new MembershipException("A membership with the same name and membership type already exists.");
    }

    public static MembershipException membershipNoExist() {
        return new MembershipException("The membership does not exist");
    }

    public static MembershipException moreThanOneMembership() {
        return new MembershipException("More than one membership found with the parameters");
    }

}
