package cash.truck.domain.repositories;

import cash.truck.domain.entities.DocumentFile;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface DocumentFileRepository extends JpaRepository<DocumentFile, Long>,
        JpaSpecificationExecutor<DocumentFile> {

    Page<DocumentFile> findAll(Specification<DocumentFile> specification, Pageable pageable);

    /**
     * Documento vigente de ese portador y tipo. Se consulta antes de guardar uno
     * nuevo para desactivarlo: sin eso la renovacion choca contra el indice
     * unico en lugar de reemplazar al anterior.
     */
    List<DocumentFile> findByVehicleIdAndDocumentFileTypeIdAndIsActiveTrue(Long vehicleId, Integer documentFileTypeId);

    List<DocumentFile> findByDriverIdAndDocumentFileTypeIdAndIsActiveTrue(Long driverId, Integer documentFileTypeId);

    List<DocumentFile> findByOwnerIdAndDocumentFileTypeIdAndIsActiveTrue(Long ownerId, Integer documentFileTypeId);

    /**
     * Vencimientos de un dia exacto. Es la consulta del recordatorio, que compara
     * la fecha puntual —no un rango— para no necesitar una columna que registre
     * si ya se aviso, igual que hace hoy el aviso de suscripcion.
     */
    List<DocumentFile> findByExpiryDateAndIsActiveTrue(LocalDate expiryDate);
}
