package cash.truck.domain.repositories;

import cash.truck.domain.entities.ExpenseCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

@Repository
public interface ExpenseCategoryRepository
        extends JpaRepository<ExpenseCategory, Integer>, JpaSpecificationExecutor<ExpenseCategory> {

}
