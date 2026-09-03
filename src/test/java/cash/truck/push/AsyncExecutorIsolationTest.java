package cash.truck.push;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;

import java.util.concurrent.CompletableFuture;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Verifica que agregar el pool del push no se llevo por delante el executor de
 * la mensajeria existente.
 *
 * El riesgo es concreto: Spring Boot autoconfigura applicationTaskExecutor con
 * @ConditionalOnMissingBean(Executor.class), asi que declarar un Executor
 * propio puede hacer que se retire. Si eso pasara, los @Async sin calificador
 * —WhatsApp, SMS y correo— pasarian a correr sobre el pool del push y un
 * barrido masivo de avisos competiria con los envios de Twilio.
 */
@SpringBootTest
class AsyncExecutorIsolationTest {

    @Autowired
    private ApplicationContext context;

    @Autowired
    private SampleAsyncBean sampleAsyncBean;

    @Test
    void elExecutorPorDefectoDeSpringBootSigueExistiendo() {
        assertTrue(context.containsBean("applicationTaskExecutor"),
                "Spring Boot retiro su executor por defecto: los @Async de mensajería se quedaron sin pool propio");
    }

    @Test
    void elPoolDelPushSigueDeclarado() {
        assertTrue(context.containsBean("pushExecutor"));
    }

    /** Un @Async sin calificador no puede terminar en el pool del push. */
    @Test
    void laMensajeriaNoCorreEnElPoolDelPush() throws Exception {
        String thread = sampleAsyncBean.currentThread().get();

        assertFalse(thread.startsWith("push-"),
                "un @Async sin calificador cayó en el pool del push: " + thread);
        // "task-" es el prefijo del pool de Spring Boot. Si apareciera
        // "SimpleAsyncTaskExecutor" seria la señal de que la autoconfiguracion
        // se retiro y cada mensaje abre un hilo nuevo sin tope.
        assertTrue(thread.startsWith("task-"),
                "la mensajería no está corriendo en el pool acotado por defecto: " + thread);
    }

    @TestConfiguration
    static class Config {
        @Bean
        SampleAsyncBean sampleAsyncBean() {
            return new SampleAsyncBean();
        }
    }

    /** Imita a WhatsappMessageUseCase: @Async sin calificador. */
    @Component
    static class SampleAsyncBean {
        @Async
        public CompletableFuture<String> currentThread() {
            return CompletableFuture.completedFuture(Thread.currentThread().getName());
        }
    }
}
