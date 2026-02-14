package cash.truck.application.utility;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jws;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.crypto.spec.SecretKeySpec;
import java.security.Key;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.Date;
import java.util.UUID;

public class JWTManager {

    private static final String SECRET_KEY = "mySecretKey";
    private static final Logger logger = LoggerFactory.getLogger(JWTManager.class);
    private JWTManager() {
        throw new IllegalStateException("Utility class");
    }

    public static String createJWT(JSONObject data){
        Key hmacKey = new SecretKeySpec(Base64.getDecoder().decode(ConfigProperties.getJWTKey()),
                SignatureAlgorithm.HS256.getJcaName());
       return Jwts.builder()
                .addClaims(data.toMap())
                .setSubject(data.get(Constants.PARAMETER_EMAIL).toString())
                .setId(UUID.randomUUID().toString())
                .setIssuedAt(Date.from(Instant.now()))
                .setExpiration(Date.from(Instant.now().plus(ConfigProperties.getJWTExpired(), ChronoUnit.MINUTES)))
                .signWith(hmacKey)
                .compact();
    }

    public static Jws<Claims> verifyJWT(String jwtData){
        try {
            String secret = ConfigProperties.getJWTKey();
            Key hmacKey = new SecretKeySpec(Base64.getDecoder().decode(secret),
                    SignatureAlgorithm.HS256.getJcaName());

            return Jwts.parserBuilder()
                    .setSigningKey(hmacKey)
                    .build()
                    .parseClaimsJws(jwtData);

        } catch (Exception e) {
            logger.error(e.getMessage());
            return null;
        }
    }
}
