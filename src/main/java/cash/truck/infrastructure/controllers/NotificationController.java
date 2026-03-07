package cash.truck.infrastructure.controllers;

import cash.truck.application.usecases.InAppNotificationUseCase;
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

    @PostMapping("/save")
    public ResponseEntity<Object> save(@RequestBody Notification notification) {
        try {
            return new ResponseEntity<>(inAppNotificationUseCase.saveNotification(notification), HttpStatus.OK);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(), HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.NOTIFICATION_SEARCH_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/filter")
    public ResponseEntity<Object> filter(@RequestBody FilterRequest filterRequest) {
        try {
            Page<Notification> page = inAppNotificationUseCase.findWithFilterOptional(filterRequest);
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
