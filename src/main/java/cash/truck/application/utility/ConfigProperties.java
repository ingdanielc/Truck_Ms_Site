package cash.truck.application.utility;

import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

@Component
@Configuration
@PropertySource("classpath:application.yml")
public class ConfigProperties {

    private static Environment env;

    public ConfigProperties(Environment environment) {
        env = environment;
    }

    public static String getConfigValue(String configKey){
        return env.getProperty(configKey);
    }

    public static String getJWTKey() {
        return getConfigValue("truck.parameter.jwt-key");
    }

    public static int getJWTExpired() {
        return Integer.valueOf(getConfigValue("truck.parameter.jwt-expired"));
    }
}
