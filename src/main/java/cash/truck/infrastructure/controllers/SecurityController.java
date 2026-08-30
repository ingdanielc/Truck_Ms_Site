package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.PartnerException;
import cash.truck.application.exception.RegistrationException;
import cash.truck.application.usecases.PasswordResetUseCase;
import cash.truck.application.usecases.RegistrationUseCase;
import cash.truck.application.usecases.SecurityUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.RateLimiter;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.domain.dtos.AvailabilityResponse;
import cash.truck.domain.dtos.PasswordResetRequest;
import cash.truck.domain.dtos.PasswordResetResponse;
import cash.truck.domain.dtos.RegisterResponse;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.entities.Users;
import jakarta.persistence.EntityNotFoundException;
import jakarta.servlet.http.HttpServletRequest;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/security", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = {"http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/", "https://truck.ccsoluciones.com.co/"})
public class SecurityController {

    private static final Logger logger = LoggerFactory.getLogger(SecurityController.class);

    @Autowired
    private SecurityUseCase securityUseCase;

    @Autowired
    private PasswordResetUseCase passwordResetUseCase;

    @Autowired
    private RegistrationUseCase registrationUseCase;

    @Autowired
    private RateLimiter rateLimiter;

    /**
     * Registro publico de cuenta. El servidor fija el estado, la fecha de fin de
     * suscripcion y el cupo de vehiculos; lo que venga en esos campos se ignora.
     */
    @PostMapping(value = "/register", consumes = "application/json")
    public ResponseEntity<Object> register(@RequestBody Owner owner, HttpServletRequest request) {
        if (!rateLimiter.tryAcquire(Constants.RATE_BUCKET_REGISTER, RateLimiter.clientIp(request),
                Constants.REGISTER_RATE_LIMIT, Constants.REGISTER_RATE_WINDOW_SECONDS)) {
            return registerError(HttpStatus.TOO_MANY_REQUESTS, Constants.REGISTER_RATE_LIMITED_MESSAGE,
                    Constants.REGISTER_RATE_LIMITED);
        }
        try {
            RegisterResponse response = registrationUseCase.register(owner);
            ResponseMessage responseMessage = new ResponseMessage(response, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.REGISTER_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (RegistrationException e) {
            HttpStatus status = e.isDuplicate() ? HttpStatus.CONFLICT : HttpStatus.BAD_REQUEST;
            return registerError(status, e.getMessage(), e.getI18n());
        } catch (EntityNotFoundException e) {
            return registerError(HttpStatus.NOT_FOUND, e.getMessage(), Constants.REGISTER_KO);
        } catch (PartnerException | IllegalArgumentException e) {
            return registerError(HttpStatus.CONFLICT, e.getMessage(), Constants.REGISTER_KO);
        } catch (Exception e) {
            logger.error("Error registrando la cuenta: {}", e.getMessage());
            return registerError(HttpStatus.INTERNAL_SERVER_ERROR, HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.REGISTER_KO);
        }
    }

    /**
     * Validador asincrono del formulario: dice si un documento, correo o celular
     * sigue libre. Responde solo el booleano y esta limitado por IP para que no
     * sirva de enumerador.
     */
    @GetMapping("/checkAvailability")
    public ResponseEntity<Object> checkAvailability(@RequestParam String field, @RequestParam String value,
            HttpServletRequest request) {
        if (!rateLimiter.tryAcquire(Constants.RATE_BUCKET_AVAILABILITY, RateLimiter.clientIp(request),
                Constants.AVAILABILITY_RATE_LIMIT, Constants.AVAILABILITY_RATE_WINDOW_SECONDS)) {
            return registerError(HttpStatus.TOO_MANY_REQUESTS, Constants.AVAILABILITY_RATE_LIMITED_MESSAGE,
                    Constants.AVAILABILITY_RATE_LIMITED);
        }
        try {
            AvailabilityResponse response = registrationUseCase.checkAvailability(field, value);
            ResponseMessage responseMessage = new ResponseMessage(response, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.AVAILABILITY_CHECK_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (RegistrationException e) {
            return registerError(HttpStatus.BAD_REQUEST, e.getMessage(), Constants.AVAILABILITY_KO);
        } catch (Exception e) {
            logger.error("Error validando disponibilidad: {}", e.getMessage());
            return registerError(HttpStatus.INTERNAL_SERVER_ERROR, HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.AVAILABILITY_KO);
        }
    }

    private ResponseEntity<Object> registerError(HttpStatus status, String message, String i18n) {
        return new ResponseEntity<>(new ResponseErrorMessage(status.value(), message, i18n), status);
    }

    @GetMapping("/getAllUsers")
    public ResponseEntity<Object> getAllPartners() {
        ResponseMessage responseMessage = new ResponseMessage(securityUseCase.getAllUsers(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.USERS_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping(value = "/authentication", consumes = "application/json", produces = "application/json")
    public ResponseEntity<Object> authenticationUser(@RequestBody Users user) {
        try {
            JSONObject responseAutorization = securityUseCase.checkAuthentication(user);
            if (responseAutorization.get(Constants.PARAMETER_AUTHORIZED).equals(Constants.PARAMETER_OK)) {
                HttpHeaders responseHeaders = new HttpHeaders();
                responseHeaders.set("Access-Control-Expose-Headers", Constants.PARAMETER_AUTHORIZED_TOKEN);
                responseHeaders.set(Constants.PARAMETER_AUTHORIZED_TOKEN, responseAutorization.get(Constants.PARAMETER_JWT).toString());
                responseAutorization.remove(Constants.PARAMETER_JWT);
                ResponseMessage responseMessage = new ResponseMessage(responseAutorization.toMap(), HttpStatus.OK.value(), HttpStatus.OK.name(), null, null);
                return ResponseEntity.ok().headers(responseHeaders).body(responseMessage);
            } else {
                ResponseMessage responseMessage = new ResponseMessage(responseAutorization.toMap(), HttpStatus.FORBIDDEN.value(), HttpStatus.FORBIDDEN.name(), null, null);
                return new ResponseEntity<>(responseMessage, HttpStatus.FORBIDDEN);
            }
        } catch (Exception e) {
            ResponseMessage responseMessage = new ResponseMessage(null, HttpStatus.BAD_REQUEST.value(), HttpStatus.BAD_REQUEST.name(), null, null);
            return new ResponseEntity<>(responseMessage, HttpStatus.BAD_REQUEST);
        }
    }

    @PostMapping("/save")
    public ResponseEntity<Object> createOrUpdateUser(@RequestBody Users user) {
        try {
            Users userSave = securityUseCase.saveUser(user);
            ResponseMessage responseMessage = new ResponseMessage(userSave, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.USER_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    Constants.USER_SEARCH_NOT_FOUND_ME, Constants.USER_SEARCH_NOT_FOUND);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (PartnerException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.CONFLICT.value(), e.getMessage(), Constants.USER_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.CONFLICT);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.USER_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/filter")
    public ResponseEntity<Object> filter(@RequestBody FilterRequest filterRequest) {
        try {
            Page<Users> userPage = securityUseCase.findWithFilterOptional(filterRequest);

            ResponseMessage responseMessage = new ResponseMessage(userPage, HttpStatus.OK.value(), HttpStatus.OK.name(),
                    null, Constants.USERS_SEARCH_OK);

            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.PARTNER_SEARCH_KO), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/getAllRoles")
    public ResponseEntity<Object> getAllRoles() {
        ResponseMessage responseMessage = new ResponseMessage(securityUseCase.getAllRoles(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.ROLES_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping(value = "/forgotPassword", consumes = "application/json")
    public ResponseEntity<Object> forgotPassword(@RequestBody PasswordResetRequest request) {
        try {
            PasswordResetResponse response = passwordResetUseCase.forgotPassword(request.getCellPhone());
            ResponseMessage responseMessage = new ResponseMessage(response, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.PASSWORD_RESET_SENT_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (EntityNotFoundException e) {
            return passwordResetError(HttpStatus.NOT_FOUND, e.getMessage(), Constants.PASSWORD_RESET_NOT_FOUND);
        } catch (IllegalArgumentException e) {
            return passwordResetError(HttpStatus.CONFLICT, e.getMessage(), Constants.PASSWORD_RESET_KO);
        } catch (Exception e) {
            logger.error("Error requesting password reset: {}", e.getMessage());
            return passwordResetError(HttpStatus.INTERNAL_SERVER_ERROR, HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.PASSWORD_RESET_KO);
        }
    }

    @PostMapping(value = "/verify", consumes = "application/json")
    public ResponseEntity<Object> verify(@RequestBody PasswordResetRequest request) {
        try {
            PasswordResetResponse response = passwordResetUseCase.verify(request.getCellPhone(), request.getCode());
            ResponseMessage responseMessage = new ResponseMessage(response, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.PASSWORD_RESET_VERIFIED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (EntityNotFoundException e) {
            return passwordResetError(HttpStatus.NOT_FOUND, e.getMessage(), Constants.PASSWORD_RESET_NOT_FOUND);
        } catch (IllegalArgumentException e) {
            return passwordResetError(HttpStatus.CONFLICT, e.getMessage(), Constants.PASSWORD_RESET_KO);
        } catch (Exception e) {
            logger.error("Error verifying password reset code: {}", e.getMessage());
            return passwordResetError(HttpStatus.INTERNAL_SERVER_ERROR, HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.PASSWORD_RESET_KO);
        }
    }

    @PostMapping(value = "/reset", consumes = "application/json")
    public ResponseEntity<Object> reset(@RequestBody PasswordResetRequest request) {
        try {
            passwordResetUseCase.reset(request.getResetToken(), request.getPassword());
            ResponseMessage responseMessage = new ResponseMessage(null, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.PASSWORD_RESET_CHANGED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (EntityNotFoundException e) {
            return passwordResetError(HttpStatus.NOT_FOUND, e.getMessage(), Constants.PASSWORD_RESET_NOT_FOUND);
        } catch (IllegalArgumentException e) {
            return passwordResetError(HttpStatus.CONFLICT, e.getMessage(), Constants.PASSWORD_RESET_KO);
        } catch (Exception e) {
            logger.error("Error changing password: {}", e.getMessage());
            return passwordResetError(HttpStatus.INTERNAL_SERVER_ERROR, HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.PASSWORD_RESET_KO);
        }
    }

    private ResponseEntity<Object> passwordResetError(HttpStatus status, String message, String i18n) {
        return new ResponseEntity<>(new ResponseErrorMessage(status.value(), message, i18n), status);
    }
}
