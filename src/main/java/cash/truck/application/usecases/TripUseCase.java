package cash.truck.application.usecases;

import cash.truck.application.exception.TripValidationException;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.Trip;
import cash.truck.domain.enums.TripTypeEnum;
import cash.truck.domain.repositories.TripRepository;
import cash.truck.domain.repositories.VehicleRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.function.Consumer;

@Service
public class TripUseCase {

    @Autowired
    private final TripRepository tripRepository;
    private final VehicleRepository vehicleRepository;
    private final InAppNotificationUseCase inAppNotificationUseCase;

    public TripUseCase(TripRepository tripRepository, VehicleRepository vehicleRepository,
            InAppNotificationUseCase inAppNotificationUseCase) {
        this.tripRepository = tripRepository;
        this.vehicleRepository = vehicleRepository;
        this.inAppNotificationUseCase = inAppNotificationUseCase;
    }

    public List<Trip> getAllTrips() {
        return tripRepository.findAll();
    }

    public Trip save(Trip trip) {
        Trip tripNew;
        boolean isNew = trip.getId() == null;

        if (!isNew) {
            tripNew = tripRepository.findById(trip.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Trip not found"));
        } else {
            tripNew = new Trip();
        }

        applyFields(trip, tripNew);
        normalizeAndValidate(tripNew);
        Trip savedTrip = tripRepository.save(tripNew);

        // Un viaje VACIO puede no tener manifiesto
        String manifestLabel = isBlank(savedTrip.getManifestNumber()) ? "sin manifiesto"
                : "con manifiesto " + savedTrip.getManifestNumber();

        String message;
        Long ownerId = null;
        try {
            if (savedTrip.getVehicleId() != null) {
                var vehicle = vehicleRepository.findById(savedTrip.getVehicleId()).orElse(null);
                if (vehicle != null) {
                    String plate = vehicle.getPlate() != null ? vehicle.getPlate().toUpperCase() : null;
                    if (isNew) {
                        message = "Se ha creado un nuevo viaje " + manifestLabel
                                + (plate != null ? " para el vehículo de placa: " + plate : "");
                    } else {
                        message = "Se ha actualizado el viaje " + manifestLabel
                                + (plate != null ? " para el vehículo de placa: " + plate : "");
                    }
                    if (vehicle.getOwners() != null && !vehicle.getOwners().isEmpty()) {
                        ownerId = vehicle.getOwners().get(0).getOwnerId();
                    }
                } else {
                    message = isNew ? "Se ha creado un nuevo viaje " + manifestLabel
                            : "Se ha actualizado el viaje " + manifestLabel;
                }
            } else {
                message = isNew ? "Se ha creado un nuevo viaje " + manifestLabel
                        : "Se ha actualizado el viaje " + manifestLabel;
            }
        } catch (Exception e) {
            message = isNew ? "Se ha creado un nuevo viaje " + manifestLabel
                    : "Se ha actualizado el viaje " + manifestLabel;
        }

        inAppNotificationUseCase.createNotification("TRIP_EVENT", message, 1, null, ownerId, savedTrip.getId());

        return savedTrip;
    }

    private void applyFields(Trip source, Trip target) {
        setIfNotNull(source.getVehicleId(), target::setVehicleId);
        setIfNotNull(source.getDriverId(), target::setDriverId);
        setIfNotNull(source.getManifestNumber(), target::setManifestNumber);
        setIfNotNull(source.getNumberTrip(), target::setNumberTrip);
        setIfNotNull(source.getCompany(), target::setCompany);
        setIfNotNull(source.getOriginId(), target::setOriginId);
        setIfNotNull(source.getDestinationId(), target::setDestinationId);
        setIfNotNull(source.getStartDate(), target::setStartDate);
        setIfNotNull(source.getEndDate(), target::setEndDate);
        setIfNotNull(source.getNumberOfDays(), target::setNumberOfDays);
        setIfNotNull(source.getLoadType(), target::setLoadType);
        setIfNotNull(source.getDistanceKm(), target::setDistanceKm);
        setIfNotNull(source.getFreight(), target::setFreight);
        setIfNotNull(source.getAdvancePayment(), target::setAdvancePayment);
        setIfNotNull(source.getPaidBalance(), target::setPaidBalance);
        setIfNotNull(source.getStatus(), target::setStatus);
        setIfNotNull(source.getTripType(), target::setTripType);
        setIfNotNull(source.getReturnDestinationId(), target::setReturnDestinationId);
        setIfNotNull(source.getCurrentLeg(), target::setCurrentLeg);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }

    /**
     * Reglas de coherencia por tipo de viaje. Se aplican sobre el viaje ya
     * consolidado (nuevo o existente + cambios), no por anotaciones sueltas de
     * campo, porque dependen del valor de tripType.
     */
    private void normalizeAndValidate(Trip trip) {
        if (trip.getTripType() == null) {
            trip.setTripType(TripTypeEnum.CARGADO);
        }
        TripTypeEnum tripType = trip.getTripType();

        if (tripType == TripTypeEnum.REDONDO) {
            if (isBlank(trip.getReturnDestinationId())) {
                throw new TripValidationException("El destino de regreso es obligatorio para un viaje redondo.");
            }
        } else {
            // returnDestinationId y currentLeg solo aplican al viaje redondo
            trip.setReturnDestinationId(null);
            trip.setCurrentLeg(null);
        }

        BigDecimal freight = trip.getFreight() != null ? trip.getFreight() : BigDecimal.ZERO;
        BigDecimal advancePayment = trip.getAdvancePayment() != null ? trip.getAdvancePayment() : BigDecimal.ZERO;

        if (tripType == TripTypeEnum.VACIO) {
            if (freight.compareTo(BigDecimal.ZERO) != 0) {
                throw new TripValidationException("Un viaje vacío no puede tener flete: el flete debe ser 0.");
            }
            if (advancePayment.compareTo(BigDecimal.ZERO) != 0) {
                throw new TripValidationException("Un viaje vacío no puede tener anticipo: el anticipo debe ser 0.");
            }
        } else {
            if (isBlank(trip.getManifestNumber())) {
                throw new TripValidationException(
                        "El número de manifiesto es obligatorio para un viaje " + tripType.name().toLowerCase() + ".");
            }
            if (freight.compareTo(BigDecimal.ZERO) < 0) {
                throw new TripValidationException("El flete no puede ser negativo.");
            }
            if (advancePayment.compareTo(BigDecimal.ZERO) < 0) {
                throw new TripValidationException("El anticipo no puede ser negativo.");
            }
            if (advancePayment.compareTo(freight) > 0) {
                throw new TripValidationException("El anticipo no puede ser mayor que el flete.");
            }
        }

        trip.setFreight(freight);
        trip.setAdvancePayment(advancePayment);
    }

    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    public Page<Trip> findWithFilterOptional(FilterRequest filterRequest) {
        Pageable pageable = UtilsFilter.getPageable(filterRequest);
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<Trip> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        Page<Trip> page;
        if (specification != null) {
            page = tripRepository.findAll(specification, pageable);
        } else {
            page = tripRepository.findAll(pageable);
        }

        return page;
    }
}
