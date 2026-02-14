package cash.truck.infrastructure.controllers;

import cash.truck.application.usecases.notifications.EmailMessageUseCase;
import cash.truck.application.usecases.notifications.SmsMessageUseCase;
import cash.truck.application.usecases.notifications.WhatsappMessageUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.domain.dtos.MessageRequest;
import cash.truck.domain.entities.notifications.Audit;
import cash.truck.domain.enums.MediumEnum;
import lombok.AllArgsConstructor;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/notifications", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = {"http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/"})
@AllArgsConstructor
public class NotificationController {

    private static final Logger logger = LoggerFactory.getLogger(NotificationController.class);
    private final WhatsappMessageUseCase whatsappMessageUseCase;
    private final SmsMessageUseCase smsMessageUseCase;
    private final EmailMessageUseCase emailMessageUseCase;

    @PostMapping("/sendMessages")
    public ResponseEntity<Object> sendMessages(@RequestBody MessageRequest messageRequest) {
        try {
            MediumEnum mediumEnum = MediumEnum.fromName(messageRequest.getMedium());
            switch (mediumEnum) {
                case SMS -> smsMessageUseCase.sendSms(messageRequest, new Audit());
                case EMAIL -> emailMessageUseCase.sendEmail(messageRequest, new Audit());
                default -> whatsappMessageUseCase.sendWhatsApp(messageRequest, new Audit());
            }
            ResponseMessage responseMessage = new ResponseMessage("processed", HttpStatus.OK.value(), HttpStatus.OK.name(), null, Constants.NOTIFICATION_SEARCH_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(), HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.NOTIFICATION_SEARCH_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
