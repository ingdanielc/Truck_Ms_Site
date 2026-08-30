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

    // Notificaciones al propietario
    public static final String APP_URL_DEFAULT = "https://truck.ccsoluciones.com.co";
    public static final String WELCOME_OWNER_MESSAGE_TYPE = "WELCOME_OWNER";
    public static final String WELCOME_OWNER_DRIVER_MESSAGE_TYPE = "WELCOME_OWNER_DRIVER";
    public static final String SUBSCRIPTION_REMINDER_MESSAGE_TYPE = "SUBSCRIPTION_REMINDER";
    /** Dias de antelacion con que se avisa el vencimiento de la suscripcion. */
    public static final int SUBSCRIPTION_REMINDER_DAYS = 3;
    /** Todos los dias a las 8:00 en Bogota. */
    public static final String SUBSCRIPTION_REMINDER_CRON = "0 0 8 * * *";

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

    public static final String PASSWORD_RESET_PHONE_REQUIRED = "Debe indicar el número de celular.";
    public static final String PASSWORD_RESET_PHONE_NOT_FOUND = "No hay un usuario registrado con ese número de celular.";
    public static final String PASSWORD_RESET_CODE_REQUIRED = "Debe indicar el celular y el código de verificación.";
    public static final String PASSWORD_RESET_NO_REQUEST = "No hay una solicitud de recuperación vigente para ese celular.";
    public static final String PASSWORD_RESET_CODE_EXPIRED = "El código expiró, solicite uno nuevo.";
    public static final String PASSWORD_RESET_CODE_INVALID = "El código ingresado no es válido.";
    public static final String PASSWORD_RESET_MAX_ATTEMPTS_REACHED = "Se superó el número de intentos permitidos, solicite un código nuevo.";
    public static final String PASSWORD_RESET_TOKEN_REQUIRED = "Debe indicar el token de recuperación.";
    public static final String PASSWORD_RESET_TOKEN_INVALID = "El token de recuperación no es válido o ya fue utilizado.";
    public static final String PASSWORD_RESET_TOKEN_EXPIRED = "El token de recuperación expiró, solicite un código nuevo.";
    public static final String PASSWORD_RESET_PASSWORD_INVALID = "La contraseña debe llegar cifrada en SHA-512.";

    public static final String PASSWORD_RESET_SENT_OK = "password.reset.sent.ok";
    public static final String PASSWORD_RESET_VERIFIED_OK = "password.reset.verified.ok";
    public static final String PASSWORD_RESET_CHANGED_OK = "password.reset.changed.ok";
    public static final String PASSWORD_RESET_NOT_FOUND = "password.reset.not.found";
    public static final String PASSWORD_RESET_KO = "password.reset.ko";

    // Registro publico de cuenta
    public static final String REGISTER_CREATED_OK = "register.created.ok";
    public static final String REGISTER_KO = "register.ko";
    /** Se completa con el campo en falta: register.invalid.email, register.invalid.cellPhone, ... */
    public static final String REGISTER_INVALID_PREFIX = "register.invalid.";
    /** Se completa con el campo duplicado: register.duplicate.documentNumber, ... */
    public static final String REGISTER_DUPLICATE_PREFIX = "register.duplicate.";
    public static final String REGISTER_RATE_LIMITED = "register.rate.limited";

    public static final String FIELD_DOCUMENT_NUMBER = "documentNumber";
    public static final String FIELD_EMAIL = "email";
    public static final String FIELD_CELL_PHONE = "cellPhone";
    public static final String FIELD_NAME = "name";
    public static final String FIELD_DOCUMENT_TYPE_ID = "documentTypeId";
    public static final String FIELD_PASSWORD = "password";
    public static final String FIELD_MAX_VEHICLES = "maxVehicles";
    public static final String FIELD_PAYLOAD = "payload";

    public static final String REGISTER_PAYLOAD_REQUIRED = "No se recibió información para el registro.";
    public static final String REGISTER_FIELD_REQUIRED = "El campo %s es obligatorio.";
    public static final String REGISTER_EMAIL_INVALID = "El correo electrónico no tiene un formato válido.";
    public static final String REGISTER_CELL_PHONE_INVALID = "El celular debe tener 10 dígitos.";
    public static final String REGISTER_PASSWORD_INVALID = "La contraseña debe llegar codificada en Base64.";
    public static final String REGISTER_MAX_VEHICLES_INVALID = "La cantidad de vehículos debe estar entre 1 y %d.";
    public static final String REGISTER_DUPLICATE_DOCUMENT_NUMBER = "Ya existe una cuenta con ese número de documento.";
    public static final String REGISTER_DUPLICATE_EMAIL = "Ya existe una cuenta con ese correo electrónico.";
    public static final String REGISTER_DUPLICATE_CELL_PHONE = "Ya existe una cuenta con ese número de celular.";
    public static final String REGISTER_RATE_LIMITED_MESSAGE = "Demasiados intentos de registro, espere unos minutos.";

    // Validador de disponibilidad
    public static final String AVAILABILITY_CHECK_OK = "availability.check.ok";
    public static final String AVAILABILITY_KO = "availability.ko";
    public static final String AVAILABILITY_RATE_LIMITED = "availability.rate.limited";
    public static final String AVAILABILITY_FIELD_INVALID = "El campo a validar debe ser documentNumber, email o cellPhone.";
    public static final String AVAILABILITY_VALUE_REQUIRED = "Debe indicar el valor a validar.";
    public static final String AVAILABILITY_RATE_LIMITED_MESSAGE = "Demasiadas consultas, espere unos segundos.";

    /** Ventanas de uso por IP: el registro se protege mas que el validador del formulario. */
    /** Techo del cupo de vehiculos que puede pedir el formulario de registro. */
    public static final int REGISTER_MAX_VEHICLES_LIMIT = 999;

    /** Vigencia con la que entra una cuenta creada desde el registro publico. */
    public static final int REGISTER_SUBSCRIPTION_MONTHS = 1;

    public static final String RATE_BUCKET_REGISTER = "register";
    public static final int REGISTER_RATE_LIMIT = 5;
    public static final int REGISTER_RATE_WINDOW_SECONDS = 600;
    public static final String RATE_BUCKET_AVAILABILITY = "availability";
    public static final int AVAILABILITY_RATE_LIMIT = 30;
    public static final int AVAILABILITY_RATE_WINDOW_SECONDS = 60;

    public static final String EMAIL_PATTERN = "^[^@ ]+@[^@ .]+[.][^@ ]{2,}$";
}
