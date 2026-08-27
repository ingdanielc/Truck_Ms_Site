package cash.truck.application.utility;

public class Constants {

    private Constants() {
        throw new IllegalStateException("Utility class");
    }

    public static final String STATUS_ACTIVE = "Activo";
    public static final String STATUS_INACTIVE = "Inactivo";

    public static final String STATUS_COMPLETED = "Completed";
    public static final String STATUS_PENDING = "Pending";

    public static final String DOCUMENT_TYPES_SEARCH_OK = "document_types.search.ok";
    public static final String GENDERS_SEARCH_OK = "genders.search.ok";
    public static final String CITIES_SEARCH_OK = "cities.search.ok";
    public static final String EXPENSE_TYPES_SEARCH_OK = "expense_types.search.ok";
    public static final String VEHICLE_BRANDS_SEARCH_OK = "vehicle_brands.search.ok";
    public static final String SALARY_TYPES_SEARCH_OK = "salary_types.search.ok";

    public static final String OWNER_SEARCH_OK = "owner.search.ok";
    public static final String OWNER_SEARCH_NOT_FOUND = "owner.search.not.found";
    public static final String OWNER_SEARCH_NOT_FOUND_ME = "Owner Not Found";
    public static final String OWNER_CREATED_OK = "owner.created.ok";
    public static final String OWNER_SEARCH_KO = "owner.search.ko";
    public static final String OWNER_KO = "owner.ko";

    public static final String VEHICLE_SEARCH_OK = "vehicle.search.ok";
    public static final String VEHICLE_SEARCH_NOT_FOUND = "vehicle.search.not.found";
    public static final String VEHICLE_SEARCH_NOT_FOUND_ME = "Vehicle Not Found";
    public static final String VEHICLE_CREATED_OK = "vehicle.created.ok";
    public static final String VEHICLE_SEARCH_KO = "vehicle.search.ko";
    public static final String VEHICLE_KO = "vehicle.ko";

    public static final String TRIP_SEARCH_OK = "trip.search.ok";
    public static final String TRIP_SEARCH_NOT_FOUND = "trip.search.not.found";
    public static final String TRIP_SEARCH_NOT_FOUND_ME = "Trip Not Found";
    public static final String TRIP_CREATED_OK = "trip.created.ok";
    public static final String TRIP_SEARCH_KO = "trip.search.ko";
    public static final String TRIP_KO = "trip.ko";

    public static final String EXPENSE_SEARCH_OK = "expense.search.ok";
    public static final String EXPENSE_SEARCH_NOT_FOUND = "expense.search.not.found";
    public static final String EXPENSE_SEARCH_NOT_FOUND_ME = "Expense Not Found";
    public static final String EXPENSE_CREATED_OK = "expense.created.ok";
    public static final String EXPENSE_SEARCH_KO = "expense.search.ko";
    public static final String EXPENSE_KO = "expense.ko";
    public static final String EXPENSE_CATEGORY_SEARCH_OK = "expense_category.search.ok";
    public static final String EXPENSE_CATEGORY_SEARCH_NOT_FOUND = "expense_category.search.not.found";
    public static final String EXPENSE_CATEGORY_SEARCH_NOT_FOUND_ME = "Expense Category Not Found";
    public static final String EXPENSE_CATEGORY_CREATED_OK = "expense_category.created.ok";
    public static final String EXPENSE_CATEGORY_KO = "expense_category.ko";

    public static final String PARTNER_SEARCH_KO = "partner.search.ko";

    // Security
    public static final String USERS_SEARCH_OK = "users.search.ok";
    public static final String USER_SEARCH_NOT_FOUND = "user.search.not.found";
    public static final String USER_SEARCH_NOT_FOUND_ME = "User Not Found";
    public static final String USER_CREATED_OK = "user.created.ok";
    public static final String USER_SEARCH_KO = "user.search.ko";
    public static final String USER_KO = "user.ko";

    public static final String ROLES_SEARCH_OK = "roles.search.ok";

    // Setup Variables
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
    public static final String PARAMETER_CODE = "code";

    // Subscription
    public static final String HEADER_USER_ID = "X-USER-ID";
    public static final String ZONE_BOGOTA = "America/Bogota";
    public static final Integer ROLE_ID_ADMIN = 1;
    public static final String ROLE_NAME_ADMIN = "ADMINISTRADOR";
    public static final int SUBSCRIPTION_DEFAULT_MONTHS = 12;
    public static final String SUBSCRIPTION_EXPIRED_CODE = "SUBSCRIPTION_EXPIRED";
    public static final String SUBSCRIPTION_EXPIRED_MESSAGE = "La suscripción finalizó, debe contactar al administrador por WhatsApp.";

    // Notifications
    public static final String NOTIFICATION_SEARCH_KO = "notification.search.ko";
    public static final String NOTIFICATION_SEARCH_OK = "notification.search.ok";

    // Photo Upload
    public static final String PHOTO_UPLOAD_OK = "photo.upload.ok";
    public static final String PHOTO_UPLOAD_KO = "photo.upload.ko";

    // Password Reset
    public static final String PASSWORD_RESET_MESSAGE_TYPE = "PASSWORD_RECOVERY";
    public static final String COUNTRY_CODE_CO = "57";
    public static final int PHONE_LOCAL_LENGTH = 10;
    // El front envia la contrasena ya cifrada en SHA-512, igual que en el login.
    public static final String PASSWORD_HASH_PATTERN = "(?i)^[0-9a-f]{128}$";
    public static final int PASSWORD_RESET_CODE_LENGTH = 6;
    public static final int PASSWORD_RESET_CODE_MINUTES = 10;
    public static final int PASSWORD_RESET_TOKEN_MINUTES = 15;
    public static final int PASSWORD_RESET_MAX_ATTEMPTS = 5;

    public static final String PASSWORD_RESET_PHONE_REQUIRED = "Debe indicar el numero de celular.";
    public static final String PASSWORD_RESET_PHONE_NOT_FOUND = "No hay un usuario registrado con ese numero de celular.";
    public static final String PASSWORD_RESET_CODE_REQUIRED = "Debe indicar el celular y el codigo de verificacion.";
    public static final String PASSWORD_RESET_NO_REQUEST = "No hay una solicitud de recuperacion vigente para ese celular.";
    public static final String PASSWORD_RESET_CODE_EXPIRED = "El codigo expiro, solicite uno nuevo.";
    public static final String PASSWORD_RESET_CODE_INVALID = "El codigo ingresado no es valido.";
    public static final String PASSWORD_RESET_MAX_ATTEMPTS_REACHED = "Se supero el numero de intentos permitidos, solicite un codigo nuevo.";
    public static final String PASSWORD_RESET_TOKEN_REQUIRED = "Debe indicar el token de recuperacion.";
    public static final String PASSWORD_RESET_TOKEN_INVALID = "El token de recuperacion no es valido o ya fue utilizado.";
    public static final String PASSWORD_RESET_TOKEN_EXPIRED = "El token de recuperacion expiro, solicite un codigo nuevo.";
    public static final String PASSWORD_RESET_PASSWORD_INVALID = "La contrasena debe llegar cifrada en SHA-512.";

    public static final String PASSWORD_RESET_SENT_OK = "password.reset.sent.ok";
    public static final String PASSWORD_RESET_VERIFIED_OK = "password.reset.verified.ok";
    public static final String PASSWORD_RESET_CHANGED_OK = "password.reset.changed.ok";
    public static final String PASSWORD_RESET_NOT_FOUND = "password.reset.not.found";
    public static final String PASSWORD_RESET_KO = "password.reset.ko";
}
