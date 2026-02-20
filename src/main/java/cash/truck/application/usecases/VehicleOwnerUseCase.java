package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.VehicleOwner;
import cash.truck.domain.repositories.VehicleOwnerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;

import cash.truck.domain.entities.Vehicle;
import cash.truck.domain.repositories.VehicleRepository;
import java.util.stream.Collectors;

@Service
public class VehicleOwnerUseCase {

    @Autowired
    private VehicleOwnerRepository vehicleOwnerRepository;

    @Autowired
    private VehicleRepository vehicleRepository;

    public Page<Vehicle> findWithFilterOptional(FilterRequest filterRequest) {
        Pageable pageable = UtilsFilter.getPageable(filterRequest);
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<VehicleOwner> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        Page<VehicleOwner> page;
        if (specification != null) {
            page = vehicleOwnerRepository.findAll(specification, pageable);
        } else {
            page = vehicleOwnerRepository.findAll(pageable);
        }

        List<Long> vehicleIds = page.getContent().stream()
                .map(VehicleOwner::getVehicleId)
                .collect(Collectors.toList());

        List<Vehicle> vehicles = vehicleRepository.findAllById(vehicleIds);

        // Maintain the order if necessary, though findAllById might not guarantee it.
        // For accurate ordering based on the original query, we might need to map them
        // back.
        // But for now, returning the list is the primary goal.
        // A simple way to preserve order is to loop through IDs and pick from the map.

        java.util.Map<Long, Vehicle> vehicleMap = vehicles.stream()
                .collect(Collectors.toMap(Vehicle::getId, v -> v));

        List<Vehicle> orderedVehicles = vehicleIds.stream()
                .map(vehicleMap::get)
                .filter(java.util.Objects::nonNull)
                .collect(Collectors.toList());

        return new PageImpl<>(orderedVehicles, pageable, page.getTotalElements());
    }
}
