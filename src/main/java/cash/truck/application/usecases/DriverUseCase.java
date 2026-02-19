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

    public DriverUseCase(DriverRepository driverRepository) {
        this.driverRepository = driverRepository;
    }

    public List<Driver> getAllDrivers() {
        return driverRepository.findAll();
    }

    public Driver save(Driver driver) {
        Driver driverNew;

        if (driver.getId() != null) {
            driverNew = driverRepository.findById(driver.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Driver not found"));
        } else {
            driverNew = new Driver();
        }

        applyFields(driver, driverNew);
        return driverRepository.save(driverNew);
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
