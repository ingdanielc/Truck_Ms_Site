package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.Expires;
import cash.truck.domain.entities.Membership;
import cash.truck.domain.entities.MembershipType;
import cash.truck.domain.repositories.ExpiresRepository;
import cash.truck.domain.repositories.MembershipRepository;
import cash.truck.domain.repositories.MembershipTypeRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.function.Consumer;

import static cash.truck.application.exception.MembershipException.duplicateEntityException;

@Service
public class MembershipUseCase {

    @Autowired
    private final MembershipRepository membershipRepository;
    private final MembershipTypeRepository membershipTypeRepository;
    private final ExpiresRepository expiresRepository;

    public MembershipUseCase(MembershipRepository membershipRepository,
                             MembershipTypeRepository membershipTypeRepository,
                             ExpiresRepository expiresRepository){
        this.membershipRepository = membershipRepository;
        this.membershipTypeRepository = membershipTypeRepository;
        this.expiresRepository = expiresRepository;
    }

    public List<Membership> getAllMemberships() {
        return membershipRepository.findAll();
    }

    public Membership saveMembership(Membership membership) {
        Membership membershipNew;

        // Validate duplicated
        if (membership.getName() != null && membership.getMembershipTypeId() != null) {
            Optional<Membership> existingMembership = membershipRepository.findByNameAndMembershipTypeId(
                    membership.getName(),
                    membership.getMembershipTypeId()
            );
            if (existingMembership.isPresent() &&
                    (membership.getId() == null ||
                            !existingMembership.get().getId().equals(membership.getId()))) {
                throw duplicateEntityException();
            }
        }
        if (membership.getId() != null) {
            membershipNew = membershipRepository.findById(membership.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Membership not found"));
        } else {
            membershipNew = new Membership();
        }

        createMembership(membershipNew, membership);

        return membershipRepository.save(membershipNew);
    }

    private void createMembership(Membership membershipNew, Membership membership) {
        setIfNotNull(membership.getName(), membershipNew::setName);
        setIfNotNull(membership.getMembershipTypeId(), membershipNew::setMembershipTypeId);
        setIfNotNull(membership.getExpiresId(), membershipNew::setExpiresId);
        setIfNotNull(membership.getCantSessions(), membershipNew::setCantSessions);
        setIfNotNull(membership.getPrice(), membershipNew::setPrice);
        setIfNotNull(membership.getStatus(), membershipNew::setStatus);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }

    public Page<Membership> findWithFilterOptional(FilterRequest filterRequest) {

        // Crear objeto de pagina para filtros
        Pageable pageable = UtilsFilter.getPageable(filterRequest);

        // Convertir FilterItem a SearchCriteria si hay filtros
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        // Construir especificación utilizando los criterios si hay filtros
        Specification<Membership> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        // Get page results
        Page<Membership> membershipPage;
        if (specification != null) {
            membershipPage = membershipRepository.findAll(specification, pageable);
        } else {
            membershipPage = membershipRepository.findAll(pageable);
        }

        // Set membership type name and expires name
        for (Membership membership : membershipPage.getContent()) {
            MembershipType membershipType = membershipTypeRepository.findById(membership.getMembershipTypeId()).get();
            membership.setMembershipTypeName(membershipType.getMembershipTypeName());
            if(membership.getExpiresId() != null) {
                Expires expires = expiresRepository.findById(membership.getExpiresId()).get();
                membership.setExpiresName(expires.getExpiresName());
            }
        }

        return new PageImpl<>(membershipPage.getContent(), pageable, membershipPage.getTotalElements());
    }

    public List<MembershipType> getAllMembershipTypes() { return membershipTypeRepository.findAll(); }
}
