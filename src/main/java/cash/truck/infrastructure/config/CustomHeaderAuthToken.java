package cash.truck.infrastructure.config;

import org.springframework.security.authentication.AbstractAuthenticationToken;
import org.springframework.security.core.authority.AuthorityUtils;

public class CustomHeaderAuthToken extends AbstractAuthenticationToken {

    public CustomHeaderAuthToken() {
        super(AuthorityUtils.NO_AUTHORITIES);
        setAuthenticated(true);
    }

    @Override
    public Object getCredentials() {
        return null;
    }

    @Override
    public Object getPrincipal() {
        return "API User";
    }
}
