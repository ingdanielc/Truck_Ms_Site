package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.Vehicle;
import cash.truck.domain.entities.Trip;
import cash.truck.domain.dtos.VehicleCountsDTO;
import cash.truck.domain.repositories.VehicleOwnerRepository;
import cash.truck.domain.repositories.VehicleRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.List;
import java.util.function.Consumer;

@Service
public class VehicleUseCase {

    @Autowired
    private final VehicleRepository vehicleRepository;

    @Autowired
    private VehicleOwnerRepository vehicleOwnerRepository;

    private final InAppNotificationUseCase inAppNotificationUseCase;

    public VehicleUseCase(VehicleRepository vehicleRepository, InAppNotificationUseCase inAppNotificationUseCase) {
        this.vehicleRepository = vehicleRepository;
        this.inAppNotificationUseCase = inAppNotificationUseCase;
    }

    public List<Vehicle> getAllVehicles() {
        return vehicleRepository.findAll();
    }

    @org.springframework.transaction.annotation.Transactional
    public Vehicle save(Vehicle vehicle) {
        Vehicle vehicleNew;
        boolean isNew = vehicle.getId() == null;

        if (!isNew) {
            vehicleNew = vehicleRepository.findById(vehicle.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Vehicle not found"));
        } else {
            vehicleNew = new Vehicle();
        }

        applyFields(vehicle, vehicleNew);
        Vehicle savedVehicle = vehicleRepository.save(vehicleNew);

        if (vehicle.getOwnerId() != null) {
            boolean ownerExists = false;
            if (vehicleNew.getOwners() != null) {
                for (cash.truck.domain.entities.VehicleOwner existingOwner : vehicleNew.getOwners()) {
                    if (existingOwner.getOwnerId().equals(vehicle.getOwnerId())) {
                        ownerExists = true;
                        break;
                    }
                }
            }
            if (!ownerExists) {
                cash.truck.domain.entities.VehicleOwner vehicleOwner = new cash.truck.domain.entities.VehicleOwner();
                vehicleOwner.setVehicleId(savedVehicle.getId());
                vehicleOwner.setOwnerId(vehicle.getOwnerId());
                vehicleOwner.setOwnershipPercentage(new java.math.BigDecimal("100.00"));
                vehicleOwnerRepository.save(vehicleOwner);
            }
        }

        String message = isNew ? "Se ha creado un nuevo vehículo de placa: " + savedVehicle.getPlate()
                : "Se ha actualizado el vehículo de placa: " + savedVehicle.getPlate();
        inAppNotificationUseCase.createNotification("VEHICLE_EVENT", message, 1, null, vehicle.getOwnerId(),
                savedVehicle.getId().longValue());

        return savedVehicle;
    }

    private void applyFields(Vehicle source, Vehicle target) {
        setIfNotNull(source.getPhoto(), target::setPhoto);
        setIfNotNull(source.getPlate() != null ? source.getPlate().toUpperCase() : null, target::setPlate);
        setIfNotNull(source.getVehicleBrandId(), target::setVehicleBrandId);
        setIfNotNull(source.getModel(), target::setModel);
        setIfNotNull(source.getYear(), target::setYear);
        setIfNotNull(source.getColor(), target::setColor);
        setIfNotNull(source.getEngineNumber(), target::setEngineNumber);
        setIfNotNull(source.getChassisNumber(), target::setChassisNumber);
        setIfNotNull(source.getNumberOfAxles(), target::setNumberOfAxles);
        setIfNotNull(source.getCurrentDriverId(), target::setCurrentDriverId);
        setIfNotNull(source.getStatus(), target::setStatus);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }

    @org.springframework.transaction.annotation.Transactional
    public void sellVehicle(Long vehicleId) {
        Vehicle vehicle = vehicleRepository.findById(vehicleId)
                .orElseThrow(() -> new EntityNotFoundException("Vehicle not found"));

        vehicle.setCurrentDriverId(null);
        vehicle.setStatus(Vehicle.Status.Vendido);
        vehicleRepository.save(vehicle);

        List<cash.truck.domain.entities.VehicleOwner> activeOwners = vehicleOwnerRepository.findByVehicleIdAndIsActiveTrue(vehicleId);
        Date now = new Date();
        for (cash.truck.domain.entities.VehicleOwner owner : activeOwners) {
            owner.setIsActive(false);
            owner.setEndDate(now);
        }
        vehicleOwnerRepository.saveAll(activeOwners);
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

    public VehicleCountsDTO getCounts(FilterRequest filterRequest) {
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<Vehicle> baseSpec = null;
        if (!searchCriteriaList.isEmpty()) {
            baseSpec = new GenericSpecification<>(searchCriteriaList);
        }

        Specification<Vehicle> notSoldSpec = (root, query, cb) -> 
            cb.notEqual(root.get("status"), Vehicle.Status.Vendido);
        
        Specification<Vehicle> finalBaseSpec = baseSpec != null ? baseSpec.and(notSoldSpec) : notSoldSpec;

        Specification<Vehicle> occupiedSpec = (root, query, cb) -> {
            Subquery<Long> subquery = query.subquery(Long.class);
            Root<Trip> tripRoot = subquery.from(Trip.class);
            subquery.select(cb.count(tripRoot));
            subquery.where(
                cb.equal(tripRoot.get("vehicleId"), root.get("id")),
                cb.equal(tripRoot.get("status"), "En Curso")
            );
            return cb.greaterThan(subquery, 0L);
        };

        Specification<Vehicle> availableSpec = (root, query, cb) -> {
            Subquery<Long> subquery = query.subquery(Long.class);
            Root<Trip> tripRoot = subquery.from(Trip.class);
            subquery.select(cb.count(tripRoot));
            subquery.where(
                cb.equal(tripRoot.get("vehicleId"), root.get("id")),
                cb.equal(tripRoot.get("status"), "En Curso")
            );
            return cb.equal(subquery, 0L);
        };

        long total = vehicleRepository.count(finalBaseSpec);
        long inProgress = vehicleRepository.count(finalBaseSpec.and(occupiedSpec));
        long available = vehicleRepository.count(finalBaseSpec.and(availableSpec));

        return new VehicleCountsDTO(total, available, inProgress);
    }
}
