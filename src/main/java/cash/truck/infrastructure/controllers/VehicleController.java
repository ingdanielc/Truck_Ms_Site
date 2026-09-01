package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.DocumentValidationException;
import cash.truck.application.exception.PartnerException;
import cash.truck.application.usecases.DocumentFileUseCase;
import cash.truck.application.usecases.VehicleUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.domain.entities.DocumentFile;
import cash.truck.domain.entities.Vehicle;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping(value = "/vehicle", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = { "http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/",
        "https://truck.ccsoluciones.com.co/" })
public class VehicleController {

    @Autowired
    private VehicleUseCase vehicleUseCase;

    @Autowired
    private cash.truck.application.usecases.VehicleOwnerUseCase vehicleOwnerUseCase;

    @Autowired
    private DocumentFileUseCase documentFileUseCase;

    @GetMapping("/getAllVehicles")
    public ResponseEntity<Object> getAllVehicles() {
        ResponseMessage responseMessage = new ResponseMessage(vehicleUseCase.getAllVehicles(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.VEHICLE_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping("/save")
    public ResponseEntity<Object> save(@RequestBody Vehicle vehicle) {
        try {
            Vehicle saved = vehicleUseCase.save(vehicle);
            ResponseMessage responseMessage = new ResponseMessage(saved, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.VEHICLE_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    Constants.VEHICLE_SEARCH_NOT_FOUND_ME, Constants.VEHICLE_SEARCH_NOT_FOUND);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (PartnerException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.CONFLICT.value(),
                    e.getMessage(), Constants.VEHICLE_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.CONFLICT);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.VEHICLE_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/filter")
    public ResponseEntity<Object> filter(@RequestBody FilterRequest filterRequest) {
        try {
            Page<Vehicle> page = vehicleUseCase.findWithFilterOptional(filterRequest);
            ResponseMessage responseMessage = new ResponseMessage(page, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.VEHICLE_SEARCH_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.VEHICLE_SEARCH_KO),
                    HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/filterVehicleOwner")
    public ResponseEntity<Object> filterVehicleOwner(@RequestBody FilterRequest filterRequest) {
        try {
            Page<Vehicle> page = vehicleOwnerUseCase
                    .findWithFilterOptional(filterRequest);
            ResponseMessage responseMessage = new ResponseMessage(page, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.VEHICLE_SEARCH_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.VEHICLE_SEARCH_KO),
                    HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/counts")
    public ResponseEntity<Object> getCounts(@RequestBody FilterRequest filterRequest) {
        try {
            return new ResponseEntity<>(new ResponseMessage(vehicleUseCase.getCounts(filterRequest),
                    HttpStatus.OK.value(), HttpStatus.OK.name(), null, Constants.VEHICLE_SEARCH_OK), HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.VEHICLE_SEARCH_KO),
                    HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Alta y actualizacion de documentos en una sola llamada: el front manda la
     * lista completa y cada elemento sin id se crea, con id se actualiza. Va
     * aparte del guardado del vehiculo porque ocurre en otro momento.
     *
     * Al guardar un documento activo de un tipo que ya tenia uno vigente, el
     * anterior queda inactivo en lugar de perderse.
     */
    @PostMapping("/saveDocuments")
    public ResponseEntity<Object> saveDocuments(@RequestBody List<DocumentFile> documents) {
        try {
            List<DocumentFile> saved = documentFileUseCase.saveAll(documents);
            ResponseMessage responseMessage = new ResponseMessage(saved, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.DOCUMENT_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (DocumentValidationException e) {
            return documentError(HttpStatus.BAD_REQUEST, e.getMessage(), Constants.DOCUMENT_KO);
        } catch (EntityNotFoundException e) {
            return documentError(HttpStatus.NOT_FOUND, e.getMessage(), Constants.DOCUMENT_SEARCH_NOT_FOUND);
        } catch (DataIntegrityViolationException | PartnerException | IllegalArgumentException e) {
            return documentError(HttpStatus.CONFLICT, e.getMessage(), Constants.DOCUMENT_KO);
        } catch (Exception e) {
            return documentError(HttpStatus.INTERNAL_SERVER_ERROR, HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.DOCUMENT_KO);
        }
    }

    /**
     * Documentos por vehiculo, con el mismo vocabulario de filtros del resto:
     * {"fieldFilter":"vehicleId","compFilter":"=","valueFilter":"12"} y, para
     * ver solo los vigentes, isActive = true.
     */
    @PostMapping("/filterDocuments")
    public ResponseEntity<Object> filterDocuments(@RequestBody FilterRequest filterRequest) {
        try {
            Page<DocumentFile> page = documentFileUseCase.findWithFilterOptional(filterRequest);
            ResponseMessage responseMessage = new ResponseMessage(page, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.DOCUMENT_SEARCH_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return documentError(HttpStatus.INTERNAL_SERVER_ERROR, HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.DOCUMENT_SEARCH_KO);
        }
    }

    /**
     * Borrado real, para el documento cargado por error. La renovacion no pasa
     * por aqui: esa desactiva y conserva el historico.
     */
    @DeleteMapping("/documents/{id}")
    public ResponseEntity<Object> deleteDocument(@PathVariable Long id) {
        try {
            documentFileUseCase.delete(id);
            ResponseMessage responseMessage = new ResponseMessage(null, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.DOCUMENT_DELETED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (EntityNotFoundException e) {
            return documentError(HttpStatus.NOT_FOUND, e.getMessage(), Constants.DOCUMENT_SEARCH_NOT_FOUND);
        } catch (Exception e) {
            return documentError(HttpStatus.INTERNAL_SERVER_ERROR, HttpStatus.INTERNAL_SERVER_ERROR.name(),
                    Constants.DOCUMENT_KO);
        }
    }

    private ResponseEntity<Object> documentError(HttpStatus status, String message, String i18n) {
        return new ResponseEntity<>(new ResponseErrorMessage(status.value(), message, i18n), status);
    }

    @PostMapping("/{id}/sell")
    public ResponseEntity<Object> sellVehicle(@PathVariable Long id) {
        try {
            vehicleUseCase.sellVehicle(id);
            ResponseMessage responseMessage = new ResponseMessage(null, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, "Vehículo vendido exitosamente");
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    e.getMessage(), Constants.VEHICLE_SEARCH_NOT_FOUND);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    e.getMessage(), Constants.VEHICLE_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
