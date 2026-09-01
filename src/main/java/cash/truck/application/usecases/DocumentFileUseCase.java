package cash.truck.application.usecases;

import cash.truck.application.exception.DocumentValidationException;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.DocumentFile;
import cash.truck.domain.entities.DocumentFileType;
import cash.truck.domain.enums.DocumentHolderEnum;
import cash.truck.domain.repositories.DocumentFileRepository;
import cash.truck.domain.repositories.DocumentFileTypeRepository;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.VehicleRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.function.Consumer;

/**
 * Documentos archivados. El caso de uso no sabe de vehiculos en particular: la
 * misma logica sirve para conductores y propietarios, de modo que exponerlos
 * mañana desde DriverController es agregar el endpoint, no reescribir esto.
 *
 * Las reglas que la base ya garantiza con CHECK se validan igual aqui, pero por
 * otra razon: un CHECK devuelve un error de motor ilegible: el front necesita
 * saber cual documento de la lista fallo y por que.
 */
@Service
@Transactional
public class DocumentFileUseCase {

    private final DocumentFileRepository documentFileRepository;
    private final DocumentFileTypeRepository documentFileTypeRepository;
    private final VehicleRepository vehicleRepository;
    private final DriverRepository driverRepository;
    private final OwnerRepository ownerRepository;

    public DocumentFileUseCase(DocumentFileRepository documentFileRepository,
            DocumentFileTypeRepository documentFileTypeRepository,
            VehicleRepository vehicleRepository,
            DriverRepository driverRepository,
            OwnerRepository ownerRepository) {
        this.documentFileRepository = documentFileRepository;
        this.documentFileTypeRepository = documentFileTypeRepository;
        this.vehicleRepository = vehicleRepository;
        this.driverRepository = driverRepository;
        this.ownerRepository = ownerRepository;
    }

    /**
     * Alta y actualizacion en un solo viaje: sin id se crea, con id se
     * actualiza. Todo va en una transaccion —la del @Transactional de la
     * clase— para que una lista no quede aplicada a medias si el tercer
     * documento no valida.
     */
    public List<DocumentFile> saveAll(List<DocumentFile> documents) {
        if (documents == null || documents.isEmpty()) {
            throw new DocumentValidationException("No se recibio ningun documento para guardar.");
        }

        List<DocumentFile> saved = new ArrayList<>(documents.size());
        for (int index = 0; index < documents.size(); index++) {
            saved.add(save(documents.get(index), index));
        }
        return saved;
    }

    private DocumentFile save(DocumentFile document, int index) {
        DocumentFile target;
        if (document.getId() != null) {
            target = documentFileRepository.findById(document.getId())
                    .orElseThrow(() -> new EntityNotFoundException(
                            prefix(index) + "el documento " + document.getId() + " no existe."));
        } else {
            target = new DocumentFile();
        }

        applyFields(document, target);
        if (target.getIsActive() == null) {
            target.setIsActive(true);
        }

        // Se valida el resultado de la mezcla y no lo que llego: en una
        // actualizacion el front puede mandar solo el campo que cambio, y lo que
        // omite sigue estando en la fila guardada.
        DocumentHolderEnum holder = resolveHolder(target, index);
        DocumentFileType type = documentFileTypeRepository.findById(requireTypeId(target, index))
                .orElseThrow(() -> new EntityNotFoundException(
                        prefix(index) + "el tipo de documento " + target.getDocumentFileTypeId() + " no existe."));

        validateType(target, type, holder, index);
        validateHolderExists(target, holder, index);
        validatePayload(target, type, index);

        // Al renovar, el anterior sale de circulacion antes de insertar el nuevo:
        // si no, los dos quedarian activos y chocarian contra el indice unico.
        if (Boolean.TRUE.equals(target.getIsActive())) {
            deactivatePrevious(target);
        }

        return documentFileRepository.save(target);
    }

    /** Exactamente un portador: ni cero ni dos. */
    private DocumentHolderEnum resolveHolder(DocumentFile document, int index) {
        int holders = 0;
        DocumentHolderEnum holder = null;
        if (document.getVehicleId() != null) {
            holders++;
            holder = DocumentHolderEnum.VEHICLE;
        }
        if (document.getDriverId() != null) {
            holders++;
            holder = DocumentHolderEnum.DRIVER;
        }
        if (document.getOwnerId() != null) {
            holders++;
            holder = DocumentHolderEnum.OWNER;
        }
        if (holders != 1) {
            throw new DocumentValidationException(prefix(index)
                    + "debe indicarse exactamente un vehicleId, driverId u ownerId.");
        }
        return holder;
    }

    private Integer requireTypeId(DocumentFile document, int index) {
        if (document.getDocumentFileTypeId() == null) {
            throw new DocumentValidationException(prefix(index) + "falta el documentFileTypeId.");
        }
        return document.getDocumentFileTypeId();
    }

    private void validateType(DocumentFile document, DocumentFileType type, DocumentHolderEnum holder, int index) {
        if (Boolean.FALSE.equals(type.getIsActive())) {
            throw new DocumentValidationException(
                    prefix(index) + "el tipo '" + type.getName() + "' esta inactivo.");
        }
        if (type.getAppliesTo() != holder) {
            throw new DocumentValidationException(prefix(index) + "el tipo '" + type.getName()
                    + "' aplica a " + type.getAppliesTo() + " y se envio con un portador " + holder + ".");
        }
        if (Boolean.TRUE.equals(type.getRequiresExpiry()) && document.getExpiryDate() == null) {
            throw new DocumentValidationException(
                    prefix(index) + "el tipo '" + type.getName() + "' exige fecha de vencimiento.");
        }
    }

    private void validateHolderExists(DocumentFile document, DocumentHolderEnum holder, int index) {
        boolean exists = switch (holder) {
            case VEHICLE -> vehicleRepository.existsById(document.getVehicleId());
            case DRIVER -> driverRepository.existsById(document.getDriverId());
            case OWNER -> ownerRepository.existsById(document.getOwnerId());
        };
        if (!exists) {
            throw new EntityNotFoundException(prefix(index) + "el portador " + holder + " no existe.");
        }
    }

    /**
     * Sin archivo y sin vencimiento la fila no sirve para nada: ni se consulta
     * ni hay de que avisar. Registrar solo la fecha, para que la app recuerde el
     * vencimiento sin cargar el escaneo, si es valido.
     */
    private void validatePayload(DocumentFile document, DocumentFileType type, int index) {
        boolean hasFile = document.getFileUrl() != null && !document.getFileUrl().isBlank();
        if (!hasFile && document.getExpiryDate() == null) {
            throw new DocumentValidationException(prefix(index) + "el documento '" + type.getName()
                    + "' necesita al menos el archivo o la fecha de vencimiento.");
        }
        if (document.getIssueDate() != null && document.getExpiryDate() != null
                && document.getExpiryDate().isBefore(document.getIssueDate())) {
            throw new DocumentValidationException(
                    prefix(index) + "la fecha de vencimiento es anterior a la de expedicion.");
        }
    }

    private void deactivatePrevious(DocumentFile target) {
        List<DocumentFile> current;
        if (target.getVehicleId() != null) {
            current = documentFileRepository.findByVehicleIdAndDocumentFileTypeIdAndIsActiveTrue(
                    target.getVehicleId(), target.getDocumentFileTypeId());
        } else if (target.getDriverId() != null) {
            current = documentFileRepository.findByDriverIdAndDocumentFileTypeIdAndIsActiveTrue(
                    target.getDriverId(), target.getDocumentFileTypeId());
        } else {
            current = documentFileRepository.findByOwnerIdAndDocumentFileTypeIdAndIsActiveTrue(
                    target.getOwnerId(), target.getDocumentFileTypeId());
        }

        for (DocumentFile previous : current) {
            if (!previous.getId().equals(target.getId())) {
                previous.setIsActive(false);
                documentFileRepository.save(previous);
            }
        }
        documentFileRepository.flush();
    }

    private void applyFields(DocumentFile source, DocumentFile target) {
        setIfNotNull(source.getDocumentFileTypeId(), target::setDocumentFileTypeId);
        setIfNotNull(source.getVehicleId(), target::setVehicleId);
        setIfNotNull(source.getDriverId(), target::setDriverId);
        setIfNotNull(source.getOwnerId(), target::setOwnerId);
        setIfNotNull(source.getDocumentNumber(), target::setDocumentNumber);
        setIfNotNull(source.getIssuer(), target::setIssuer);
        setIfNotNull(source.getIssueDate(), target::setIssueDate);
        setIfNotNull(source.getExpiryDate(), target::setExpiryDate);
        setIfNotNull(source.getFileUrl(), target::setFileUrl);
        setIfNotNull(source.getObservations(), target::setObservations);
        setIfNotNull(source.getIsActive(), target::setIsActive);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }

    public Page<DocumentFile> findWithFilterOptional(FilterRequest filterRequest) {
        Pageable pageable = UtilsFilter.getPageable(filterRequest);
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<DocumentFile> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        Page<DocumentFile> page;
        if (specification != null) {
            page = documentFileRepository.findAll(specification, pageable);
        } else {
            page = documentFileRepository.findAll(pageable);
        }

        return new PageImpl<>(page.getContent(), pageable, page.getTotalElements());
    }

    /**
     * Borrado real, para el documento cargado por error. La renovacion no pasa
     * por aqui: esa desactiva y conserva el historico.
     */
    public void delete(Long id) {
        DocumentFile document = documentFileRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException("El documento " + id + " no existe."));
        documentFileRepository.delete(document);
    }

    private String prefix(int index) {
        return "Documento " + (index + 1) + ": ";
    }
}
