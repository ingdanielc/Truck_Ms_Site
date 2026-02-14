package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.PartnerException;
import cash.truck.application.usecases.AccessControlUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.domain.entities.AccessControl;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/access-control", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = {"http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/"})
public class AccessControlController {

    @Autowired
    private AccessControlUseCase accessControlUseCase;

    @GetMapping("/getAllAccessControls")
    public ResponseEntity<Object> getAllAccessControls() {
        ResponseMessage responseMessage = new ResponseMessage(accessControlUseCase.getAllAccessControls(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.ACCESS_CONTROL_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping("save")
    public ResponseEntity<Object> saveAccessControl(@RequestBody AccessControl accessControl) {
        try {
            AccessControl accessControlSave = accessControlUseCase.saveAccessControl(accessControl);
            ResponseMessage responseMessage = new ResponseMessage(accessControlSave, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.ACCESS_CONTROL_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    Constants.ACCESS_CONTROL_SEARCH_NOT_FOUND_ME, Constants.ACCESS_CONTROL_SEARCH_NOT_FOUND);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (PartnerException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.CONFLICT.value(), e.getMessage(), Constants.ACCESS_CONTROL_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.CONFLICT);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.ACCESS_CONTROL_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/filter")
    public ResponseEntity<Object> filter(@RequestBody FilterRequest filterRequest) {
        try {
            Page<AccessControl> accessControlPage = accessControlUseCase.findWithFilterOptional(filterRequest);

            ResponseMessage responseMessage = new ResponseMessage(accessControlPage, HttpStatus.OK.value(), HttpStatus.OK.name(),
                    null, Constants.ACCESS_CONTROL_SEARCH_OK);

            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.ACCESS_CONTROL_SEARCH_KO), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/count")
    public ResponseEntity<Object> count(@RequestBody FilterRequest filterRequest) {
        try {
            Page<AccessControl> accessControlPage = accessControlUseCase.findWithFilterOptional(filterRequest);
            long count = accessControlPage.stream().count();

            ResponseMessage responseMessage = new ResponseMessage(count, HttpStatus.OK.value(), HttpStatus.OK.name(),
                    null, Constants.ACCESS_CONTROL_SEARCH_OK);

            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.ACCESS_CONTROL_SEARCH_KO), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/getAccessControlByPartner/{partnerId}")
    public ResponseEntity<Object> getAccessControlByPartner(@PathVariable Long partnerId) {
        ResponseMessage responseMessage = new ResponseMessage(accessControlUseCase.getAccessControlByPartner(partnerId), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.ACCESS_CONTROL_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }
}

