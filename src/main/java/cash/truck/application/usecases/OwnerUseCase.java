package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.entities.VehicleOwner;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.VehicleOwnerRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import jakarta.transaction.Transactional;

import java.util.List;
import java.util.function.Consumer;

import static cash.truck.application.exception.PartnerException.duplicateEntityException;

@Service
@Transactional
public class OwnerUseCase {

    @Autowired
    private final OwnerRepository ownerRepository;
    private final VehicleOwnerRepository vehicleOwnerRepository;
    private final SecurityUseCase securityUseCase;

    public OwnerUseCase(OwnerRepository ownerRepository,
            VehicleOwnerRepository vehicleOwnerRepository,
            SecurityUseCase securityUseCase) {
        this.ownerRepository = ownerRepository;
        this.vehicleOwnerRepository = vehicleOwnerRepository;
        this.securityUseCase = securityUseCase;
    }

    public List<Owner> getAllOwners() {
        return ownerRepository.findAll();
    }

    public Owner save(Owner owner) {
        Owner ownerNew;

        if (owner.getId() != null) {
            ownerNew = ownerRepository.findById(owner.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Owner not found"));

            // Synchronize email and name with User entity if they are changing
            if (ownerNew.getUser() != null) {
                boolean changed = false;
                if (owner.getEmail() != null && !owner.getEmail().equals(ownerNew.getEmail())) {
                    ownerNew.getUser().setEmail(owner.getEmail());
                    changed = true;
                }
                if (owner.getName() != null && !owner.getName().equals(ownerNew.getName())) {
                    ownerNew.getUser().setName(owner.getName());
                    changed = true;
                }
                if (changed) {
                    securityUseCase.saveUser(ownerNew.getUser());
                }
            }
        } else {
            ownerNew = new Owner();
        }

        applyFields(owner, ownerNew);

        if (ownerNew.getMaxVehicles() == null) {
            ownerNew.setMaxVehicles(3);
        }

        return ownerRepository.save(ownerNew);
    }

    private void applyFields(Owner source, Owner target) {
        setIfNotNull(source.getPhoto(), target::setPhoto);
        setIfNotNull(source.getDocumentTypeId(), target::setDocumentTypeId);
        setIfNotNull(source.getDocumentNumber(), target::setDocumentNumber);
        setIfNotNull(source.getName(), target::setName);
        setIfNotNull(source.getEmail(), target::setEmail);
        setIfNotNull(source.getCellPhone(), target::setCellPhone);
        setIfNotNull(source.getCityId(), target::setCityId);
        setIfNotNull(source.getGenderId(), target::setGenderId);
        setIfNotNull(source.getBirthdate(), target::setBirthdate);
        setIfNotNull(source.getUser(), target::setUser);
        setIfNotNull(source.getMaxVehicles(), target::setMaxVehicles);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }

    public Page<Owner> findWithFilterOptional(FilterRequest filterRequest) {
        Pageable pageable = UtilsFilter.getPageable(filterRequest);
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<Owner> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        Page<Owner> page;
        if (specification != null) {
            page = ownerRepository.findAll(specification, pageable);
        } else {
            page = ownerRepository.findAll(pageable);
        }

        return new PageImpl<>(page.getContent(), pageable, page.getTotalElements());
    }

    public VehicleOwner setVehicle(VehicleOwner vehicleOwner) {
        // Validate duplicate assignment
        boolean exists = vehicleOwnerRepository.findAll().stream()
                .anyMatch(vo -> vo.getVehicleId().equals(vehicleOwner.getVehicleId())
                        && vo.getOwnerId().equals(vehicleOwner.getOwnerId())
                        && (vehicleOwner.getId() == null || !vo.getId().equals(vehicleOwner.getId())));
        if (exists) {
            throw duplicateEntityException();
        }
        return vehicleOwnerRepository.save(vehicleOwner);
    }
}
