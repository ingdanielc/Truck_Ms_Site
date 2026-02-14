package cash.truck.application.usecases;

import cash.truck.application.utility.Constants;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.*;
import cash.truck.domain.repositories.BiometricDataRepository;
import cash.truck.domain.repositories.MembershipRepository;
import cash.truck.domain.repositories.PartnerMembershipRepository;
import cash.truck.domain.repositories.PartnerRepository;
import jakarta.persistence.EntityNotFoundException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Date;
import java.util.List;
import java.util.Optional;
import java.util.function.Consumer;
import java.util.stream.Collectors;

import static cash.truck.application.exception.PartnerException.duplicateEntityException;

@Service
public class PartnerUseCase {

    private static final Logger logger = LoggerFactory.getLogger(PartnerUseCase.class);

    @Autowired
    private final PartnerRepository partnerRepository;
    private final BiometricDataRepository biometricDataRepository;
    private final PartnerMembershipRepository partnerMembershipRepository;
    private final MembershipRepository membershipRepository;

    public PartnerUseCase(PartnerRepository partnerRepository,
                          BiometricDataRepository biometricDataRepository,
                          PartnerMembershipRepository partnerMembershipRepository,
                          MembershipRepository membershipRepository){
        this.partnerRepository = partnerRepository;
        this.biometricDataRepository = biometricDataRepository;
        this.partnerMembershipRepository = partnerMembershipRepository;
        this.membershipRepository = membershipRepository;
    }

    public List<Partner> getAllPartners() {
        return partnerRepository.findAll();
    }

    public Partner savePartner(Partner partner) {
        Partner partnerNew;

        // Validate duplicated
        if (partner.getDocumentTypeId() != null
                && partner.getDocumentNumber() != null) {
            Optional<Partner> existingPartner = partnerRepository.findByDocumentTypeIdAndDocumentNumber(
                    partner.getDocumentTypeId(),
                    partner.getDocumentNumber()
            );
            if (existingPartner.isPresent() &&
                    (partner.getId() == null ||
                            !existingPartner.get().getId().equals(partner.getId()))) {
                throw duplicateEntityException();
            }
        }
        if (partner.getId() != null) {
            partnerNew = partnerRepository.findById(partner.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Partner not found"));
        } else {
            partnerNew = new Partner();
        }

        createPartner(partnerNew, partner);

        return partnerRepository.save(partnerNew);
    }

    private void createPartner(Partner partnerNew, Partner partner) {
        setIfNotNull(partner.getPhoto(), partnerNew::setPhoto);
        setIfNotNull(partner.getDocumentTypeId(), partnerNew::setDocumentTypeId);
        setIfNotNull(partner.getDocumentNumber(), partnerNew::setDocumentNumber);
        setIfNotNull(partner.getName(), partnerNew::setName);
        setIfNotNull(partner.getBirthdate(), partnerNew::setBirthdate);
        setIfNotNull(partner.getAge(), partnerNew::setAge);
        setIfNotNull(partner.getGenderId(), partnerNew::setGenderId);
        setIfNotNull(partner.getCityId(), partnerNew::setCityId);
        setIfNotNull(partner.getAddress(), partnerNew::setAddress);
        setIfNotNull(partner.getCellPhone(), partnerNew::setCellPhone);
        setIfNotNull(partner.getEmail(), partnerNew::setEmail);
        setIfNotNull(partner.getStatus(), partnerNew::setStatus);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }

    public Page<Partner> findWithFilterOptional(FilterRequest filterRequest) {

        // Crear objeto de pagina para filtros
        Pageable pageable = UtilsFilter.getPageable(filterRequest);

        // Convert FilterItem a SearchCriteria si hay filtros
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        // Construir especificación utilizando los criterios si hay filtros
        Specification<Partner> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        // Get page results
        Page<Partner> partnerPage;
        if (specification != null) {
            partnerPage = partnerRepository.findAll(specification, pageable);
        } else {
            partnerPage = partnerRepository.findAll(pageable);
        }

        return new PageImpl<>(partnerPage.getContent(), pageable, partnerPage.getTotalElements());
    }

    public BiometricData saveBiometricData(BiometricData biometricData) {
        return biometricDataRepository.save(biometricData);
    }

    public PartnerMembership savePartnerMembership(PartnerMembership partnerMembership) {
        PartnerMembership partnerMembershipNew;

        // Validate duplicated
        if (partnerMembership.getPartnerId() != null
                && partnerMembership.getMembership().getId() != null) {
            Optional<PartnerMembership> existingPartnerMembership = partnerMembershipRepository.findByPartnerIdAndMembershipIdAndStatus(
                    partnerMembership.getPartnerId(),
                    partnerMembership.getMembership().getId(),
                    Constants.STATUS_ACTIVE
            );
            if (existingPartnerMembership.isPresent() &&
                    (partnerMembership.getId() == null ||
                            !existingPartnerMembership.get().getId().equals(partnerMembership.getId()))) {
                throw duplicateEntityException();
            }
        }
        if (partnerMembership.getId() != null) {
            partnerMembershipNew = partnerMembershipRepository.findById(partnerMembership.getId())
                    .orElseThrow(() -> new EntityNotFoundException("PartnerMembership not found"));
        } else {
            partnerMembershipNew = new PartnerMembership();
        }

        // Set status partner to Active
        if (partnerMembership.getStatus().equals(Constants.STATUS_ACTIVE)) {
            assert partnerMembership.getPartnerId() != null;
            Optional<Partner> partner = partnerRepository.findById(partnerMembership.getPartnerId());
            partner.ifPresent(value -> value.setStatus(Constants.STATUS_ACTIVE));
            partnerRepository.save(partner.get());
        } else {
            List<PartnerMembership> partnerMembershipList = partnerMembershipRepository.findByPartnerId(partnerMembership.getPartnerId());
            String status = Constants.STATUS_INACTIVE;
            for (PartnerMembership membership : partnerMembershipList) {
                if(membership.getStatus().equals(Constants.STATUS_ACTIVE) && !membership.getId().equals(partnerMembership.getId())) {
                    status = Constants.STATUS_ACTIVE;
                    break;
                } else {
                    status = Constants.STATUS_INACTIVE;
                }
            }
            if (status.equals(Constants.STATUS_INACTIVE)) {
                assert partnerMembership.getPartnerId() != null;
                Optional<Partner> partner = partnerRepository.findById(partnerMembership.getPartnerId());
                partner.ifPresent(value -> value.setStatus(Constants.STATUS_INACTIVE));
                partnerRepository.save(partner.get());
            }
        }

        assert partnerMembership.getMembership().getId() != null;
        Optional<Membership> membership = membershipRepository.findById(partnerMembership.getMembership().getId());
        partnerMembership.setMembership(membership.get());

        createPartnerMembership(partnerMembershipNew, partnerMembership);
        return partnerMembershipRepository.save(partnerMembershipNew);
    }

    private void createPartnerMembership(PartnerMembership partnerMembershipNew, PartnerMembership partnerMembership) {
        setIfNotNull(partnerMembership.getPartnerId(), partnerMembershipNew::setPartnerId);
        setIfNotNull(partnerMembership.getMembership(), partnerMembershipNew::setMembership);
        setIfNotNull(partnerMembership.getCantSessions(), partnerMembershipNew::setCantSessions);
        setIfNotNull(partnerMembership.getPrice(), partnerMembershipNew::setPrice);
        setIfNotNull(partnerMembership.getStartDate(), partnerMembershipNew::setStartDate);
        setIfNotNull(partnerMembership.getExpirationDate(), partnerMembershipNew::setExpirationDate);
        setIfNotNull(partnerMembership.getStatus(), partnerMembershipNew::setStatus);
    }

    public List<PartnerMembership> getPartnerMembershipsByPartner(Long partnerId) {
        List<PartnerMembership> resp = partnerMembershipRepository.findByPartnerId(partnerId);
        for (PartnerMembership partnerMembership : resp) {
            Membership membership = membershipRepository.findById(partnerMembership.getMembership().getId()).get();
            partnerMembership.setMembership(membership);
        }
        return resp;
    }

    public List<Partner> getPartnersWithBirthdayToday() {
        return partnerRepository.findPartnersWithBirthdayToday();
    }

    public List<Partner> getInactivePartners(Integer days) {
        LocalDateTime daysAgo = LocalDateTime.now().minusDays(days);
        List<Object[]> results = partnerRepository.findInactivePartners(daysAgo);

        return results.stream().map(result -> {
            Partner partner = (Partner) result[0];
            Date accessTime = (Date) result[1];
            partner.setAccessTime(accessTime);
            return partner;
        }).collect(Collectors.toList());
    }
}
