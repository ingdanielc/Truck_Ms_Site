package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.DriverLocation;
import cash.truck.domain.repositories.DriverLocationRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.function.Consumer;

@Service
@Transactional
public class DriverLocationUseCase {

    @Autowired
    private final DriverLocationRepository driverLocationRepository;

    public DriverLocationUseCase(DriverLocationRepository driverLocationRepository) {
        this.driverLocationRepository = driverLocationRepository;
    }

    public Page<DriverLocation> findWithFilterOptional(FilterRequest filterRequest) {
        Pageable pageable = UtilsFilter.getPageable(filterRequest);
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<DriverLocation> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        Page<DriverLocation> page;
        if (specification != null) {
            page = driverLocationRepository.findAll(specification, pageable);
        } else {
            page = driverLocationRepository.findAll(pageable);
        }

        return new PageImpl<>(page.getContent(), pageable, page.getTotalElements());
    }

    public DriverLocation save(DriverLocation driverLocation) {
        DriverLocation newLocation;
        boolean isNew = driverLocation.getId() == null;

        if (!isNew) {
            newLocation = driverLocationRepository.findById(driverLocation.getId())
                    .orElseThrow(() -> new EntityNotFoundException("DriverLocation not found"));
        } else {
            newLocation = new DriverLocation();
        }

        applyFields(driverLocation, newLocation);

        return driverLocationRepository.save(newLocation);
    }

    private void applyFields(DriverLocation source, DriverLocation target) {
        setIfNotNull(source.getDriverId(), target::setDriverId);
        setIfNotNull(source.getVehicleId(), target::setVehicleId);
        setIfNotNull(source.getTripId(), target::setTripId);
        setIfNotNull(source.getLatitude(), target::setLatitude);
        setIfNotNull(source.getLongitude(), target::setLongitude);
        setIfNotNull(source.getSpeedKmh(), target::setSpeedKmh);
        setIfNotNull(source.getAddressText(), target::setAddressText);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }
}
