package cash.truck.infrastructure.config;

import org.springframework.boot.task.ThreadPoolTaskExecutorBuilder;
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
 * Hay dos pools y la distincion importa. La mensajeria usa el de por defecto,
 * porque sus @Async no llevan calificador; el push usa el suyo, porque un aviso
 * llega a N dispositivos por usuario y un barrido masivo son cientos de
 * conexiones salientes que no pueden competir con los envios de Twilio.
 *
 * OJO al declarar aqui cualquier bean de tipo Executor: Spring Boot autoconfigura
 * applicationTaskExecutor con @ConditionalOnMissingBean(Executor.class), asi que
 * en cuanto aparece uno propio, el suyo deja de crearse. Cuando eso paso, los
 * @Async sin calificador cayeron en un SimpleAsyncTaskExecutor, que abre un hilo
 * nuevo por mensaje y sin tope. Por eso el de por defecto se declara explicito
 * aqui abajo en vez de confiar en la autoconfiguracion.
 */
@Configuration
@EnableAsync
public class AsyncConfig {

    /** Nombre con el que se pide el pool del push: @Async(AsyncConfig.PUSH_EXECUTOR). */
    public static final String PUSH_EXECUTOR = "pushExecutor";

    /**
     * El que Spring Boot habria creado solo. Se arma con su mismo builder para
     * respetar las propiedades spring.task.execution.*, y conserva sus dos
     * nombres: con dos Executor en el contexto, el @Async sin calificador ya no
     * puede resolverse por tipo y Spring cae al bean llamado "taskExecutor".
     * Ese alias es lo que manda la mensajeria a este pool y no al del push.
     */
    @Bean(name = { "applicationTaskExecutor", "taskExecutor" })
    public ThreadPoolTaskExecutor applicationTaskExecutor(ThreadPoolTaskExecutorBuilder builder) {
        return builder.build();
    }

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
