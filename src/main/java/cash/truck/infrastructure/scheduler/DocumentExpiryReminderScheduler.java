package cash.truck.infrastructure.scheduler;

import cash.truck.application.usecases.InAppNotificationUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.domain.entities.DocumentFile;
import cash.truck.domain.entities.VehicleOwner;
import cash.truck.domain.repositories.DocumentFileRepository;
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

/**
 * Avisa al propietario que un documento de su vehiculo esta por vencer.
 *
 * El aviso es interno: se guarda en la bandeja de notificaciones de la app y no
 * sale por WhatsApp ni por push, a diferencia del recordatorio de suscripcion.
 *
 * Corre una vez al dia y consulta la fecha de vencimiento exacta de cada
 * antelacion —10, 3 y 0 dias—, no un rango, de modo que a cada propietario le
 * llega un aviso por documento y por hito. Si el servicio estuvo caido a la
 * hora programada ese dia se pierde el aviso de ese hito: no hay reintento,
 * porque repetirlo al dia siguiente cambiaria los dias de antelacion.
 *
 * Solo mira documentos de vehiculo; los del conductor y los del propietario
 * quedan fuera hasta que se decida a quien avisarles.
 */
@Component
public class DocumentExpiryReminderScheduler {

    private static final Logger logger = LoggerFactory.getLogger(DocumentExpiryReminderScheduler.class);
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    private final DocumentFileRepository documentFileRepository;
    private final VehicleRepository vehicleRepository;
    private final VehicleOwnerRepository vehicleOwnerRepository;
    private final InAppNotificationUseCase inAppNotificationUseCase;

    public DocumentExpiryReminderScheduler(DocumentFileRepository documentFileRepository,
                                           VehicleRepository vehicleRepository,
                                           VehicleOwnerRepository vehicleOwnerRepository,
                                           InAppNotificationUseCase inAppNotificationUseCase) {
        this.documentFileRepository = documentFileRepository;
        this.vehicleRepository = vehicleRepository;
        this.vehicleOwnerRepository = vehicleOwnerRepository;
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
        List<DocumentFile> documents = documentFileRepository.findByExpiryDateAndIsActiveTrue(expiryDate);
        if (documents.isEmpty()) {
            logger.info("Sin documentos que venzan el {} ({} dia(s) de antelacion)", expiryDate, days);
            return;
        }

        for (DocumentFile document : documents) {
            if (document.getVehicleId() == null) {
                continue;
            }
            // Un documento que falle no puede dejar sin aviso a los demas.
            try {
                notifyOwners(document, days);
            } catch (Exception e) {
                logger.error("No se pudo avisar el vencimiento del documento {}: {}", document.getId(),
                        e.getMessage());
            }
        }
    }

    private void notifyOwners(DocumentFile document, int days) {
        List<VehicleOwner> owners = vehicleOwnerRepository.findByVehicleIdAndIsActiveTrue(document.getVehicleId());
        if (owners.isEmpty()) {
            logger.warn("Vehiculo {} sin propietario activo: no se avisa el documento {}",
                    document.getVehicleId(), document.getId());
            return;
        }

        String message = buildMessage(document, days);
        for (VehicleOwner owner : owners) {
            inAppNotificationUseCase.createNotification(Constants.DOCUMENT_EXPIRY_EVENT_TYPE, message,
                    Constants.ROLE_ID_ADMIN, null, owner.getOwnerId(), document.getId());
        }
        logger.info("Avisado a {} propietario(s) por el documento {} del vehiculo {}", owners.size(),
                document.getId(), document.getVehicleId());
    }

    /**
     * El nombre del documento es lo que el propietario necesita leer primero;
     * la placa lo situa cuando tiene varios vehiculos con el mismo documento
     * venciendo la misma semana.
     */
    private String buildMessage(DocumentFile document, int days) {
        String documentName = document.getDocumentFileType() == null
                ? "documento"
                : document.getDocumentFileType().getName();
        String plate = vehicleRepository.findPlateById(document.getVehicleId()).orElse(null);

        StringBuilder message = new StringBuilder("El documento ").append(documentName);
        if (plate != null) {
            message.append(" del vehículo de placa ").append(plate);
        }
        if (days == 0) {
            message.append(" vence hoy");
        } else {
            message.append(" vence en ").append(days).append(days == 1 ? " día" : " días");
        }
        message.append(" (").append(document.getExpiryDate().format(DATE_FORMAT)).append(").");
        return message.toString();
    }
}
