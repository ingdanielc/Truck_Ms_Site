package cash.truck.documents;

import cash.truck.application.usecases.DocumentFileUseCase;
import cash.truck.domain.entities.DocumentFile;
import cash.truck.domain.entities.DocumentFileType;
import cash.truck.domain.entities.Driver;
import cash.truck.domain.enums.DocumentHolderEnum;
import cash.truck.domain.repositories.DocumentFileRepository;
import cash.truck.domain.repositories.DocumentFileTypeRepository;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.VehicleRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

/** Al cargar o renovar la licencia como documento, la ficha del conductor toma su vencimiento. */
class DocumentFileLicenseSyncTest {

    private final DocumentFileRepository documentFileRepository = mock(DocumentFileRepository.class);
    private final DocumentFileTypeRepository typeRepository = mock(DocumentFileTypeRepository.class);
    private final DriverRepository driverRepository = mock(DriverRepository.class);
    private final DocumentFileUseCase useCase = new DocumentFileUseCase(documentFileRepository, typeRepository,
            mock(VehicleRepository.class), driverRepository, mock(OwnerRepository.class));

    private final Driver driver = new Driver();

    @BeforeEach
    void setUp() {
        driver.setId(5L);
        when(driverRepository.existsById(5L)).thenReturn(true);
        when(driverRepository.findById(5L)).thenReturn(Optional.of(driver));
        when(documentFileRepository.save(any(DocumentFile.class))).thenAnswer(call -> call.getArgument(0));
        when(typeRepository.findById(1)).thenReturn(Optional.of(type(1, "Licencia de Conducción")));
        when(typeRepository.findById(2)).thenReturn(Optional.of(type(2, "Certificado de ARL")));
    }

    private DocumentFileType type(int id, String name) {
        DocumentFileType type = new DocumentFileType();
        type.setId(id);
        type.setName(name);
        type.setAppliesTo(DocumentHolderEnum.DRIVER);
        type.setRequiresExpiry(true);
        return type;
    }

    private DocumentFile document(int typeId, LocalDate expiry) {
        DocumentFile document = new DocumentFile();
        document.setDocumentFileTypeId(typeId);
        document.setDriverId(5L);
        document.setExpiryDate(expiry);
        return document;
    }

    @Test
    void laLicenciaActualizaElVencimientoDelConductor() {
        useCase.saveAll(List.of(document(1, LocalDate.of(2031, 3, 15))));

        assertEquals(java.sql.Date.valueOf(LocalDate.of(2031, 3, 15)), driver.getLicenseExpiry());
        verify(driverRepository).save(driver);
    }

    @Test
    void otroDocumentoDelConductorNoTocaLaLicencia() {
        useCase.saveAll(List.of(document(2, LocalDate.of(2031, 3, 15))));

        assertNull(driver.getLicenseExpiry());
        verify(driverRepository, never()).save(any());
    }

    @Test
    void unaLicenciaInactivaNoDevuelveLaFichaAUnaFechaVieja() {
        DocumentFile old = document(1, LocalDate.of(2020, 1, 1));
        old.setIsActive(false);

        useCase.saveAll(List.of(old));

        assertNull(driver.getLicenseExpiry());
        verify(driverRepository, never()).save(any());
    }
}
