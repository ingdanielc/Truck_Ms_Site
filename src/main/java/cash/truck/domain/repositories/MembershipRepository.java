package cash.truck.domain.repositories;

import cash.truck.domain.entities.Membership;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MembershipRepository extends JpaRepository<Membership, Long> {
    Optional<Membership> findByNameAndMembershipTypeId(String name, Long membershipTypeId);
    Page<Membership> findAll(Specification<Membership> specification, Pageable pageable);
}
