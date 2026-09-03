package cash.truck.push;

import cash.truck.domain.dtos.PushPayload;
import cash.truck.infrastructure.providers.push.VapidRequestFactory;
import nl.martijndwars.webpush.HttpRequest;
import nl.martijndwars.webpush.Notification;
import nl.martijndwars.webpush.Urgency;
import nl.martijndwars.webpush.Utils;
import org.bouncycastle.jce.provider.BouncyCastleProvider;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.nio.charset.StandardCharsets;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.SecureRandom;
import java.security.Security;
import java.security.spec.ECGenParameterSpec;
import java.util.Base64;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Comprueba que el cifrado y la firma VAPID siguen funcionando despues de haber
 * excluido del pom el arbol transitivo de la libreria (async-http-client,
 * httpasyncclient y jcommander).
 *
 * Es la prueba que justifica esa poda: si alguna de esas clases hiciera falta
 * para armar la peticion, aqui saltaria un NoClassDefFoundError. No se envia
 * nada a ningun push service; solo se construye la peticion.
 */
class VapidRequestFactoryTest {

    private static final String FCM_ENDPOINT = "https://fcm.googleapis.com/fcm/send/abc123";
    private static final String MOZILLA_ENDPOINT = "https://updates.push.services.mozilla.com/wpush/v2/abc123";

    @BeforeAll
    static void registerProvider() {
        if (Security.getProvider(BouncyCastleProvider.PROVIDER_NAME) == null) {
            Security.addProvider(new BouncyCastleProvider());
        }
    }

    @Test
    void armaLaPeticionCifradaYFirmada() throws Exception {
        KeyPair serverKeys = generateKeyPair();
        KeyPair deviceKeys = generateKeyPair();

        VapidRequestFactory factory = new VapidRequestFactory(
                encodePublic(serverKeys), encodePrivate(serverKeys), "mailto:soporte@ccsoluciones.com.co");

        PushPayload payload = new PushPayload();
        payload.setTitle("Documento por vencer");
        payload.setBody("SOAT del vehículo ABC123 vence en 3 días");
        payload.setTag("document-1");
        payload.setData(Map.of("notificationId", 987, "eventType", "DOCUMENT_EVENT"));

        Notification notification = Notification.builder()
                .endpoint(FCM_ENDPOINT)
                .userPublicKey(encodePublic(deviceKeys))
                .userAuth(randomAuth())
                .payload(toJson(payload).getBytes(StandardCharsets.UTF_8))
                .ttl(86400)
                .urgency(Urgency.NORMAL)
                .build();

        HttpRequest request = factory.build(notification);

        // La libreria reescribe los endpoints heredados de FCM (/fcm/send/) a la
        // ruta Web Push (/wp/). Por eso el envio tiene que usar la URL que
        // devuelve prepareRequest y nunca el endpoint crudo de la suscripcion.
        assertEquals("https://fcm.googleapis.com/wp/abc123", request.getUrl());
        assertNotNull(request.getBody());
        assertTrue(request.getBody().length > 0, "el cuerpo cifrado no puede ir vacío");

        Map<String, String> headers = request.getHeaders();
        assertEquals("aes128gcm", headers.get("Content-Encoding"));
        assertTrue(headers.getOrDefault("Authorization", "").startsWith("vapid"),
                "falta el JWT de VAPID: " + headers.get("Authorization"));
        assertEquals("86400", headers.get("TTL"));

        // El payload viaja cifrado: el texto plano no puede aparecer en el cuerpo.
        assertFalse(new String(request.getBody(), StandardCharsets.ISO_8859_1).contains("ABC123"));
    }

    /** Los endpoints que no son de FCM se dejan tal cual. */
    @Test
    void respetaElEndpointCuandoNoEsDeFcm() throws Exception {
        KeyPair serverKeys = generateKeyPair();
        KeyPair deviceKeys = generateKeyPair();

        VapidRequestFactory factory = new VapidRequestFactory(
                encodePublic(serverKeys), encodePrivate(serverKeys), "mailto:soporte@ccsoluciones.com.co");

        Notification notification = Notification.builder()
                .endpoint(MOZILLA_ENDPOINT)
                .userPublicKey(encodePublic(deviceKeys))
                .userAuth(randomAuth())
                .payload("{}".getBytes(StandardCharsets.UTF_8))
                .ttl(86400)
                .build();

        assertEquals(MOZILLA_ENDPOINT, factory.build(notification).getUrl());
    }

    @Test
    void recortaTituloYCuerpoAlLimiteDelEstandar() {
        PushPayload payload = new PushPayload();
        payload.setTitle("T".repeat(200));
        payload.setBody("B".repeat(400));

        assertEquals(PushPayload.TITLE_MAX_LENGTH, payload.getTitle().length());
        assertEquals(PushPayload.BODY_MAX_LENGTH, payload.getBody().length());
        assertTrue(payload.getTitle().endsWith("…"));
    }

    @Test
    void dejaIntactoLoQueYaCabe() {
        PushPayload payload = new PushPayload();
        payload.setTitle("Documento por vencer");
        payload.setBody("SOAT vence hoy");

        assertEquals("Documento por vencer", payload.getTitle());
        assertEquals("SOAT vence hoy", payload.getBody());
    }

    private static KeyPair generateKeyPair() throws Exception {
        KeyPairGenerator generator = KeyPairGenerator.getInstance("ECDH", BouncyCastleProvider.PROVIDER_NAME);
        generator.initialize(new ECGenParameterSpec("prime256v1"));
        return generator.generateKeyPair();
    }

    private static String encodePublic(KeyPair keyPair) {
        return base64Url(Utils.encode((org.bouncycastle.jce.interfaces.ECPublicKey) keyPair.getPublic()));
    }

    private static String encodePrivate(KeyPair keyPair) {
        return base64Url(Utils.encode((org.bouncycastle.jce.interfaces.ECPrivateKey) keyPair.getPrivate()));
    }

    private static String randomAuth() {
        byte[] auth = new byte[16];
        new SecureRandom().nextBytes(auth);
        return base64Url(auth);
    }

    private static String base64Url(byte[] value) {
        return Base64.getUrlEncoder().withoutPadding().encodeToString(value);
    }

    private static String toJson(PushPayload payload) {
        return new com.google.gson.Gson().toJson(payload);
    }
}
