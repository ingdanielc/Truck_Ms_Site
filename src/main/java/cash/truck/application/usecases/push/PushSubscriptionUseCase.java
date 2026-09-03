package cash.truck.application.usecases.push;

import cash.truck.application.exception.PushValidationException;
import cash.truck.application.utility.Constants;
import cash.truck.domain.dtos.PushSubscriptionRequest;
import cash.truck.domain.entities.PushSubscription;
import cash.truck.domain.repositories.PushSubscriptionRepository;
import cash.truck.domain.repositories.UsersRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Optional;

/**
 * Alta y baja de suscripciones push.
 *
 * El usuario se toma del header X-USER-ID y nunca del cuerpo, para que el
 * cliente no pueda suscribir a un tercero cambiando un campo del JSON.
 */
@Service
@Transactional
public class PushSubscriptionUseCase {

    private static final Logger logger = LoggerFactory.getLogger(PushSubscriptionUseCase.class);

    private final PushSubscriptionRepository pushSubscriptionRepository;
    private final UsersRepository usersRepository;

    public PushSubscriptionUseCase(PushSubscriptionRepository pushSubscriptionRepository,
                                   UsersRepository usersRepository) {
        this.pushSubscriptionRepository = pushSubscriptionRepository;
        this.usersRepository = usersRepository;
    }

    /**
     * Upsert por endpoint, no insert.
     *
     * El navegador reenvia la misma suscripcion en cada arranque, asi que
     * insertar a ciegas duplicaria filas hasta chocar contra el indice unico. Y
     * hay un caso real que solo el upsert resuelve: el celular que se presta
     * entre conductores. Ahi el endpoint es el mismo y el usuario cambia; la
     * fila se reasigna para que los avisos del anterior no le sigan llegando al
     * que entro.
     */
    public PushSubscription subscribe(Integer userId, PushSubscriptionRequest request) {
        if (userId == null) {
            throw new PushValidationException(Constants.PUSH_USER_REQUIRED);
        }
        if (request == null || isBlank(request.getEndpoint()) || request.getKeys() == null
                || isBlank(request.getKeys().getP256dh()) || isBlank(request.getKeys().getAuth())) {
            throw new PushValidationException(Constants.PUSH_INVALID_SUBSCRIPTION);
        }
        if (!usersRepository.existsById(userId)) {
            throw new EntityNotFoundException(Constants.PUSH_USER_NOT_FOUND);
        }

        String endpoint = request.getEndpoint().trim();
        String endpointHash = sha256(endpoint);

        PushSubscription subscription = pushSubscriptionRepository.findByEndpointHash(endpointHash)
                .orElseGet(PushSubscription::new);

        subscription.setUserId(userId);
        subscription.setEndpoint(endpoint);
        subscription.setEndpointHash(endpointHash);
        subscription.setP256dh(request.getKeys().getP256dh().trim());
        subscription.setAuth(request.getKeys().getAuth().trim());
        subscription.setUserAgent(truncate(request.getUserAgent()));
        // Vuelve a estar viva: si estaba desactivada por fallos o por un cierre
        // de sesion, el contador arranca limpio.
        subscription.setIsActive(true);
        subscription.setFailureCount(0);

        PushSubscription saved = pushSubscriptionRepository.save(subscription);
        logger.info("Suscripcion push {} para el usuario {}", saved.getId(), userId);
        return saved;
    }

    /**
     * Baja al cerrar sesion. Se desactiva en vez de borrar: saber que ese
     * dispositivo estuvo suscrito sirve, y el aseo semanal la retira despues.
     */
    public void unsubscribe(String endpoint) {
        if (isBlank(endpoint)) {
            throw new PushValidationException(Constants.PUSH_ENDPOINT_REQUIRED);
        }

        Optional<PushSubscription> found = pushSubscriptionRepository.findByEndpointHash(sha256(endpoint.trim()));
        if (found.isEmpty()) {
            throw new EntityNotFoundException(Constants.PUSH_NOT_SUBSCRIBED);
        }

        PushSubscription subscription = found.get();
        subscription.setIsActive(false);
        pushSubscriptionRepository.save(subscription);
        logger.info("Suscripcion push {} dada de baja", subscription.getId());
    }

    /**
     * El endpoint no cabe en un indice de MySQL, asi que la unicidad se apoya en
     * su hash. Hex de 64 caracteres para que entre en un CHAR(64) fijo.
     */
    private String sha256(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(digest.length * 2);
            for (byte b : digest) {
                hex.append(Character.forDigit((b >> 4) & 0xF, 16)).append(Character.forDigit(b & 0xF, 16));
            }
            return hex.toString();
        } catch (NoSuchAlgorithmException e) {
            // SHA-256 es obligatorio en toda JVM; si falta, algo mucho peor pasa.
            throw new IllegalStateException("SHA-256 no disponible", e);
        }
    }

    /** El user agent de un navegador puede pasarse de los 300 de la columna. */
    private String truncate(String userAgent) {
        if (userAgent == null) {
            return null;
        }
        return userAgent.length() <= 300 ? userAgent : userAgent.substring(0, 300);
    }

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
    }
}
