package cash.truck.domain.repositories;

import cash.truck.domain.entities.AccessControl;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AccessControlRepository extends JpaRepository<AccessControl, Long> {
    List<AccessControl> findByPartnerId(Long partnerId);
    Page<AccessControl> findAll(Specification<AccessControl> specification, Pageable pageable);
}
