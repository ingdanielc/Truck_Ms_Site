package cash.truck.infrastructure.providers.push;

import nl.martijndwars.webpush.AbstractPushService;
import nl.martijndwars.webpush.Encoding;
import nl.martijndwars.webpush.HttpRequest;
import nl.martijndwars.webpush.Notification;

import java.io.IOException;
import java.security.GeneralSecurityException;

import org.jose4j.lang.JoseException;

/**
 * Arma la peticion cifrada y firmada que se le manda al push service.
 *
 * La libreria trae dos clases listas para enviar —PushService y
 * PushAsyncService—, pero cada una arrastra su propio cliente HTTP (Apache
 * httpasyncclient y Netty). Aqui se excluyeron del pom: la API ya corre sobre
 * Tomcat y el JDK trae su HttpClient desde Java 11, asi que meter un segundo
 * stack HTTP solo aportaria peso y superficie de CVE.
 *
 * Lo que si hace falta de la libreria es la parte dificil: el cifrado del
 * payload (RFC 8291) y el JWT de VAPID (RFC 8292). Eso vive en
 * prepareRequest(), que es protected: de ahi que esta clase exista, para
 * exponerlo. Devuelve URL, cabeceras y cuerpo listos para cualquier cliente.
 */
public class VapidRequestFactory extends AbstractPushService<VapidRequestFactory> {

    public VapidRequestFactory(String publicKey, String privateKey, String subject)
            throws GeneralSecurityException {
        super(publicKey, privateKey, subject);
    }

    /**
     * AES128GCM y no AESGCM: es el esquema del estandar vigente y el unico que
     * entienden todos los navegadores con soporte actual.
     */
    public HttpRequest build(Notification notification)
            throws GeneralSecurityException, IOException, JoseException {
        return prepareRequest(notification, Encoding.AES128GCM);
    }
}
