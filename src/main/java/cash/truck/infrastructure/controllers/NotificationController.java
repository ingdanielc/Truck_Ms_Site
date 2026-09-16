package cash.truck.infrastructure.controllers;

import cash.truck.application.usecases.InAppNotificationUseCase;
import cash.truck.application.usecases.SecurityUseCase;
import cash.truck.application.usecases.notifications.EmailMessageUseCase;

import cash.truck.application.usecases.notifications.SmsMessageUseCase;
import cash.truck.application.usecases.notifications.WhatsappMessageUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.domain.dtos.MessageRequest;

import cash.truck.domain.entities.Notification;
import cash.truck.domain.entities.notifications.Audit;

import cash.truck.domain.enums.MediumEnum;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;

import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/notifications", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = { "http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/",
        "https://truck.ccsoluciones.com.co/" })
public class NotificationController {

    @Autowired
    private WhatsappMessageUseCase whatsappMessageUseCase;

    @Autowired
    private SmsMessageUseCase smsMessageUseCase;

    @Autowired
    private EmailMessageUseCase emailMessageUseCase;

    @Autowired
    private InAppNotificationUseCase inAppNotificationUseCase;

    @Autowired
    private SecurityUseCase securityUseCase;

    @PostMapping("/sendMessages")
    public ResponseEntity<Object> sendMessages(@RequestBody MessageRequest messageRequest) {
        try {
            MediumEnum mediumEnum = MediumEnum.fromName(messageRequest.getMedium());
            switch (mediumEnum) {
                case SMS -> smsMessageUseCase.sendSms(messageRequest, new Audit());
                case EMAIL -> emailMessageUseCase.sendEmail(messageRequest, new Audit());
                default -> whatsappMessageUseCase.sendWhatsApp(messageRequest, new Audit());
            }
            ResponseMessage responseMessage = new ResponseMessage("processed", HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.NOTIFICATION_SEARCH_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(), HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.NOTIFICATION_SEARCH_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/getAllNotifications")
    public ResponseEntity<Object> getAllNotifications() {
        try {
            return new ResponseEntity<>(inAppNotificationUseCase.getAllNotifications(), HttpStatus.OK);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(), HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.NOTIFICATION_SEARCH_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * El front lo usa para marcar leida o borrada y manda la notificacion
     * completa. Solo se aplican esos dos campos, y solo sobre una notificacion
     * de quien llama: cada persona tiene su propia copia y no puede tocar la
     * de otro. Ya no crea notificaciones: eso lo hace el backend.
     */
    @PostMapping("/save")
    public ResponseEntity<Object> save(@RequestBody Notification notification,
            @RequestHeader(value = Constants.HEADER_USER_ID, required = false) Integer callerUserId,
            @RequestHeader(value = Constants.PARAMETER_AUTHORIZED_TOKEN, required = false) String authorizedToken) {
        try {
            if (notification == null || notification.getId() == null) {
                return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.BAD_REQUEST.value(),
                        "Debe indicar el id de la notificación.", Constants.NOTIFICATION_SEARCH_KO),
                        HttpStatus.BAD_REQUEST);
            }
            Integer userId = securityUseCase.resolveCallerUserId(callerUserId, authorizedToken);
            boolean callerIsAdmin = securityUseCase.isAdministratorCaller(callerUserId, authorizedToken);
            return new ResponseEntity<>(inAppNotificationUseCase.updateState(notification.getId(),
                    notification.getIsRead(), notification.getIsDeleted(), userId, callerIsAdmin), HttpStatus.OK);
        } catch (EntityNotFoundException e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(), e.getMessage(),
                    Constants.NOTIFICATION_SEARCH_KO), HttpStatus.NOT_FOUND);
        } catch (InAppNotificationUseCase.NotificationAccessException e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.FORBIDDEN.value(), e.getMessage(),
                    Constants.NOTIFICATION_SEARCH_KO), HttpStatus.FORBIDDEN);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(), HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.NOTIFICATION_SEARCH_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /** La bandeja: a los filtros del front se suma quien consulta. */
    @PostMapping("/filter")
    public ResponseEntity<Object> filter(@RequestBody FilterRequest filterRequest,
            @RequestHeader(value = Constants.HEADER_USER_ID, required = false) Integer callerUserId,
            @RequestHeader(value = Constants.PARAMETER_AUTHORIZED_TOKEN, required = false) String authorizedToken) {
        try {
            Integer userId = securityUseCase.resolveCallerUserId(callerUserId, authorizedToken);
            boolean callerIsAdmin = securityUseCase.isAdministratorCaller(callerUserId, authorizedToken);
            Page<Notification> page = inAppNotificationUseCase.findWithFilterOptional(filterRequest, userId,
                    callerIsAdmin);
            ResponseMessage responseMessage = new ResponseMessage(page, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.NOTIFICATION_SEARCH_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(), HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.NOTIFICATION_SEARCH_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
