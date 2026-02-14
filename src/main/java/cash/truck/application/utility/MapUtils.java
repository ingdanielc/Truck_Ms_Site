package cash.truck.application.utility;

import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Template;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
public class MapUtils {

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
