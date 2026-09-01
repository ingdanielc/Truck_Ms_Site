package cash.truck.application.utility;

import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Template;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Component
public class MapUtils {

    /**
     * Traduce las variables nombradas de la plantilla local al JSON posicional
     * que espera Twilio: {"1":"Juan","2":"https://..."}. El orden lo fija
     * providerVariables, no el orden en que el llamador armo la lista, porque
     * ese numero tiene que coincidir con el de la plantilla aprobada.
     *
     * Una variable que no llegue se envia vacia en lugar de romper el envio:
     * WhatsApp rechaza el mensaje si falta una posicion.
     */
    public String mapContentVariables(String providerVariables, List<MessageRequest.KeyValue> data) {
        if (providerVariables == null || providerVariables.isBlank()) {
            return null;
        }

        Map<String, String> values = new HashMap<>();
        if (data != null) {
            for (MessageRequest.KeyValue entry : data) {
                if (entry.getKey() != null) {
                    values.put(entry.getKey(), entry.getValue() == null ? "" : entry.getValue());
                }
            }
        }

        StringBuilder json = new StringBuilder("{");
        int position = 1;
        for (String key : providerVariables.split(",")) {
            if (position > 1) {
                json.append(',');
            }
            json.append(JSONObject.quote(String.valueOf(position)))
                    .append(':')
                    .append(JSONObject.quote(values.getOrDefault(key.trim(), "")));
            position++;
        }
        return json.append('}').toString();
    }

    public String mapTemplateValues(Template template, List<MessageRequest.KeyValue> data) {
        try {
            String content = template.getTemplateContent();
            if (content == null || content.isEmpty()) {
                throw new RuntimeException("Template content is null or empty");
            }

            for (MessageRequest.KeyValue entry : data) {
                String key = entry.getKey();
                String value = entry.getValue();
                if (key != null && value != null) {
                    content = content.replace("${" + key + "}", value);
                }
            }
            content = content.replaceAll("\\$\\{[^}]+}", "");

            log.info("Final template content after mapping: {}", content);
            return content;
        } catch (Exception e) {
            log.error("Error processing template values: {}", e.getMessage());
            throw new RuntimeException("Error mapping template values: " + e.getMessage(), e);
        }
    }
}
