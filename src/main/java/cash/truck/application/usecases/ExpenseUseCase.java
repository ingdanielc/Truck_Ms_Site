package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.Expense;
import cash.truck.domain.entities.ExpenseCategory;
import cash.truck.domain.repositories.ExpenseCategoryRepository;
import cash.truck.domain.repositories.ExpenseRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.function.Consumer;

@Service
public class ExpenseUseCase {

    @Autowired
    private final ExpenseRepository expenseRepository;

    @Autowired
    private final ExpenseCategoryRepository expenseCategoryRepository;

    public ExpenseUseCase(ExpenseRepository expenseRepository, ExpenseCategoryRepository expenseCategoryRepository) {
        this.expenseRepository = expenseRepository;
        this.expenseCategoryRepository = expenseCategoryRepository;
    }

    public List<Expense> getAllExpenses() {
        return expenseRepository.findAll();
    }

    public Expense save(Expense expense) {
        Expense expenseNew;

        if (expense.getId() != null) {
            expenseNew = expenseRepository.findById(expense.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Expense not found"));
        } else {
            expenseNew = new Expense();
        }

        applyFields(expense, expenseNew);
        return expenseRepository.save(expenseNew);
    }

    public List<ExpenseCategory> getAllExpenseCategories() {
        return expenseCategoryRepository.findAll();
    }

    public Page<Expense> findWithFilterOptional(FilterRequest filterRequest) {
        Pageable pageable = UtilsFilter.getPageable(filterRequest);
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<Expense> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        if (specification != null) {
            return expenseRepository.findAll(specification, pageable);
        } else {
            return expenseRepository.findAll(pageable);
        }
    }

    private void applyFields(Expense source, Expense target) {
        setIfNotNull(source.getVehicleId(), target::setVehicleId);
        setIfNotNull(source.getTripId(), target::setTripId);
        setIfNotNull(source.getCategoryId(), target::setCategoryId);
        setIfNotNull(source.getAmount(), target::setAmount);
        setIfNotNull(source.getExpenseDate(), target::setExpenseDate);
        setIfNotNull(source.getDescription(), target::setDescription);
        setIfNotNull(source.getReceiptImageUrl(), target::setReceiptImageUrl);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }
}
