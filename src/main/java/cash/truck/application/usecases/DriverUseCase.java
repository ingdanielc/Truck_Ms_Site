package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.Driver;
import cash.truck.domain.repositories.DriverRepository;
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

@Service
@Transactional
public class DriverUseCase {

    @Autowired
    private final DriverRepository driverRepository;
    private final SecurityUseCase securityUseCase;
    private final InAppNotificationUseCase inAppNotificationUseCase;

    public DriverUseCase(DriverRepository driverRepository, SecurityUseCase securityUseCase,
            InAppNotificationUseCase inAppNotificationUseCase) {
        this.driverRepository = driverRepository;
        this.securityUseCase = securityUseCase;
        this.inAppNotificationUseCase = inAppNotificationUseCase;
    }

    public List<Driver> getAllDrivers() {
        return driverRepository.findAll();
    }

    public Driver save(Driver driver) {
        Driver driverNew;
        boolean isNew = driver.getId() == null;

        if (!isNew) {
            driverNew = driverRepository.findById(driver.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Driver not found"));

            // Synchronize email and name with User entity if they are changing
            if (driverNew.getUser() != null) {
                boolean changed = false;
                if (driver.getEmail() != null && !driver.getEmail().equals(driverNew.getEmail())) {
                    driverNew.getUser().setEmail(driver.getEmail());
                    changed = true;
                }
                if (driver.getName() != null && !driver.getName().equals(driverNew.getName())) {
                    driverNew.getUser().setName(driver.getName());
                    changed = true;
                }
                if (changed) {
                    securityUseCase.saveUser(driverNew.getUser());
                }
            }
        } else {
            driverNew = new Driver();
        }

        applyFields(driver, driverNew);
        Driver savedDriver = driverRepository.save(driverNew);

        String message = isNew ? "Se ha creado un nuevo conductor: " + savedDriver.getName()
                : "Se ha actualizado el conductor: " + savedDriver.getName();
        inAppNotificationUseCase.createNotification("DRIVER_EVENT", message, 1, null, savedDriver.getOwnerId(),
                savedDriver.getId().longValue());

        return savedDriver;
    }

    private void applyFields(Driver source, Driver target) {
        setIfNotNull(source.getPhoto(), target::setPhoto);
        setIfNotNull(source.getDocumentTypeId(), target::setDocumentTypeId);
        setIfNotNull(source.getDocumentNumber(), target::setDocumentNumber);
        setIfNotNull(source.getName(), target::setName);
        setIfNotNull(source.getEmail(), target::setEmail);
        setIfNotNull(source.getCellPhone(), target::setCellPhone);
        setIfNotNull(source.getCityId(), target::setCityId);
        setIfNotNull(source.getGenderId(), target::setGenderId);
        setIfNotNull(source.getBirthdate(), target::setBirthdate);
        setIfNotNull(source.getLicenseCategory(), target::setLicenseCategory);
        setIfNotNull(source.getLicenseNumber(), target::setLicenseNumber);
        setIfNotNull(source.getLicenseExpiry(), target::setLicenseExpiry);
        setIfNotNull(source.getSalaryTypeId(), target::setSalaryTypeId);
        setIfNotNull(source.getSalary(), target::setSalary);
        setIfNotNull(source.getUser(), target::setUser);
        setIfNotNull(source.getOwnerId(), target::setOwnerId);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }

    public Page<Driver> findWithFilterOptional(FilterRequest filterRequest) {
        Pageable pageable = UtilsFilter.getPageable(filterRequest);
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<Driver> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        Page<Driver> page;
        if (specification != null) {
            page = driverRepository.findAll(specification, pageable);
        } else {
            page = driverRepository.findAll(pageable);
        }

        return new PageImpl<>(page.getContent(), pageable, page.getTotalElements());
    }
}
