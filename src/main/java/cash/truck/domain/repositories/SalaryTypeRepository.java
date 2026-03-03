package cash.truck.domain.repositories;

import cash.truck.domain.entities.SalaryType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SalaryTypeRepository extends JpaRepository<SalaryType, Integer> {
}
