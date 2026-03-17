package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.Expense;
import cash.truck.domain.entities.ExpenseCategory;
import cash.truck.domain.entities.Trip;
import cash.truck.domain.entities.Vehicle;
import cash.truck.domain.repositories.ExpenseCategoryRepository;
import cash.truck.domain.repositories.ExpenseRepository;
import cash.truck.domain.repositories.TripRepository;
import cash.truck.domain.repositories.VehicleRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;
import java.util.function.Consumer;

@Service
public class ExpenseUseCase {

    @Autowired
    private final ExpenseRepository expenseRepository;

    @Autowired
    private final ExpenseCategoryRepository expenseCategoryRepository;

    @Autowired
    private final VehicleRepository vehicleRepository;

    @Autowired
    private final TripRepository tripRepository;

    private final InAppNotificationUseCase inAppNotificationUseCase;

    public ExpenseUseCase(ExpenseRepository expenseRepository, ExpenseCategoryRepository expenseCategoryRepository,
            VehicleRepository vehicleRepository, TripRepository tripRepository,
            InAppNotificationUseCase inAppNotificationUseCase) {
        this.expenseRepository = expenseRepository;
        this.expenseCategoryRepository = expenseCategoryRepository;
        this.vehicleRepository = vehicleRepository;
        this.tripRepository = tripRepository;
        this.inAppNotificationUseCase = inAppNotificationUseCase;
    }

    public List<Expense> getAllExpenses() {
        return expenseRepository.findAll();
    }

    public Expense save(Expense expense) {
        Expense expenseNew;
        boolean isNew = expense.getId() == null;

        if (!isNew) {
            expenseNew = expenseRepository.findById(expense.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Expense not found"));
        } else {
            expenseNew = new Expense();
        }

        applyFields(expense, expenseNew);
        Expense savedExpense = expenseRepository.save(expenseNew);

        // Determine type: Mantenimiento (expense_type_id == 4) or Gasto
        String expenseType = "Gasto";
        try {
            if (savedExpense.getCategoryId() != null) {
                ExpenseCategory category = expenseCategoryRepository.findById(savedExpense.getCategoryId()).orElse(null);
                if (category != null && Integer.valueOf(4).equals(category.getExpenseTypeId())) {
                    expenseType = "Mantenimiento";
                }
            }
        } catch (Exception e) {
            // Use default "Gasto"
        }

        // Retrieve vehicle plate and owner
        String plate = null;
        Long ownerId = null;
        try {
            if (savedExpense.getVehicleId() != null) {
                Vehicle vehicle = vehicleRepository.findById(savedExpense.getVehicleId()).orElse(null);
                if (vehicle != null) {
                    plate = vehicle.getPlate() != null ? vehicle.getPlate().toUpperCase() : null;
                    if (vehicle.getOwners() != null && !vehicle.getOwners().isEmpty()) {
                        ownerId = vehicle.getOwners().get(0).getOwnerId();
                    }
                }
            }
        } catch (Exception e) {
            // Handle error
        }

        // Retrieve trip number
        String tripNumber = null;
        try {
            if (savedExpense.getTripId() != null) {
                Trip trip = tripRepository.findById(savedExpense.getTripId()).orElse(null);
                if (trip != null) {
                    tripNumber = trip.getNumberTrip();
                }
            }
        } catch (Exception e) {
            // Handle error
        }

        // Build notification message
        StringBuilder messageBuilder = new StringBuilder();
        // Format amount with $ sign and thousand separators (Colombian locale)
        NumberFormat nf = NumberFormat.getNumberInstance(new Locale("es", "CO"));
        String formattedAmount = "$" + nf.format(savedExpense.getAmount());

        if (isNew) {
            messageBuilder.append("Se ha registrado un nuevo ").append(expenseType)
                    .append(" por el valor de: ").append(formattedAmount);
        } else {
            messageBuilder.append("Se ha actualizado el ").append(expenseType)
                    .append(" por el valor de: ").append(formattedAmount);
        }
        // Gasto: include trip number if available; Mantenimiento: skip trip number
        if (!"Mantenimiento".equals(expenseType) && tripNumber != null) {
            messageBuilder.append(" para el viaje nro: ").append(tripNumber);
        }
        if (plate != null) {
            messageBuilder.append(" del vehículo de placa: ").append(plate);
        }

        inAppNotificationUseCase.createNotification("EXPENSE_EVENT", messageBuilder.toString(), 1, null, ownerId, savedExpense.getId());

        return savedExpense;
    }

    public List<ExpenseCategory> getAllExpenseCategories() {
        return expenseCategoryRepository.findAll();
    }

    public Page<ExpenseCategory> findExpenseCategoriesWithFilter(FilterRequest filterRequest) {
        Pageable pageable = UtilsFilter.getPageable(filterRequest);
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<ExpenseCategory> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        if (specification != null) {
            return expenseCategoryRepository.findAll(specification, pageable);
        } else {
            return expenseCategoryRepository.findAll(pageable);
        }
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

    public ExpenseCategory saveExpenseCategory(ExpenseCategory expenseCategory) {
        ExpenseCategory expenseCategoryNew;
        boolean isNew = expenseCategory.getId() == null;

        if (!isNew) {
            expenseCategoryNew = expenseCategoryRepository.findById(expenseCategory.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Expense Category not found"));
        } else {
            expenseCategoryNew = new ExpenseCategory();
        }

        applyExpenseCategoryFields(expenseCategory, expenseCategoryNew);
        return expenseCategoryRepository.save(expenseCategoryNew);
    }

    private void applyExpenseCategoryFields(ExpenseCategory source, ExpenseCategory target) {
        setIfNotNull(source.getName(), target::setName);
        setIfNotNull(source.getExpenseTypeId(), target::setExpenseTypeId);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }
}
