package cash.truck.domain.repositories;

import cash.truck.domain.entities.Owner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;

@Repository
public interface OwnerRepository extends JpaRepository<Owner, Long> {
    Page<Owner> findAll(Specification<Owner> specification, Pageable pageable);
}
