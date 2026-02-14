package cash.truck.application.usecases;

import cash.truck.domain.entities.PartnerMembership;
import cash.truck.domain.repositories.PartnerMembershipRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PartnerMembershipUseCase {

    @Autowired
    private PartnerMembershipRepository partnerMembershipRepository;

    public List<PartnerMembership> getAllPartnerMemberships() {
        return partnerMembershipRepository.findAll();
    }
}
