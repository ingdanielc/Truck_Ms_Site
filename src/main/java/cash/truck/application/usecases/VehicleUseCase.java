package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.Vehicle;
import cash.truck.domain.repositories.VehicleRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.function.Consumer;

@Service
public class VehicleUseCase {

    @Autowired
    private final VehicleRepository vehicleRepository;

    public VehicleUseCase(VehicleRepository vehicleRepository) {
        this.vehicleRepository = vehicleRepository;
    }

    public List<Vehicle> getAllVehicles() {
        return vehicleRepository.findAll();
    }

    public Vehicle save(Vehicle vehicle) {
        Vehicle vehicleNew;

        if (vehicle.getId() != null) {
            vehicleNew = vehicleRepository.findById(vehicle.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Vehicle not found"));
        } else {
            vehicleNew = new Vehicle();
        }

        applyFields(vehicle, vehicleNew);
        return vehicleRepository.save(vehicleNew);
    }

    private void applyFields(Vehicle source, Vehicle target) {
        setIfNotNull(source.getPhoto(), target::setPhoto);
        setIfNotNull(source.getPlate(), target::setPlate);
        setIfNotNull(source.getVehicleBrandId(), target::setVehicleBrandId);
        setIfNotNull(source.getModel(), target::setModel);
        setIfNotNull(source.getYear(), target::setYear);
        setIfNotNull(source.getColor(), target::setColor);
        setIfNotNull(source.getEngineNumber(), target::setEngineNumber);
        setIfNotNull(source.getChassisNumber(), target::setChassisNumber);
        setIfNotNull(source.getNumberOfAxles(), target::setNumberOfAxles);
        setIfNotNull(source.getStatus(), target::setStatus);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }

    public Page<Vehicle> findWithFilterOptional(FilterRequest filterRequest) {
        Pageable pageable = UtilsFilter.getPageable(filterRequest);
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<Vehicle> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        Page<Vehicle> page;
        if (specification != null) {
            page = vehicleRepository.findAll(specification, pageable);
        } else {
            page = vehicleRepository.findAll(pageable);
        }

        return new PageImpl<>(page.getContent(), pageable, page.getTotalElements());
    }
}
