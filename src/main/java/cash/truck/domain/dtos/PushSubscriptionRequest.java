package cash.truck.domain.dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Lo que entrega el navegador en PushSubscription.toJSON(), mas el user agent.
 * Se recibe tal cual para que el front no tenga que reempaquetarlo.
 *
 * El usuario NO viaja en el cuerpo: se resuelve del header X-USER-ID.
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class PushSubscriptionRequest {

    private String endpoint;
    private Keys keys;
    private String userAgent;

    @Data
    @AllArgsConstructor
    @NoArgsConstructor
    public static class Keys {
        private String p256dh;
        private String auth;
    }
}
