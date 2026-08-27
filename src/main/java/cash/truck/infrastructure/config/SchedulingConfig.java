package cash.truck.infrastructure.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * Habilita las tareas programadas. Sin esta anotacion los @Scheduled del
 * proyecto quedan inertes y no se ejecuta ninguno.
 */
@Configuration
@EnableScheduling
public class SchedulingConfig {
}
