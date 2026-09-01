package cash.truck.infrastructure.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;

/**
 * Habilita los @Async de los casos de uso de mensajeria. Sin esta anotacion la
 * de WhatsappMessageUseCase, SmsMessageUseCase y EmailMessageUseCase quedaba
 * inerte y el envio corria en el hilo de quien llamaba: crear un propietario
 * esperaba a que Twilio contestara antes de devolver la respuesta.
 *
 * Se usa el executor que Spring Boot autoconfigura (applicationTaskExecutor);
 * definir uno propio aqui haria ambigua la resolucion de los @Async sin
 * calificador.
 */
@Configuration
@EnableAsync
public class AsyncConfig {
}
