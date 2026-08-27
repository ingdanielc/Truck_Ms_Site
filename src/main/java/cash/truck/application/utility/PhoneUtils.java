package cash.truck.application.utility;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

/**
 * Los celulares se capturan sin indicativo (3147235739) pero Twilio exige
 * formato E.164 (+573147235739). Aqui vive esa conversion, compartida por la
 * recuperacion de contrasena y por las notificaciones a propietarios.
 */
public class PhoneUtils {

    private PhoneUtils() {
        throw new IllegalStateException("Utility class");
    }

    /** Deja el celular como lo pide Twilio: +57 seguido del numero local. */
    public static String toE164(String phone) {
        if (phone == null || phone.isBlank()) {
            return null;
        }
        String clean = phone.replaceAll("[^0-9+]", "");
        if (clean.startsWith("+")) {
            return clean;
        }
        if (clean.startsWith(Constants.COUNTRY_CODE_CO) && clean.length() > Constants.PHONE_LOCAL_LENGTH) {
            return "+" + clean;
        }
        return "+" + Constants.COUNTRY_CODE_CO + clean;
    }

    /**
     * Todas las formas en que un mismo celular pudo quedar guardado, para poder
     * buscarlo sin depender de como lo escribieron.
     */
    public static List<String> candidates(String phone) {
        Set<String> candidates = new LinkedHashSet<>();
        if (phone == null) {
            return new ArrayList<>(candidates);
        }

        String digits = phone.replaceAll("[^0-9]", "");
        if (digits.startsWith(Constants.COUNTRY_CODE_CO) && digits.length() > Constants.PHONE_LOCAL_LENGTH) {
            digits = digits.substring(Constants.COUNTRY_CODE_CO.length());
        }

        candidates.add(digits);
        candidates.add(Constants.COUNTRY_CODE_CO + digits);
        candidates.add("+" + Constants.COUNTRY_CODE_CO + digits);
        candidates.add(phone.trim());
        return new ArrayList<>(candidates);
    }

    /** Oculta el celular dejando visibles los ultimos cuatro digitos. */
    public static String mask(String phone) {
        if (phone == null || phone.length() <= 4) {
            return phone;
        }
        return "*".repeat(phone.length() - 4) + phone.substring(phone.length() - 4);
    }
}
