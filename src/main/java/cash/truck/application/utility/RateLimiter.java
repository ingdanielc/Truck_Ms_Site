package cash.truck.application.utility;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.stereotype.Component;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Limitador de uso por IP con ventana fija, en memoria. Protege los dos
 * endpoints publicos del registro (alta y validador de disponibilidad) de que
 * alguien los use para enumerar documentos o celulares.
 *
 * El conteo vive en la instancia: si manana la aplicacion corre en varios
 * nodos, el limite efectivo se multiplica por el numero de nodos. Es una
 * mitigacion, no una garantia; si se necesita mas, el lugar correcto es el
 * proxy que expone la API.
 */
@Component
public class RateLimiter {

    /** Techo de IPs vigiladas a la vez; al superarlo se purgan las ventanas vencidas. */
    private static final int MAX_TRACKED_KEYS = 10000;
    private static final String FORWARDED_FOR = "X-Forwarded-For";

    private final Map<String, Window> windows = new ConcurrentHashMap<>();

    /**
     * @return true si la peticion cabe en la ventana actual; false cuando ya se
     *         agoto el cupo y hay que responder 429.
     */
    public boolean tryAcquire(String bucket, String clientIp, int limit, int windowSeconds) {
        long now = System.currentTimeMillis();
        long windowMillis = windowSeconds * 1000L;

        if (windows.size() > MAX_TRACKED_KEYS) {
            windows.values().removeIf(window -> window.isExpired(now, windowMillis));
        }

        Window window = windows.computeIfAbsent(bucket + "|" + clientIp, key -> new Window(now));
        synchronized (window) {
            if (window.isExpired(now, windowMillis)) {
                window.startedAt = now;
                window.count = 0;
            }
            window.count++;
            return window.count <= limit;
        }
    }

    /**
     * La aplicacion se sirve detras de un proxy, asi que getRemoteAddr devuelve
     * la IP del proxy. El primer valor de X-Forwarded-For es el cliente real.
     */
    public static String clientIp(HttpServletRequest request) {
        if (request == null) {
            return "unknown";
        }
        String forwarded = request.getHeader(FORWARDED_FOR);
        if (forwarded != null && !forwarded.isBlank()) {
            return forwarded.split(",")[0].trim();
        }
        String remote = request.getRemoteAddr();
        return remote == null ? "unknown" : remote;
    }

    private static final class Window {
        private long startedAt;
        private int count;

        private Window(long startedAt) {
            this.startedAt = startedAt;
        }

        private boolean isExpired(long now, long windowMillis) {
            return now - startedAt >= windowMillis;
        }
    }
}
