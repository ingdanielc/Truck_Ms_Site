package cash.truck.infrastructure.config;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

public class CustomHeaderAuthFilter extends OncePerRequestFilter {

private static final String HEADER_NAME = "X-API-KEY";
    private static final String HEADER_VALUE = "truck-api-key";  // Cambia esto por un valor seguro

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        String headerValue = request.getHeader(HEADER_NAME);

        if (HEADER_VALUE.equals(headerValue)) {
            SecurityContextHolder.getContext().setAuthentication(new CustomHeaderAuthToken());
        } else {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        filterChain.doFilter(request, response);
    }
}
