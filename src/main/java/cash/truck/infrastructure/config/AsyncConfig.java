package cash.truck.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.Executor;
import java.util.concurrent.ThreadPoolExecutor;

/**
 * Habilita los @Async de los casos de uso de mensajeria. Sin esta anotacion la
 * de WhatsappMessageUseCase, SmsMessageUseCase y EmailMessageUseCase quedaba
 * inerte y el envio corria en el hilo de quien llamaba: crear un propietario
 * esperaba a que Twilio contestara antes de devolver la respuesta.
 *
 * Esos tres siguen usando el executor que Spring Boot autoconfigura
 * (applicationTaskExecutor), porque no llevan calificador. El push si tiene el
 * suyo: un aviso llega a N dispositivos por usuario, asi que un barrido masivo
 * son cientos de conexiones salientes, y sobre el executor comun competirian
 * con las peticiones de los usuarios. Al declararlo con nombre y pedirlo como
 * @Async("pushExecutor") no se vuelve ambigua la resolucion de los otros tres.
 */
@Configuration
@EnableAsync
public class AsyncConfig {

    /** Nombre con el que se pide el pool: @Async(AsyncConfig.PUSH_EXECUTOR). */
    public static final String PUSH_EXECUTOR = "pushExecutor";

    /**
     * Acotado y con cola limitada. La politica ante saturacion es CallerRuns: un
     * aviso push no vale perderse en silencio, pero tampoco vale crecer sin
     * limite; que el llamador —un scheduler, no una peticion de usuario— absorba
     * el exceso es el mal menor.
     */
    @Bean(name = PUSH_EXECUTOR)
    public Executor pushExecutor() {
        ThreadPoolTaskExecutor executor = new ThreadPoolTaskExecutor();
        executor.setCorePoolSize(10);
        executor.setMaxPoolSize(20);
        executor.setQueueCapacity(500);
        executor.setThreadNamePrefix("push-");
        executor.setRejectedExecutionHandler(new ThreadPoolExecutor.CallerRunsPolicy());
        executor.initialize();
        return executor;
    }
}
