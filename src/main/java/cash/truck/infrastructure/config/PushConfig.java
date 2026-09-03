package cash.truck.infrastructure.config;

import cash.truck.application.utility.Constants;
import cash.truck.infrastructure.providers.push.VapidRequestFactory;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.net.http.HttpClient;
import java.security.Security;
import java.time.Duration;

/**
 * Llaves VAPID y cliente HTTP del push.
 *
 * Las llaves llegan por variable de entorno y por defecto van vacias: sin ellas
 * el push queda apagado y la aplicacion arranca igual. Es a proposito, para que
 * desplegar el backend antes que el frontend —como manda el plan— no obligue a
 * tener el par generado ni rompa los entornos donde nadie lo va a usar. La
 * unica consecuencia de no configurarlas es que PushSenderUseCase no envia y lo
 * dice en el log.
 *
 * La llave privada NUNCA va en el repositorio.
 */
@Configuration
public class PushConfig {

    private static final Logger logger = LoggerFactory.getLogger(PushConfig.class);

    private final String publicKey;
    private final String privateKey;
    private final String subject;

    public PushConfig(@Value("${truck.push.public-key:}") String publicKey,
                      @Value("${truck.push.private-key:}") String privateKey,
                      @Value("${truck.push.subject:" + Constants.PUSH_SUBJECT_DEFAULT + "}") String subject) {
        this.publicKey = publicKey == null ? "" : publicKey.trim();
        this.privateKey = privateKey == null ? "" : privateKey.trim();
        this.subject = subject;
    }

    /**
     * Null cuando no hay par configurado. Se prefiere un bean nulo a no
     * declararlo: asi el caso de uso decide que hacer y no hay que condicionar
     * el arranque del contexto.
     */
    @Bean
    public VapidRequestFactory vapidRequestFactory() {
        if (publicKey.isEmpty() || privateKey.isEmpty()) {
            logger.warn("Push desactivado: falta truck.push.public-key o truck.push.private-key");
            return null;
        }

        // El cifrado usa curvas de BouncyCastle; sin el proveedor registrado
        // falla al cargar las llaves.
        if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
            Security.addProvider(new BouncyCastleProvider());
        }

        try {
            VapidRequestFactory factory = new VapidRequestFactory(publicKey, privateKey, subject);
            logger.info("Push activado con subject {}", subject);
            return factory;
        } catch (Exception e) {
            // Un par mal copiado no puede impedir que arranque el resto.
            logger.error("Push desactivado: el par VAPID no es valido: {}", e.getMessage());
            return null;
        }
    }

    /** La llave publica que el frontend pide para suscribirse. */
    @Bean(name = "vapidPublicKey")
    public String vapidPublicKey() {
        return publicKey;
    }

    /**
     * El del JDK, no un stack nuevo. El timeout es corto a proposito: un push
     * service lento no puede quedarse con un hilo del pool.
     */
    @Bean(name = "pushHttpClient")
    public HttpClient pushHttpClient() {
        return HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(Constants.PUSH_HTTP_TIMEOUT_SECONDS))
                .build();
    }
}
