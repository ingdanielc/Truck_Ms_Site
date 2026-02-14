package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.PartnerException;
import cash.truck.application.usecases.PaymentUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.domain.entities.Payment;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/payment", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = {"http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/"})
public class PaymentController {

    @Autowired
    private PaymentUseCase paymentUseCase;

    @GetMapping("/getAllPayments")
    public ResponseEntity<Object> getAllPayments() {
        ResponseMessage responseMessage = new ResponseMessage(paymentUseCase.getAllPayments(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.PAYMENTS_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping("save")
    public ResponseEntity<Object> savePayment(@RequestBody Payment payment) {
        try {
            Payment paymentSave = paymentUseCase.savePayment(payment);
            ResponseMessage responseMessage = new ResponseMessage(paymentSave, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.PAYMENT_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    Constants.PAYMENT_SEARCH_NOT_FOUND_ME, Constants.PAYMENT_SEARCH_NOT_FOUND);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (PartnerException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.CONFLICT.value(), e.getMessage(), Constants.PAYMENT_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.CONFLICT);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.PAYMENT_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/filter")
    public ResponseEntity<Object> filter(@RequestBody FilterRequest filterRequest) {
        try {
            Page<Payment> paymentPage = paymentUseCase.findWithFilterOptional(filterRequest);

            ResponseMessage responseMessage = new ResponseMessage(paymentPage, HttpStatus.OK.value(), HttpStatus.OK.name(),
                    null, Constants.PAYMENTS_SEARCH_OK);

            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.PAYMENT_SEARCH_KO), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/getAllPaymentMethods")
    public ResponseEntity<Object> getAllPaymentMethods() {
        ResponseMessage responseMessage = new ResponseMessage(paymentUseCase.getAllPaymentMethods(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.PAYMENT_METHODS_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }
}

