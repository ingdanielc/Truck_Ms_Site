package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.ReportException;
import cash.truck.application.usecases.ReportUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.domain.dtos.reports.DashboardReportDTO;
import cash.truck.domain.dtos.reports.GroupTripsReportDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

/**
 * Reportes del tablero. Sustituye las ocho peticiones y los ~61.000 registros
 * de la carga actual por una sola llamada, con el detalle por grupo a demanda.
 *
 * Los endpoints de filtro de trip, expense y vehicle siguen en pie: son la via
 * de escape para el reporte que se salga de este vocabulario.
 */
@RestController
@RequestMapping(value = "/reports", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = { "http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/",
        "https://truck.ccsoluciones.com.co/" })
public class ReportController {

    private static final Logger logger = LoggerFactory.getLogger(ReportController.class);

    @Autowired
    private ReportUseCase reportUseCase;

    /**
     * Carga completa del tablero. groupBy y ownerId son opcionales: sin groupBy
     * la dimension la decide el rol y ownerId solo lo honra el administrador.
     */
    @GetMapping("/dashboard")
    public ResponseEntity<Object> dashboard(
            @RequestParam int year,
            @RequestParam(required = false) String groupBy,
            @RequestParam(required = false) Long ownerId,
            @RequestHeader(value = Constants.HEADER_USER_ID, required = false) Integer callerUserId,
            @RequestHeader(value = Constants.PARAMETER_AUTHORIZED_TOKEN, required = false) String authorizedToken) {
        try {
            DashboardReportDTO report = reportUseCase.buildDashboard(callerUserId, authorizedToken, year, groupBy,
                    ownerId);
            ResponseMessage responseMessage = new ResponseMessage(report, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.REPORT_DASHBOARD_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (ReportException e) {
            return reportError(e.getStatus(), e.getMessage());
        } catch (Exception e) {
            logger.error("Error construyendo el tablero: {}", e.getMessage());
            return reportError(HttpStatus.INTERNAL_SERVER_ERROR, HttpStatus.INTERNAL_SERVER_ERROR.name());
        }
    }

    /**
     * Detalle de un grupo. Se pide al tocar una barra, nunca en la carga. Sin
     * month devuelve el ano completo.
     */
    @GetMapping("/dashboard/groups/{key}/trips")
    public ResponseEntity<Object> groupTrips(
            @PathVariable String key,
            @RequestParam int year,
            @RequestParam(required = false) Integer month,
            @RequestHeader(value = Constants.HEADER_USER_ID, required = false) Integer callerUserId,
            @RequestHeader(value = Constants.PARAMETER_AUTHORIZED_TOKEN, required = false) String authorizedToken) {
        try {
            GroupTripsReportDTO report = reportUseCase.buildGroupTrips(callerUserId, authorizedToken, key, year, month);
            ResponseMessage responseMessage = new ResponseMessage(report, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.REPORT_GROUP_TRIPS_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (ReportException e) {
            return reportError(e.getStatus(), e.getMessage());
        } catch (Exception e) {
            logger.error("Error construyendo el detalle del grupo {}: {}", key, e.getMessage());
            return reportError(HttpStatus.INTERNAL_SERVER_ERROR, HttpStatus.INTERNAL_SERVER_ERROR.name());
        }
    }

    /**
     * year ausente o un month que no es numero fallan en el binding, antes de
     * llegar al caso de uso. Sin esto Spring responde su propio cuerpo de error
     * y el front tendria que distinguir dos formas para el mismo endpoint.
     */
    @ExceptionHandler({ MissingServletRequestParameterException.class, MethodArgumentTypeMismatchException.class })
    public ResponseEntity<Object> handleBadRequest(Exception e) {
        return reportError(HttpStatus.BAD_REQUEST, e.getMessage());
    }

    private ResponseEntity<Object> reportError(HttpStatus status, String message) {
        return new ResponseEntity<>(new ResponseErrorMessage(status.value(), message, Constants.REPORT_KO), status);
    }
}
