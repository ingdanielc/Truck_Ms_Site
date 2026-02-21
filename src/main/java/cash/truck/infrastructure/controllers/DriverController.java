package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.PartnerException;
import cash.truck.application.usecases.DriverUseCase;
import cash.truck.application.usecases.SecurityUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.domain.entities.*;
import cash.truck.domain.repositories.RolesRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;

@RestController
@RequestMapping(value = "/driver", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = { "http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/",
        "https://truck.ccsoluciones.com.co/" })
public class DriverController {

    @Autowired
    private DriverUseCase driverUseCase;

    @Autowired
    private SecurityUseCase securityUseCase;

    @Autowired
    private RolesRepository rolesRepository;

    @GetMapping("/getAllDrivers")
    public ResponseEntity<Object> getAllDrivers() {
        ResponseMessage responseMessage = new ResponseMessage(driverUseCase.getAllDrivers(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, "driver.search.ok");
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping("/save")
    public ResponseEntity<Object> save(@RequestBody Driver driver) {
        try {
            if (driver.getId() == null && driver.getPassword() != null && !driver.getPassword().isEmpty()) {
                Users user = new Users();
                user.setName(driver.getName());
                user.setEmail(driver.getEmail());
                user.setPassword(SecurityUseCase.getHashSHA512(driver.getPassword()));
                user.setStatus(Constants.STATUS_ACTIVE);

                Roles role = rolesRepository.findById(3)
                        .orElseThrow(() -> new EntityNotFoundException("Role Driver not found"));

                UserRole userRole = new UserRole();
                userRole.setRole(role);
                userRole.setUser(user);
                user.setUserRoles(Collections.singletonList(userRole));

                Users savedUser = securityUseCase.saveUser(user);
                driver.setUser(savedUser);
            }
            Driver saved = driverUseCase.save(driver);
            ResponseMessage responseMessage = new ResponseMessage(saved, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, "driver.created.ok");
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    "Driver Not Found", "driver.search.not.found");
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (PartnerException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.CONFLICT.value(),
                    e.getMessage(), "driver.ko");
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.CONFLICT);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), "driver.ko");
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/filter")
    public ResponseEntity<Object> filter(@RequestBody FilterRequest filterRequest) {
        try {
            return new ResponseEntity<>(new ResponseMessage(driverUseCase.findWithFilterOptional(filterRequest),
                    HttpStatus.OK.value(), HttpStatus.OK.name(), null, "driver.search.ok"), HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), "driver.search.ko"),
                    HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
