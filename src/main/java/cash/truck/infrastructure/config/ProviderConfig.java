package cash.truck.infrastructure.config;

import cash.truck.application.strategies.EmailNotificationStrategy;
import cash.truck.application.strategies.SmsNotificationStrategy;
import cash.truck.application.strategies.WhatsAppNotificationStrategy;
import cash.truck.infrastructure.providers.gmail.GmailEmailNotificationProviders;
import cash.truck.infrastructure.providers.twilio.TwilioEmailNotificationProviders;
import cash.truck.infrastructure.providers.twilio.TwilioSmsNotificationProviders;
import cash.truck.infrastructure.providers.twilio.TwilioWhatsAppNotificationProviders;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ProviderConfig {

    @Value("${provider.whatsapp}")
    private String whatsappProvider;

    @Value("${provider.sms}")
    private String smsProvider;

    @Value("${provider.email}")
    private String emailProvider;

    @Value("${provider.flow}")
    private String flowProvider;

    @Bean
    public WhatsAppNotificationStrategy whatsappService() {
        return new TwilioWhatsAppNotificationProviders();
    }

    @Bean
    public SmsNotificationStrategy smsService() {
        return new TwilioSmsNotificationProviders();
    }

    @Bean
    public EmailNotificationStrategy emailService() {
        return switch (emailProvider.toLowerCase()) {
            case "twilio" -> new TwilioEmailNotificationProviders();
            case "gmail" -> new GmailEmailNotificationProviders();
            default -> throw new IllegalArgumentException("Email provider not supported: " + emailProvider);
        };
    }
}
