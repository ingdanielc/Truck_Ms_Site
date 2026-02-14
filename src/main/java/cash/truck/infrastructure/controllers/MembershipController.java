package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.MembershipException;
import cash.truck.application.usecases.MembershipUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.domain.entities.Membership;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/membership", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = {"http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/"})
public class MembershipController {

    @Autowired
    private MembershipUseCase membershipUseCase;

    @GetMapping("/getAllMemberships")
    public ResponseEntity<Object> getAllMembeships() {
        ResponseMessage responseMessage = new ResponseMessage(membershipUseCase.getAllMemberships(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.MEMBERSHIP_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping("/save")
    public ResponseEntity<Object> createOrUpdateMembership(@RequestBody Membership membership) {
        try {
            Membership membershipSave = membershipUseCase.saveMembership(membership);
            ResponseMessage responseMessage = new ResponseMessage(membershipSave, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.MEMBERSHIP_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    Constants.MEMBERSHIP_SEARCH_NOT_FOUND_ME, Constants.MEMBERSHIP_SEARCH_NOT_FOUND);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (MembershipException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.CONFLICT.value(), e.getMessage(), Constants.MEMBERSHIP_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.CONFLICT);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.MEMBERSHIP_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/filter")
    public ResponseEntity<Object> filter(@RequestBody FilterRequest filterRequest) {
        try {
            Page<Membership> membershipPage = membershipUseCase.findWithFilterOptional(filterRequest);

            ResponseMessage responseMessage = new ResponseMessage(membershipPage, HttpStatus.OK.value(), HttpStatus.OK.name(),
                    null, Constants.PARTNER_SEARCH_OK);

            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.MEMBERSHIP_SEARCH_KO), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/getAllMembershipTypes")
    public ResponseEntity<Object> getAllMembeshipTypes() {
        ResponseMessage responseMessage = new ResponseMessage(membershipUseCase.getAllMembershipTypes(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.MEMBERSHIP_TYPES_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }
}

