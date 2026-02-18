package cash.truck.domain.repositories;

import cash.truck.domain.entities.Trip;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;

@Repository
public interface TripRepository extends JpaRepository<Trip, Long> {
    Page<Trip> findAll(Specification<Trip> specification, Pageable pageable);
}
