package cash.truck.domain.repositories;

import cash.truck.domain.entities.PartnerMembership;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PartnerMembershipRepository extends JpaRepository<PartnerMembership, Long> {
    Optional<PartnerMembership> findByPartnerIdAndMembershipId(Long partnerId, Long membershipId);
    Optional<PartnerMembership> findByPartnerIdAndMembershipIdAndStatus(Long partnerId, Long membershipId, String status);
    List<PartnerMembership> findByPartnerId(Long partnerId);
}
