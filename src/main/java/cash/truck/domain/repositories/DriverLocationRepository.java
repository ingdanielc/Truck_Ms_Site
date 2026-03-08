package cash.truck.domain.repositories;

import cash.truck.domain.entities.DriverLocation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DriverLocationRepository extends JpaRepository<DriverLocation, Long> {

    Page<DriverLocation> findAll(Specification<DriverLocation> specification, Pageable pageable);

}
