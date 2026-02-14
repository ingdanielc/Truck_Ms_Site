package cash.truck.domain.repositories;

import cash.truck.domain.entities.BiometricData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BiometricDataRepository extends JpaRepository<BiometricData, Long> {

}
