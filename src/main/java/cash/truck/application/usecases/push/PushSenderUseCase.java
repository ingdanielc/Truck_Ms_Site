package cash.truck.application.usecases.push;

import cash.truck.application.utility.Constants;
import cash.truck.domain.dtos.PushPayload;
import cash.truck.domain.entities.PushSubscription;
import cash.truck.domain.repositories.PushSubscriptionRepository;
import cash.truck.infrastructure.config.AsyncConfig;
import cash.truck.infrastructure.providers.push.VapidRequestFactory;
import com.google.gson.Gson;
import nl.martijndwars.webpush.Notification;
import nl.martijndwars.webpush.Urgency;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 * Envia el aviso a todos los dispositivos de un usuario.
 *
 * Punto de entrada unico: ningun flujo de negocio conoce endpoints, llaves ni
 * codigos del push service. Corre en su propio pool (@Async con calificador) y
 * nunca dentro de la transaccion de quien lo llama: un push service lento no
 * puede bloquear el guardado de un viaje, y un fallo suyo no puede revertirlo.
 *
 * Por eso ningun metodo de aqui lanza: todo error se registra y se traga. El
 * push es un transporte de conveniencia; la notificacion interna ya quedo
 * guardada y es la que manda.
 */
@Service
public class PushSenderUseCase {

    private static final Logger logger = LoggerFactory.getLogger(PushSenderUseCase.class);
    private static final Gson GSON = new Gson();

    /** Nulo cuando no hay par VAPID configurado: el push queda apagado. */
    private final VapidRequestFactory vapidRequestFactory;
    private final HttpClient httpClient;
    private final PushSubscriptionRepository pushSubscriptionRepository;

    public PushSenderUseCase(@Autowired(required = false) VapidRequestFactory vapidRequestFactory,
                             @Qualifier("pushHttpClient") HttpClient httpClient,
                             PushSubscriptionRepository pushSubscriptionRepository) {
        this.vapidRequestFactory = vapidRequestFactory;
        this.httpClient = httpClient;
        this.pushSubscriptionRepository = pushSubscriptionRepository;
    }

    @Async(AsyncConfig.PUSH_EXECUTOR)
    public void send(Integer userId, PushPayload payload) {
        send(userId, payload, Urgency.NORMAL);
    }

    @Async(AsyncConfig.PUSH_EXECUTOR)
    public void send(Integer userId, PushPayload payload, Urgency urgency) {
        if (vapidRequestFactory == null) {
            logger.debug("Push apagado: no se envia el aviso al usuario {}", userId);
            return;
        }
        if (userId == null || payload == null) {
            return;
        }

        List<PushSubscription> subscriptions = pushSubscriptionRepository.findByUserIdAndIsActiveTrue(userId);
        if (subscriptions.isEmpty()) {
            logger.debug("El usuario {} no tiene dispositivos suscritos", userId);
            return;
        }

        String json = GSON.toJson(payload);
        for (PushSubscription subscription : subscriptions) {
            // Un dispositivo que falle no puede dejar sin aviso a los demas.
            try {
                deliver(subscription, json, urgency);
            } catch (Exception e) {
                logger.error("No se pudo enviar el push a la suscripcion {}: {}",
                        subscription.getId(), e.getMessage());
                registerFailure(subscription);
            }
        }
    }

    /**
     * Un intento por dispositivo, con reintentos solo ante fallos temporales.
     * Un 410 no se reintenta: significa que esa suscripcion ya no existe.
     */
    private void deliver(PushSubscription subscription, String json, Urgency urgency) throws Exception {
        Notification notification = Notification.builder()
                .endpoint(subscription.getEndpoint())
                .userPublicKey(subscription.getP256dh())
                .userAuth(subscription.getAuth())
                .payload(json.getBytes(StandardCharsets.UTF_8))
                .ttl(Constants.PUSH_TTL_SECONDS)
                .urgency(urgency)
                .build();

        nl.martijndwars.webpush.HttpRequest prepared = vapidRequestFactory.build(notification);

        for (int attempt = 1; attempt <= Constants.PUSH_MAX_ATTEMPTS; attempt++) {
            HttpResponse<String> response = httpClient.send(toHttpRequest(prepared),
                    HttpResponse.BodyHandlers.ofString());
            int status = response.statusCode();

            if (status >= 200 && status < 300) {
                registerSuccess(subscription);
                return;
            }

            // Permiso revocado, datos borrados o suscripcion caducada. La fila
            // muere aqui: sin esto la tabla se llena de endpoints que solo
            // sirven para gastar una llamada fallida en cada envio.
            if (status == 404 || status == 410) {
                deactivate(subscription, status);
                return;
            }

            if (status == 413) {
                // Es un bug del payload, no del usuario: reintentar no arregla.
                logger.error("Payload demasiado grande para la suscripcion {} ({} bytes)",
                        subscription.getId(), json.length());
                return;
            }

            if (status == 429 || status >= 500) {
                if (attempt == Constants.PUSH_MAX_ATTEMPTS || !waitBeforeRetry(response, attempt)) {
                    logger.warn("Push a la suscripcion {} agotado tras {} intento(s), ultimo estado {}",
                            subscription.getId(), attempt, status);
                    registerFailure(subscription);
                    return;
                }
                continue;
            }

            logger.warn("El push service respondio {} para la suscripcion {}", status, subscription.getId());
            registerFailure(subscription);
            return;
        }
    }

    private HttpRequest toHttpRequest(nl.martijndwars.webpush.HttpRequest prepared) {
        HttpRequest.Builder builder = HttpRequest.newBuilder()
                .uri(URI.create(prepared.getUrl()))
                .timeout(Duration.ofSeconds(Constants.PUSH_HTTP_TIMEOUT_SECONDS))
                .POST(HttpRequest.BodyPublishers.ofByteArray(
                        prepared.getBody() == null ? new byte[0] : prepared.getBody()));

        for (Map.Entry<String, String> header : prepared.getHeaders().entrySet()) {
            builder.header(header.getKey(), header.getValue());
        }
        return builder.build();
    }

    /**
     * Se respeta el Retry-After que manda el push service, pero con tope: una
     * espera larga dejaria un hilo del pool bloqueado sin ganancia, y el aviso
     * ya habria perdido vigencia cuando saliera.
     */
    private boolean waitBeforeRetry(HttpResponse<String> response, int attempt) {
        long seconds = response.headers().firstValue("Retry-After")
                .map(value -> {
                    try {
                        return Long.parseLong(value.trim());
                    } catch (NumberFormatException e) {
                        return (long) attempt;
                    }
                })
                .orElse((long) attempt);

        if (seconds > Constants.PUSH_MAX_RETRY_AFTER_SECONDS) {
            return false;
        }

        try {
            Thread.sleep(seconds * 1000L);
            return true;
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            return false;
        }
    }

    private void registerSuccess(PushSubscription subscription) {
        subscription.setLastSuccessDate(new Date());
        subscription.setFailureCount(0);
        pushSubscriptionRepository.save(subscription);
    }

    private void registerFailure(PushSubscription subscription) {
        subscription.setFailureCount(subscription.getFailureCount() == null
                ? 1
                : subscription.getFailureCount() + 1);
        pushSubscriptionRepository.save(subscription);
    }

    private void deactivate(PushSubscription subscription, int status) {
        subscription.setIsActive(false);
        pushSubscriptionRepository.save(subscription);
        logger.info("Suscripcion {} desactivada: el push service respondio {}", subscription.getId(), status);
    }
}
