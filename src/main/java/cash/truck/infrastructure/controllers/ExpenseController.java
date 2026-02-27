package cash.truck.infrastructure.controllers;

import cash.truck.application.exception.PartnerException;
import cash.truck.application.usecases.ExpenseUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.ResponseErrorMessage;
import cash.truck.application.utility.ResponseMessage;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.domain.entities.Expense;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/expense", produces = MediaType.APPLICATION_JSON_VALUE)
@CrossOrigin(origins = { "http://localhost:9000", "http://168.231.93.145/", "http://truck.ccsoluciones.com.co/",
        "https://truck.ccsoluciones.com.co/" })
public class ExpenseController {

    @Autowired
    private ExpenseUseCase expenseUseCase;

    @GetMapping("/getAllExpenses")
    public ResponseEntity<Object> getAllExpenses() {
        ResponseMessage responseMessage = new ResponseMessage(expenseUseCase.getAllExpenses(), HttpStatus.OK.value(),
                HttpStatus.OK.name(), null, Constants.EXPENSE_SEARCH_OK);
        return new ResponseEntity<>(responseMessage, HttpStatus.OK);
    }

    @PostMapping("/save")
    public ResponseEntity<Object> save(@RequestBody Expense expense) {
        try {
            Expense saved = expenseUseCase.save(expense);
            ResponseMessage responseMessage = new ResponseMessage(saved, HttpStatus.CREATED.value(),
                    HttpStatus.CREATED.name(), null, Constants.EXPENSE_CREATED_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.CREATED);
        } catch (EntityNotFoundException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.NOT_FOUND.value(),
                    Constants.EXPENSE_SEARCH_NOT_FOUND_ME, Constants.EXPENSE_SEARCH_NOT_FOUND);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.NOT_FOUND);
        } catch (PartnerException | IllegalArgumentException e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(HttpStatus.CONFLICT.value(),
                    e.getMessage(), Constants.EXPENSE_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.CONFLICT);
        } catch (Exception e) {
            ResponseErrorMessage responseErrorMessage = new ResponseErrorMessage(
                    HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.EXPENSE_KO);
            return new ResponseEntity<>(responseErrorMessage, HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @PostMapping("/filter")
    public ResponseEntity<Object> filter(@RequestBody FilterRequest filterRequest) {
        try {
            Page<Expense> page = expenseUseCase.findWithFilterOptional(filterRequest);
            ResponseMessage responseMessage = new ResponseMessage(page, HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.EXPENSE_SEARCH_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.EXPENSE_SEARCH_KO),
                    HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }

    @GetMapping("/filterExpenseCategory")
    public ResponseEntity<Object> filterExpenseCategory() {
        try {
            ResponseMessage responseMessage = new ResponseMessage(expenseUseCase.getAllExpenseCategories(),
                    HttpStatus.OK.value(),
                    HttpStatus.OK.name(), null, Constants.EXPENSE_CATEGORY_SEARCH_OK);
            return new ResponseEntity<>(responseMessage, HttpStatus.OK);
        } catch (Exception e) {
            return new ResponseEntity<>(new ResponseErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR.value(),
                    HttpStatus.INTERNAL_SERVER_ERROR.name(), Constants.EXPENSE_SEARCH_KO),
                    HttpStatus.INTERNAL_SERVER_ERROR);
        }
    }
}
