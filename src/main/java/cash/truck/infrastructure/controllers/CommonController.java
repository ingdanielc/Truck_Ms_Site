package cash.truck.infrastructure.controllers;

import cash.truck.application.usecases.*;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseMessage;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/common", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = { "http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/" })
public class CommonController {

    @Autowired
    private CommonUseCase commonUseCase;

    @GetMapping("/getDocumentTypes")
    public ResponseEntity<Object> getAllDocuments() {
        ResponseMessage responseMessage = new ResponseMessage(commonUseCase.getAllDocumentTypes(),
                HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.DOCUMENT_TYPES_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @GetMapping("/getGenders")
    public ResponseEntity<Object> getAllGenders() {
        ResponseMessage responseMessage = new ResponseMessage(commonUseCase.getAllGenders(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.GENDERS_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @GetMapping("/getCities")
    public ResponseEntity<Object> getCities() {
        ResponseMessage responseMessage = new ResponseMessage(commonUseCase.getAllCities(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.CITIES_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @GetMapping("/getExpenseTypes")
    public ResponseEntity<Object> getExpenseTypes() {
        ResponseMessage responseMessage = new ResponseMessage(commonUseCase.getAllExpenseTypes(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.EXPENSE_TYPES_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @GetMapping("/getVehicleBrands")
    public ResponseEntity<Object> getVehicleBrands() {
        ResponseMessage responseMessage = new ResponseMessage(commonUseCase.getAllVehicleBrands(),
                HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.VEHICLE_BRANDS_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

}
