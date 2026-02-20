package cash.truck.domain.repositories;

import cash.truck.domain.entities.VehicleOwner;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import org.springframework.data.jpa.repository.JpaSpecificationExecutor;

@Repository
public interface VehicleOwnerRepository
        extends JpaRepository<VehicleOwner, Long>, JpaSpecificationExecutor<VehicleOwner> {

}
