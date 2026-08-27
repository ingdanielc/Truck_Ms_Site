package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.*;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.RolesRepository;
import cash.truck.domain.repositories.VehicleOwnerRepository;
import cash.truck.application.usecases.notifications.OwnerNotificationUseCase;
import cash.truck.application.utility.Constants;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import jakarta.transaction.Transactional;

import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Collections;
import java.util.List;
import java.util.function.Consumer;

import static cash.truck.application.exception.PartnerException.duplicateEntityException;

@Service
@Transactional
public class OwnerUseCase {

    private static final Logger logger = LoggerFactory.getLogger(OwnerUseCase.class);

    private final OwnerRepository ownerRepository;
    private final VehicleOwnerRepository vehicleOwnerRepository;
    private final SecurityUseCase securityUseCase;
    private final InAppNotificationUseCase inAppNotificationUseCase;
    private final RolesRepository rolesRepository;
    private final DriverRepository driverRepository;
    private final OwnerNotificationUseCase ownerNotificationUseCase;

    public OwnerUseCase(OwnerRepository ownerRepository,
            VehicleOwnerRepository vehicleOwnerRepository,
            SecurityUseCase securityUseCase,
            InAppNotificationUseCase inAppNotificationUseCase,
            RolesRepository rolesRepository,
            DriverRepository driverRepository,
            OwnerNotificationUseCase ownerNotificationUseCase) {
        this.ownerRepository = ownerRepository;
        this.vehicleOwnerRepository = vehicleOwnerRepository;
        this.securityUseCase = securityUseCase;
        this.inAppNotificationUseCase = inAppNotificationUseCase;
        this.rolesRepository = rolesRepository;
        this.driverRepository = driverRepository;
        this.ownerNotificationUseCase = ownerNotificationUseCase;
    }

    public List<Owner> getAllOwners() {
        return ownerRepository.findAll();
    }

    public Owner save(Owner owner) {
        return save(owner, false);
    }

    /**
     * @param callerIsAdmin cuando es false se descarta subscriptionEndDate del
     *                      payload: en edicion se conserva el valor existente y en
     *                      creacion se aplica el valor por defecto.
     */
    public Owner save(Owner owner, boolean callerIsAdmin) {
        Owner ownerNew;
        boolean isNew = owner.getId() == null;
        // Se retiene para la bienvenida: despues de cifrarla ya no se puede recuperar.
        String plainPassword = null;

        // Solo el administrador puede definir la fecha de fin de suscripcion
        if (!callerIsAdmin) {
            owner.setSubscriptionEndDate(null);
        }

        if (!isNew) {
            ownerNew = ownerRepository.findById(owner.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Owner not found"));

            // Synchronize email and name with User entity if they are changing
            if (ownerNew.getUser() != null) {
                boolean changed = false;
                if (owner.getEmail() != null && !owner.getEmail().equals(ownerNew.getEmail())) {
                    ownerNew.getUser().setEmail(owner.getEmail());
                    changed = true;
                }
                if (owner.getName() != null && !owner.getName().equals(ownerNew.getName())) {
                    ownerNew.getUser().setName(owner.getName());
                    changed = true;
                }
                if (changed) {
                    securityUseCase.saveUser(ownerNew.getUser());
                }
            }

            // Sync Driver roles and license fields if isDriver is true
            if (Boolean.TRUE.equals(owner.getIsDriver())) {
                // Ensure role 3 (Driver) is assigned to the user
                boolean hasDriverRole = ownerNew.getUser().getUserRoles().stream()
                        .anyMatch(ur -> ur.getRole().getId().equals(3));
                if (!hasDriverRole) {
                    Roles roleDriver = rolesRepository.findById(3)
                            .orElseThrow(() -> new EntityNotFoundException("Role Driver not found"));
                    UserRole userRoleDriver = new UserRole();
                    userRoleDriver.setRole(roleDriver);
                    userRoleDriver.setUser(ownerNew.getUser());
                    ownerNew.getUser().getUserRoles().add(userRoleDriver);
                    securityUseCase.saveUser(ownerNew.getUser());
                }

                // Update or Create Driver record
                java.util.Optional<Driver> driverOpt = driverRepository.findByOwnerIdAndDocumentNumber(ownerNew.getId(), ownerNew.getDocumentNumber());
                if (driverOpt.isPresent()) {
                    Driver driver = driverOpt.get();
                    if (owner.getLicenseCategory() != null) driver.setLicenseCategory(owner.getLicenseCategory());
                    if (owner.getLicenseNumber() != null) driver.setLicenseNumber(owner.getLicenseNumber());
                    if (owner.getLicenseExpiry() != null) driver.setLicenseExpiry(owner.getLicenseExpiry());
                    
                    // Also sync name/email/cellphone if they changed
                    if (owner.getName() != null) driver.setName(owner.getName());
                    if (owner.getEmail() != null) driver.setEmail(owner.getEmail());
                    if (owner.getCellPhone() != null) driver.setCellPhone(owner.getCellPhone());
                    if (owner.getPhoto() != null) driver.setPhoto(owner.getPhoto());
                    if (owner.getDocumentTypeId() != null) driver.setDocumentTypeId(owner.getDocumentTypeId());
                    if (owner.getDocumentNumber() != null) driver.setDocumentNumber(owner.getDocumentNumber());
                    if (owner.getCityId() != null) driver.setCityId(owner.getCityId());
                    if (owner.getGenderId() != null) driver.setGenderId(owner.getGenderId());
                    if (owner.getBirthdate() != null) driver.setBirthdate(owner.getBirthdate());
                    
                    driverRepository.save(driver);
                } else {
                    // Create new Driver record
                    Driver driver = new Driver();
                    driver.setPhoto(ownerNew.getPhoto());
                    driver.setDocumentTypeId(ownerNew.getDocumentTypeId());
                    driver.setDocumentNumber(ownerNew.getDocumentNumber());
                    driver.setName(ownerNew.getName());
                    driver.setEmail(ownerNew.getEmail());
                    driver.setCellPhone(ownerNew.getCellPhone());
                    driver.setCityId(ownerNew.getCityId());
                    driver.setGenderId(ownerNew.getGenderId());
                    driver.setBirthdate(ownerNew.getBirthdate());
                    driver.setLicenseCategory(owner.getLicenseCategory());
                    if (owner.getLicenseNumber() != null) driver.setLicenseNumber(owner.getLicenseNumber());
                    if (owner.getLicenseExpiry() != null) driver.setLicenseExpiry(owner.getLicenseExpiry());
                    driver.setUser(ownerNew.getUser());
                    driver.setOwnerId(ownerNew.getId());
                    driverRepository.save(driver);
                }
            }
        } else {
            ownerNew = new Owner();
            // Handle User creation for new Owners
            if (owner.getPassword() != null && !owner.getPassword().isEmpty()) {
                Users user = new Users();
                user.setName(owner.getName());
                user.setEmail(owner.getEmail());
                byte[] decodedBytes = java.util.Base64.getDecoder().decode(owner.getPassword());
                String decodedPassword = new String(decodedBytes, java.nio.charset.StandardCharsets.UTF_8);
                plainPassword = decodedPassword;
                user.setPassword(SecurityUseCase.getHashSHA512(decodedPassword));
                user.setStatus(Constants.STATUS_ACTIVE);

                Roles roleOwner = rolesRepository.findById(2)
                        .orElseThrow(() -> new EntityNotFoundException("Role Owner not found"));

                UserRole userRoleOwner = new UserRole();
                userRoleOwner.setRole(roleOwner);
                userRoleOwner.setUser(user);

                if (Boolean.TRUE.equals(owner.getIsDriver())) {
                    Roles roleDriver = rolesRepository.findById(3)
                            .orElseThrow(() -> new EntityNotFoundException("Role Driver not found"));
                    UserRole userRoleDriver = new UserRole();
                    userRoleDriver.setRole(roleDriver);
                    userRoleDriver.setUser(user);
                    user.setUserRoles(java.util.Arrays.asList(userRoleOwner, userRoleDriver));
                } else {
                    user.setUserRoles(Collections.singletonList(userRoleOwner));
                }

                Users savedUser = securityUseCase.saveUser(user);
                ownerNew.setUser(savedUser);
            }
        }

        applyFields(owner, ownerNew);

        if (ownerNew.getMaxVehicles() == null) {
            ownerNew.setMaxVehicles(3);
        }

        if (isNew && ownerNew.getSubscriptionEndDate() == null) {
            ownerNew.setSubscriptionEndDate(LocalDate.now(ZoneId.of(Constants.ZONE_BOGOTA))
                    .plusMonths(Constants.SUBSCRIPTION_DEFAULT_MONTHS));
        }

        Owner savedOwner = ownerRepository.save(ownerNew);

        // Create driver if isDriver is true
        if (isNew && Boolean.TRUE.equals(owner.getIsDriver())) {
            Driver driver = new Driver();
            driver.setPhoto(savedOwner.getPhoto());
            driver.setDocumentTypeId(savedOwner.getDocumentTypeId());
            driver.setDocumentNumber(savedOwner.getDocumentNumber());
            driver.setName(savedOwner.getName());
            driver.setEmail(savedOwner.getEmail());
            driver.setCellPhone(savedOwner.getCellPhone());
            driver.setCityId(savedOwner.getCityId());
            driver.setGenderId(savedOwner.getGenderId());
            driver.setBirthdate(savedOwner.getBirthdate());
            driver.setLicenseCategory(owner.getLicenseCategory());
            driver.setLicenseNumber(owner.getLicenseNumber());
            driver.setLicenseExpiry(owner.getLicenseExpiry());
            driver.setUser(savedOwner.getUser());
            driver.setOwnerId(savedOwner.getId());
            driverRepository.save(driver);
        }

        String message = isNew ? "Se ha creado un nuevo propietario: " + savedOwner.getName()
                : "Se ha actualizado el propietario: " + savedOwner.getName();
        inAppNotificationUseCase.createNotification("OWNER_EVENT", message, 1, null, null,
                savedOwner.getId().longValue());

        if (isNew) {
            sendWelcomeSafely(savedOwner, plainPassword);
        }

        return savedOwner;
    }

    /**
     * La bienvenida es accesoria: el propietario ya quedo creado y no puede
     * perderse porque WhatsApp o Twilio fallen. Por eso se traga cualquier error
     * y el envio corre en su propia transaccion.
     */
    private void sendWelcomeSafely(Owner owner, String plainPassword) {
        if (plainPassword == null) {
            // Propietario sin usuario: no hay credenciales que comunicar.
            return;
        }
        try {
            ownerNotificationUseCase.sendWelcome(owner, plainPassword);
        } catch (Exception e) {
            logger.error("No se pudo enviar la bienvenida al propietario {}: {}", owner.getId(), e.getMessage());
        }
    }

    private void applyFields(Owner source, Owner target) {
        setIfNotNull(source.getPhoto(), target::setPhoto);
        setIfNotNull(source.getDocumentTypeId(), target::setDocumentTypeId);
        setIfNotNull(source.getDocumentNumber(), target::setDocumentNumber);
        setIfNotNull(source.getName(), target::setName);
        setIfNotNull(source.getEmail(), target::setEmail);
        setIfNotNull(source.getCellPhone(), target::setCellPhone);
        setIfNotNull(source.getCityId(), target::setCityId);
        setIfNotNull(source.getGenderId(), target::setGenderId);
        setIfNotNull(source.getBirthdate(), target::setBirthdate);
        setIfNotNull(source.getUser(), target::setUser);
        setIfNotNull(source.getMaxVehicles(), target::setMaxVehicles);
        setIfNotNull(source.getIsDriver(), target::setIsDriver);
        setIfNotNull(source.getSubscriptionEndDate(), target::setSubscriptionEndDate);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }

    public Page<Owner> findWithFilterOptional(FilterRequest filterRequest) {
        Pageable pageable = UtilsFilter.getPageable(filterRequest);
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<Owner> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        Page<Owner> page;
        if (specification != null) {
            page = ownerRepository.findAll(specification, pageable);
        } else {
            page = ownerRepository.findAll(pageable);
        }

        return new PageImpl<>(page.getContent(), pageable, page.getTotalElements());
    }

    public VehicleOwner setVehicle(VehicleOwner vehicleOwner) {
        // Validate duplicate assignment
        boolean exists = vehicleOwnerRepository.findAll().stream()
                .anyMatch(vo -> vo.getVehicleId().equals(vehicleOwner.getVehicleId())
                        && vo.getOwnerId().equals(vehicleOwner.getOwnerId())
                        && (vehicleOwner.getId() == null || !vo.getId().equals(vehicleOwner.getId())));
        if (exists) {
            throw duplicateEntityException();
        }
        return vehicleOwnerRepository.save(vehicleOwner);
    }
}
