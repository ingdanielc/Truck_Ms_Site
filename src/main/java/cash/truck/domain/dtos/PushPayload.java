package cash.truck.domain.dtos;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.HashMap;
import java.util.Map;

/**
 * Contenido que el service worker recibe tal cual y muestra en el celular.
 *
 * El limite duro del estandar son 4 KB ya cifrado; se apunta a menos de 2 KB
 * recortando titulo y cuerpo, porque el celular los trunca de todos modos.
 */
@Data
@AllArgsConstructor
@NoArgsConstructor
public class PushPayload {

    public static final int TITLE_MAX_LENGTH = 50;
    public static final int BODY_MAX_LENGTH = 120;

    private String title;
    private String body;
    private String icon;
    private String badge;
    /**
     * Agrupa avisos del mismo objeto: con el mismo tag, tres actualizaciones de
     * un viaje muestran una sola notificacion en vez de apilar tres.
     */
    private String tag;
    private Map<String, Object> data = new HashMap<>();

    /** El titulo y el cuerpo se recortan aqui y no en cada llamador. */
    public void setTitle(String title) {
        this.title = truncate(title, TITLE_MAX_LENGTH);
    }

    public void setBody(String body) {
        this.body = truncate(body, BODY_MAX_LENGTH);
    }

    private static String truncate(String value, int max) {
        if (value == null || value.length() <= max) {
            return value;
        }
        return value.substring(0, max - 1) + "…";
    }
}
