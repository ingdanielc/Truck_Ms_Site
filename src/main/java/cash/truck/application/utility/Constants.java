package cash.truck.application.utility;

public class Constants {

    private Constants() {
        throw new IllegalStateException("Utility class");
    }

    public static final String STATUS_ACTIVE = "Active";
    public static final String STATUS_INACTIVE = "Inactive";

    public static final String STATUS_COMPLETED = "Completed";
    public static final String STATUS_PENDING = "Pending";

    public static final String DOCUMENT_TYPES_SEARCH_OK = "document_types.search.ok";
    public static final String GENDERS_SEARCH_OK = "genders.search.ok";
    public static final String CITIES_SEARCH_OK = "cities.search.ok";
    public static final String EXPIRES_SEARCH_OK = "expires.search.ok";

    public static final String PARTNER_SEARCH_OK = "partner.search.ok";
    public static final String PARTNER_SEARCH_NOT_FOUND = "partner.search.not.found";
    public static final String PARTNER_SEARCH_NOT_FOUND_ME = "Partner Not Found";
    public static final String PARTNER_CREATED_OK = "partner.created.ok";
    public static final String PARTNER_SEARCH_KO = "partner.search.ko";
    public static final String PARTNER_KO = "partner.ko";

    public static final String MEMBERSHIP_SEARCH_OK = "membership.search.ok";
    public static final String MEMBERSHIP_SEARCH_NOT_FOUND = "membership.search.not.found";
    public static final String MEMBERSHIP_SEARCH_NOT_FOUND_ME = "Membership Not Found";
    public static final String MEMBERSHIP_CREATED_OK = "membership.created.ok";
    public static final String MEMBERSHIP_SEARCH_KO = "membership.search.ko";
    public static final String MEMBERSHIP_KO = "membership.ko";
    public static final String MEMBERSHIP_TYPES_SEARCH_OK = "membership_types.search.ok";

    public static final String PARTNER_MEMBERSHIP_SEARCH_OK = "membership.search.ok";
    public static final String PARTNER_MEMBERSHIP_SEARCH_NOT_FOUND = "membership.search.not.found";
    public static final String PARTNER_MEMBERSHIP_SEARCH_NOT_FOUND_ME = "Membership Not Found";
    public static final String PARTNER_MEMBERSHIP_CREATED_OK = "membership.created.ok";
    public static final String PARTNER_MEMBERSHIP_SEARCH_KO = "membership.search.ko";
    public static final String PARTNER_MEMBERSHIP_KO = "membership.ko";

    public static final String PAYMENTS_SEARCH_OK = "payments.search.ok";
    public static final String PAYMENT_SEARCH_NOT_FOUND = "payment.search.not.found";
    public static final String PAYMENT_SEARCH_NOT_FOUND_ME = "Payment Not Found";
    public static final String PAYMENT_CREATED_OK = "payment.created.ok";
    public static final String PAYMENT_SEARCH_KO = "payment.search.ko";
    public static final String PAYMENT_KO = "payment.ko";
    public static final String PAYMENT_METHODS_SEARCH_OK = "payment_methods.search.ok";

    public static final String ACCESS_CONTROL_SEARCH_OK = "access_control.search.ok";
    public static final String ACCESS_CONTROL_SEARCH_NOT_FOUND = "access_control.search.not.found";
    public static final String ACCESS_CONTROL_SEARCH_NOT_FOUND_ME = "Access control Not Found";
    public static final String ACCESS_CONTROL_CREATED_OK = "access_control.created.ok";
    public static final String ACCESS_CONTROL_SEARCH_KO = "access_control.search.ko";
    public static final String ACCESS_CONTROL_KO = "access_control.ko";

    // Security
    public static final String USERS_SEARCH_OK = "users.search.ok";
    public static final String USER_SEARCH_NOT_FOUND = "user.search.not.found";
    public static final String USER_SEARCH_NOT_FOUND_ME = "User Not Found";
    public static final String USER_CREATED_OK = "user.created.ok";
    public static final String USER_SEARCH_KO = "user.search.ko";
    public static final String USER_KO = "user.ko";

    public static final String ROLES_SEARCH_OK = "roles.search.ok";

    //Setup Variables
    public static final String PARAMETER_OK = "OK";
    public static final String PARAMETER_INVALID_USER = "The Username is not valid";

    public static final String PARAMETER_INVALID_LOGIN = "Invalid username or password";
    public static final String PARAMETER_INVALID_KEY = "INVALID KEY";
    public static final String PARAMETER_AUTHORIZED = "authorized";

    public static final String PARAMETER_ID = "id";
    public static final String PARAMETER_EMAIL = "email";
    public static final String PARAMETER_NAME = "name";
    public static final String PARAMETER_JWT = "jwt";
    public static final String PARAMETER_AUTHORIZED_TOKEN = "AUTHORIZED_TOKEN";

    // Notifications
    public static final String NOTIFICATION_SEARCH_KO = "notification.search.ko";
    public static final String NOTIFICATION_SEARCH_OK = "notification.search.ok";
}