package cash.truck.infrastructure.scheduler;

import cash.truck.application.usecases.InAppNotificationUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.domain.entities.DocumentFile;
import cash.truck.domain.entities.Driver;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.entities.Vehicle;
import cash.truck.domain.entities.VehicleOwner;
import cash.truck.domain.repositories.DocumentFileRepository;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.VehicleOwnerRepository;
import cash.truck.domain.repositories.VehicleRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Optional;

/**
 * Avisa que un documento esta por vencer, sea de un vehiculo, de un conductor
 * o de un propietario.
 *
 * El aviso se guarda en la bandeja de notificaciones de la app y sale ademas
 * por push; no se envia por WhatsApp.
 *
 * Corre una vez al dia y consulta la fecha de vencimiento exacta de cada
 * antelacion —10, 3 y 0 dias—, no un rango, de modo que a cada destinatario le
 * llega un aviso por documento y por hito. Si el servicio estuvo caido a la
 * hora programada ese dia se pierde el aviso de ese hito: no hay reintento,
 * porque repetirlo al dia siguiente cambiaria los dias de antelacion.
 *
 * Destinatarios segun a quien pertenezca el documento:
 *
 *  - vehiculo: sus propietarios activos y su conductor asignado,
 *  - conductor: el conductor y su propietario,
 *  - propietario: el propietario.
 *
 * La licencia de conduccion tiene una segunda fuente: la fecha que se captura
 * en la ficha del conductor (driver.license_expiry). Se avisa con esa fecha
 * solo cuando el conductor no tiene la licencia cargada como documento activo;
 * si la tiene, manda el documento y el aviso sale por el camino general.
 *
 * Cada destinatario recibe su propia fila y su push; al conductor solo si
 * tiene acceso a la app. Cuando el propietario tambien conduce, su conductor
 * espejo comparte el mismo usuario y recibe un solo aviso.
 */
@Component
public class DocumentExpiryReminderScheduler {

    private static final Logger logger = LoggerFactory.getLogger(DocumentExpiryReminderScheduler.class);
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final DocumentFileRepository documentFileRepository;
    private final VehicleRepository vehicleRepository;
    private final VehicleOwnerRepository vehicleOwnerRepository;
    private final DriverRepository driverRepository;
    private final OwnerRepository ownerRepository;
    private final InAppNotificationUseCase inAppNotificationUseCase;

    public DocumentExpiryReminderScheduler(DocumentFileRepository documentFileRepository,
                                           VehicleRepository vehicleRepository,
                                           VehicleOwnerRepository vehicleOwnerRepository,
                                           DriverRepository driverRepository,
                                           OwnerRepository ownerRepository,
                                           InAppNotificationUseCase inAppNotificationUseCase) {
        this.documentFileRepository = documentFileRepository;
        this.vehicleRepository = vehicleRepository;
        this.vehicleOwnerRepository = vehicleOwnerRepository;
        this.driverRepository = driverRepository;
        this.ownerRepository = ownerRepository;
        this.inAppNotificationUseCase = inAppNotificationUseCase;
    }

    @Scheduled(cron = "${truck.parameter.document-expiry-reminder-cron:" + Constants.DOCUMENT_EXPIRY_REMINDER_CRON + "}",
            zone = Constants.ZONE_BOGOTA)
    public void notifyExpiringDocuments() {
        LocalDate today = LocalDate.now(ZoneId.of(Constants.ZONE_BOGOTA));
        for (Integer days : Constants.DOCUMENT_EXPIRY_REMINDER_DAYS) {
            notifyForDate(today.plusDays(days), days);
        }
    }

    private void notifyForDate(LocalDate expiryDate, int days) {
        notifyDocuments(expiryDate, days);
        notifyDriverLicenses(expiryDate, days);
    }

    private void notifyDocuments(LocalDate expiryDate, int days) {
        List<DocumentFile> documents = documentFileRepository.findByExpiryDateAndIsActiveTrue(expiryDate);
        if (documents.isEmpty()) {
            logger.info("Sin documentos que venzan el {} ({} dia(s) de antelacion)", expiryDate, days);
            return;
        }

        for (DocumentFile document : documents) {
            // Un documento que falle no puede dejar sin aviso a los demas.
            try {
                notifyDocument(document, days);
            } catch (Exception e) {
                logger.error("No se pudo avisar el vencimiento del documento {}: {}", document.getId(),
                        e.getMessage());
            }
        }
    }

    /**
     * Licencias registradas solo en la ficha del conductor. El aviso va sin
     * reference_id porque no hay fila de document_file que referenciar, y el id
     * del conductor se confundiria con el de un documento: el push lo usa para
     * decidir a que pantalla llevar.
     */
    private void notifyDriverLicenses(LocalDate expiryDate, int days) {
        List<Number> driverIds = driverRepository.findIdsByLicenseExpiryWithoutLicenseDocument(expiryDate,
                Constants.LICENSE_DOCUMENT_FILE_TYPE_NAME);
        if (driverIds.isEmpty()) {
            logger.info("Sin licencias de conductor que venzan el {} ({} dia(s) de antelacion)", expiryDate, days);
            return;
        }

        for (Number driverId : driverIds) {
            try {
                driverRepository.findById(driverId.longValue()).ifPresent(driver -> {
                    String message = buildMessage(Constants.LICENSE_DOCUMENT_FILE_TYPE_NAME,
                            " del conductor " + driver.getName(), expiryDate, days);
                    List<Long> ownerIds = driver.getOwnerId() == null ? List.of() : List.of(driver.getOwnerId());
                    notifyRecipients(null, message, ownerIds, driver);
                });
            } catch (Exception e) {
                logger.error("No se pudo avisar el vencimiento de la licencia del conductor {}: {}", driverId,
                        e.getMessage());
            }
        }
    }

    private void notifyDocument(DocumentFile document, int days) {
        if (document.getVehicleId() != null) {
            notifyVehicleDocument(document, days);
        } else if (document.getDriverId() != null) {
            notifyDriverDocument(document, days);
        } else if (document.getOwnerId() != null) {
            notifyOwnerDocument(document, days);
        }
    }

    private void notifyVehicleDocument(DocumentFile document, int days) {
        List<Long> ownerIds = vehicleOwnerRepository.findByVehicleIdAndIsActiveTrue(document.getVehicleId())
                .stream()
                .map(VehicleOwner::getOwnerId)
                .toList();
        Driver driver = vehicleRepository
                .findCurrentDriverIdByIdAndStatus(document.getVehicleId(), Vehicle.Status.Activo)
                .flatMap(driverId -> driverRepository.findById(driverId.longValue()))
                .orElse(null);
        if (ownerIds.isEmpty() && driver == null) {
            logger.warn("Vehiculo {} sin propietario activo ni conductor: no se avisa el documento {}",
                    document.getVehicleId(), document.getId());
            return;
        }

        String plate = vehicleRepository.findPlateById(document.getVehicleId()).orElse(null);
        String holder = plate == null ? "" : " del vehículo de placa " + plate;
        notifyRecipients(document.getId(), buildMessage(document, holder, days), ownerIds, driver);
    }

    private void notifyDriverDocument(DocumentFile document, int days) {
        Optional<Driver> driver = driverRepository.findById(document.getDriverId());
        if (driver.isEmpty()) {
            logger.warn("Conductor {} no existe: no se avisa el documento {}", document.getDriverId(),
                    document.getId());
            return;
        }

        List<Long> ownerIds = driver.get().getOwnerId() == null ? List.of() : List.of(driver.get().getOwnerId());
        String holder = " del conductor " + driver.get().getName();
        notifyRecipients(document.getId(), buildMessage(document, holder, days), ownerIds, driver.get());
    }

    private void notifyOwnerDocument(DocumentFile document, int days) {
        String holder = ownerRepository.findById(document.getOwnerId())
                .map(Owner::getName)
                .map(name -> " del propietario " + name)
                .orElse("");
        notifyRecipients(document.getId(), buildMessage(document, holder, days), List.of(document.getOwnerId()),
                null);
    }

    /**
     * Un aviso por propietario y otro para el conductor, cada uno con su fila
     * y su push. El reparto y la regla de la misma persona viven en
     * notifyOwnersAndDrivers.
     */
    private void notifyRecipients(Long documentId, String message, List<Long> ownerIds, Driver driver) {
        inAppNotificationUseCase.notifyOwnersAndDrivers(Constants.DOCUMENT_EXPIRY_EVENT_TYPE, message, ownerIds,
                documentId, driver == null ? List.of() : List.of(driver.getId()), null);

        String subject = documentId != null ? "documento " + documentId
                : "licencia del conductor " + (driver == null ? null : driver.getId());
        logger.info("Vencimiento de {}: avisado a {} propietario(s){}", subject, ownerIds.size(),
                driver != null ? " y al conductor " + driver.getId() : "");
    }

    /**
     * El nombre del documento es lo que el destinatario necesita leer primero;
     * la placa o el nombre del titular lo situan cuando hay varios documentos
     * iguales venciendo la misma semana.
     */
    private String buildMessage(DocumentFile document, String holder, int days) {
        String documentName = document.getDocumentFileType() == null
                ? "documento"
                : document.getDocumentFileType().getName();
        return buildMessage(documentName, holder, document.getExpiryDate(), days);
    }

    private String buildMessage(String documentName, String holder, LocalDate expiryDate, int days) {
        StringBuilder message = new StringBuilder("El documento ").append(documentName).append(holder);
        if (days == 0) {
            message.append(" vence hoy");
        } else {
            message.append(" vence en ").append(days).append(days == 1 ? " día" : " días");
        }
        message.append(" (").append(expiryDate.format(DATE_FORMAT)).append(").");
        return message.toString();
    }
}
