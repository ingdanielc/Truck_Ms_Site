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

    // Notifications
    public static final String NOTIFICATION_SEARCH_KO = "notification.search.ko";
    public static final String NOTIFICATION_SEARCH_OK = "notification.search.ok";
}