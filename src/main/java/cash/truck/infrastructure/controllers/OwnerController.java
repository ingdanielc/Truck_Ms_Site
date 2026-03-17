package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.PartnerException;
import cash.truck.application.usecases.OwnerUseCase;
import cash.truck.application.usecases.SecurityUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.domain.entities.*;
import cash.truck.domain.repositories.RolesRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import java.util.Collections;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/owner", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = { "http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/",
        "https://truck.ccsoluciones.com.co/" })
public class OwnerController {

    @Autowired
    private OwnerUseCase ownerUseCase;

    @Autowired
    private SecurityUseCase securityUseCase;

    @Autowired
    private RolesRepository rolesRepository;

    @GetMapping("/getAllOwners")
    public ResponseEntity<Object> getAllOwners() {
        ResponseMessage responseMessage = new ResponseMessage(ownerUseCase.getAllOwners(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.OWNER_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping("/save")
    public ResponseEntity<Object> save(@RequestBody Owner owner) {
        try {
            if (owner.getId() == null) {
                Users user = new Users();
                user.setName(owner.getName());
                user.setEmail(owner.getEmail());
                user.setPassword(SecurityUseCase.getHashSHA512(owner.getPassword()));
                user.setStatus(Constants.STATUS_ACTIVE);

                Roles role = rolesRepository.findById(2)
                        .orElseThrow(() -> new EntityNotFoundException("Role Owner not found"));

                UserRole userRole = new UserRole();
                userRole.setRole(role);
                userRole.setUser(user);
                user.setUserRoles(Collections.singletonList(userRole));

                Users savedUser = securityUseCase.saveUser(user);
                owner.setUser(savedUser);
            }
            Owner saved = ownerUseCase.save(owner);
            ResponseMessage responseMessage = new ResponseMessage(saved, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.OWNER_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    Constants.OWNER_SEARCH_NOT_FOUND_ME, Constants.OWNER_SEARCH_NOT_FOUND);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (PartnerException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.CONFLICT.value(),
                    e.getMessage(), Constants.OWNER_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.CONFLICT);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.OWNER_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/filter")
    public ResponseEntity<Object> filter(@RequestBody FilterRequest filterRequest) {
        try {
            Page<Owner> page = ownerUseCase.findWithFilterOptional(filterRequest);
            ResponseMessage responseMessage = new ResponseMessage(page, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.OWNER_SEARCH_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.OWNER_SEARCH_KO),
                    HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/setVehicle")
    public ResponseEntity<Object> setVehicle(@RequestBody VehicleOwner vehicleOwner) {
        try {
            VehicleOwner saved = ownerUseCase.setVehicle(vehicleOwner);
            ResponseMessage responseMessage = new ResponseMessage(saved, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.OWNER_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (PartnerException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.CONFLICT.value(),
                    e.getMessage(), Constants.OWNER_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.CONFLICT);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.OWNER_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
