package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.MembershipException;
import cash.truck.application.exception.PartnerException;
import cash.truck.application.usecases.PartnerUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.domain.entities.BiometricData;
import cash.truck.domain.entities.Partner;
import cash.truck.domain.entities.PartnerMembership;
import jakarta.persistence.EntityNotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "/partner", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = {"http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/"})
public class PartnerController {

    private static final Logger logger = LoggerFactory.getLogger(PartnerController.class);

    @Autowired
    private PartnerUseCase partnerUseCase;

    @GetMapping("/getAllPartners")
    public ResponseEntity<Object> getAllPartners() {
        ResponseMessage responseMessage = new ResponseMessage(partnerUseCase.getAllPartners(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.PARTNER_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping("/save")
    public ResponseEntity<Object> createOrUpdatePartner(@RequestBody Partner partner) {
        try {
            Partner partnerSave = partnerUseCase.savePartner(partner);
            ResponseMessage responseMessage = new ResponseMessage(partnerSave, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.PARTNER_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    Constants.PARTNER_SEARCH_NOT_FOUND_ME, Constants.PARTNER_SEARCH_NOT_FOUND);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (PartnerException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.CONFLICT.value(), e.getMessage(), Constants.PARTNER_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.CONFLICT);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.PARTNER_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/filter")
    public ResponseEntity<Object> filter(@RequestBody FilterRequest filterRequest) {
        try {
            Page<Partner> partnerPage = partnerUseCase.findWithFilterOptional(filterRequest);

            ResponseMessage responseMessage = new ResponseMessage(partnerPage, HttpStatus.OK.value(), HttpStatus.OK.name(),
                    null, Constants.PARTNER_SEARCH_OK);

            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.PARTNER_SEARCH_KO), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/saveBiometric")
    public BiometricData saveBiometricData(@RequestBody BiometricData biometricData) {
        return partnerUseCase.saveBiometricData(biometricData);
    }

    @PostMapping("/setMembership")
    public ResponseEntity<Object> savePartnerMembership(@RequestBody PartnerMembership partnerMembership) {
        try {
            PartnerMembership partnerMembershipSave = partnerUseCase.savePartnerMembership(partnerMembership);
            ResponseMessage responseMessage = new ResponseMessage(partnerMembershipSave, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.PARTNER_MEMBERSHIP_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    Constants.PARTNER_MEMBERSHIP_SEARCH_NOT_FOUND_ME, Constants.PARTNER_MEMBERSHIP_SEARCH_NOT_FOUND);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (MembershipException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.CONFLICT.value(), e.getMessage(), Constants.PARTNER_MEMBERSHIP_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.CONFLICT);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.PARTNER_MEMBERSHIP_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/getMembershipsByPartner/{partnerId}")
    public ResponseEntity<Object> getPartnerMembershipByPartner(@PathVariable Long partnerId) {
        ResponseMessage responseMessage = new ResponseMessage(partnerUseCase.getPartnerMembershipsByPartner(partnerId), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.PARTNER_MEMBERSHIP_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @GetMapping("/birthdays")
    public ResponseEntity<Object> getPartnersWithBirthdayToday() {
        try {
            List<Partner> partnerList = partnerUseCase.getPartnersWithBirthdayToday();

            ResponseMessage responseMessage = new ResponseMessage(partnerList, HttpStatus.OK.value(), HttpStatus.OK.name(),
                    null, Constants.PARTNER_SEARCH_OK);

            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.PARTNER_SEARCH_KO), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/inactives/{days}")
    public ResponseEntity<Object> getInactivePartners(@PathVariable Integer days) {
        try {
            List<Partner> partnerList = partnerUseCase.getInactivePartners(days);

            ResponseMessage responseMessage = new ResponseMessage(partnerList, HttpStatus.OK.value(), HttpStatus.OK.name(),
                    null, Constants.PARTNER_SEARCH_OK);

            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.PARTNER_SEARCH_KO), HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}

