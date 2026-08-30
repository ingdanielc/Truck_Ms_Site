package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.Driver;
import cash.truck.domain.entities.Roles;
import cash.truck.domain.entities.UserRole;
import cash.truck.domain.entities.Users;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.RolesRepository;
import cash.truck.domain.dtos.DriverCountsDTO;
import cash.truck.application.usecases.notifications.DriverNotificationUseCase;
import cash.truck.application.utility.Constants;
import jakarta.persistence.EntityNotFoundException;
import jakarta.persistence.criteria.JoinType;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import jakarta.transaction.Transactional;

import java.util.Collections;
import java.util.List;
import java.util.function.Consumer;

@Service
@Transactional
public class DriverUseCase {

    private static final Logger logger = LoggerFactory.getLogger(DriverUseCase.class);

    private final DriverRepository driverRepository;
    private final SecurityUseCase securityUseCase;
    private final InAppNotificationUseCase inAppNotificationUseCase;
    private final RolesRepository rolesRepository;
    private final DriverNotificationUseCase driverNotificationUseCase;

    public DriverUseCase(DriverRepository driverRepository, SecurityUseCase securityUseCase,
            InAppNotificationUseCase inAppNotificationUseCase, RolesRepository rolesRepository,
            DriverNotificationUseCase driverNotificationUseCase) {
        this.driverRepository = driverRepository;
        this.securityUseCase = securityUseCase;
        this.inAppNotificationUseCase = inAppNotificationUseCase;
        this.rolesRepository = rolesRepository;
        this.driverNotificationUseCase = driverNotificationUseCase;
    }

    public List<Driver> getAllDrivers() {
        return driverRepository.findAll();
    }

    public Driver save(Driver driver) {
        Driver driverNew;
        boolean isNew = driver.getId() == null;
        // Se retiene para la bienvenida: despues de cifrarla ya no se puede recuperar.
        String plainPassword = null;

        if (!isNew) {
            driverNew = driverRepository.findById(driver.getId())
                    .orElseThrow(() -> new EntityNotFoundException("Driver not found"));

            // Synchronize email and name with User entity if they are changing
            if (driverNew.getUser() != null) {
                boolean changed = false;
                if (driver.getEmail() != null && !driver.getEmail().equals(driverNew.getEmail())) {
                    driverNew.getUser().setEmail(driver.getEmail());
                    changed = true;
                }
                if (driver.getName() != null && !driver.getName().equals(driverNew.getName())) {
                    driverNew.getUser().setName(driver.getName());
                    changed = true;
                }
                if (changed) {
                    securityUseCase.saveUser(driverNew.getUser());
                }
            } else if (driver.getPassword() != null && !driver.getPassword().isEmpty()) {
                // If user doesn't exist but password is provided during update, create user
                Users user = new Users();
                user.setName(driverNew.getName());
                user.setEmail(driverNew.getEmail());
                byte[] decodedBytes = java.util.Base64.getDecoder().decode(driver.getPassword());
                String decodedPassword = new String(decodedBytes, java.nio.charset.StandardCharsets.UTF_8);
                plainPassword = decodedPassword;
                user.setPassword(SecurityUseCase.getHashSHA512(decodedPassword));
                user.setStatus(Constants.STATUS_ACTIVE);

                Roles role = rolesRepository.findById(3)
                        .orElseThrow(() -> new EntityNotFoundException("Role Driver not found"));

                UserRole userRole = new UserRole();
                userRole.setRole(role);
                userRole.setUser(user);
                user.setUserRoles(Collections.singletonList(userRole));

                Users savedUser = securityUseCase.saveUser(user);
                driverNew.setUser(savedUser);
            }
        } else {
            driverNew = new Driver();
            // Handle User creation for new Drivers
            if (driver.getPassword() != null && !driver.getPassword().isEmpty()) {
                Users user = new Users();
                user.setName(driver.getName());
                user.setEmail(driver.getEmail());
                byte[] decodedBytes = java.util.Base64.getDecoder().decode(driver.getPassword());
                String decodedPassword = new String(decodedBytes, java.nio.charset.StandardCharsets.UTF_8);
                plainPassword = decodedPassword;
                user.setPassword(SecurityUseCase.getHashSHA512(decodedPassword));
                user.setStatus(Constants.STATUS_ACTIVE);

                Roles role = rolesRepository.findById(3)
                        .orElseThrow(() -> new EntityNotFoundException("Role Driver not found"));

                UserRole userRole = new UserRole();
                userRole.setRole(role);
                userRole.setUser(user);
                user.setUserRoles(Collections.singletonList(userRole));

                Users savedUser = securityUseCase.saveUser(user);
                driverNew.setUser(savedUser);
            }
        }

        applyFields(driver, driverNew);
        Driver savedDriver = driverRepository.save(driverNew);

        String message = isNew ? "Se ha creado un nuevo conductor: " + savedDriver.getName()
                : "Se ha actualizado el conductor: " + savedDriver.getName();
        inAppNotificationUseCase.createNotification("DRIVER_EVENT", message, 1, null, savedDriver.getOwnerId(),
                savedDriver.getId().longValue());

        sendWelcomeSafely(savedDriver, plainPassword);

        return savedDriver;
    }

    /**
     * La bienvenida solo tiene sentido cuando se acaban de emitir credenciales:
     * un conductor sin acceso a la app no tiene nada que recibir. Se envia tanto
     * al crearlo con contrasena como al concedersela despues.
     *
     * Es accesoria, igual que la del propietario: el conductor ya quedo guardado
     * y no puede perderse porque WhatsApp o Twilio fallen.
     */
    private void sendWelcomeSafely(Driver driver, String plainPassword) {
        if (plainPassword == null) {
            return;
        }
        try {
            driverNotificationUseCase.sendWelcome(driver, plainPassword);
        } catch (Exception e) {
            logger.error("No se pudo enviar la bienvenida al conductor {}: {}", driver.getId(), e.getMessage());
        }
    }

    private void applyFields(Driver source, Driver target) {
        setIfNotNull(source.getPhoto(), target::setPhoto);
        setIfNotNull(source.getDocumentTypeId(), target::setDocumentTypeId);
        setIfNotNull(source.getDocumentNumber(), target::setDocumentNumber);
        setIfNotNull(source.getName(), target::setName);
        setIfNotNull(source.getEmail(), target::setEmail);
        setIfNotNull(source.getCellPhone(), target::setCellPhone);
        setIfNotNull(source.getCityId(), target::setCityId);
        setIfNotNull(source.getGenderId(), target::setGenderId);
        setIfNotNull(source.getBirthdate(), target::setBirthdate);
        setIfNotNull(source.getLicenseCategory(), target::setLicenseCategory);
        setIfNotNull(source.getLicenseNumber(), target::setLicenseNumber);
        setIfNotNull(source.getLicenseExpiry(), target::setLicenseExpiry);
        setIfNotNull(source.getSalaryTypeId(), target::setSalaryTypeId);
        setIfNotNull(source.getSalary(), target::setSalary);
        setIfNotNull(source.getUser(), target::setUser);
        setIfNotNull(source.getOwnerId(), target::setOwnerId);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }

    public Page<Driver> findWithFilterOptional(FilterRequest filterRequest) {
        Pageable pageable = UtilsFilter.getPageable(filterRequest);
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<Driver> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        Page<Driver> page;
        if (specification != null) {
            page = driverRepository.findAll(specification, pageable);
        } else {
            page = driverRepository.findAll(pageable);
        }

        return new PageImpl<>(page.getContent(), pageable, page.getTotalElements());
    }

    public DriverCountsDTO getCounts(FilterRequest filterRequest) {
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        Specification<Driver> baseSpec = null;
        if (!searchCriteriaList.isEmpty()) {
            baseSpec = new GenericSpecification<>(searchCriteriaList);
        }

        Specification<Driver> activeSpec = (root, query, cb) -> {
            var userJoin = root.join("user", JoinType.LEFT);
            return cb.or(
                    cb.equal(userJoin.get("status"), Constants.STATUS_ACTIVE),
                    cb.isNull(userJoin.get("id"))
            );
        };

        Specification<Driver> inactiveSpec = (root, query, cb) -> {
            var userJoin = root.join("user", JoinType.LEFT);
            return cb.equal(userJoin.get("status"), Constants.STATUS_INACTIVE);
        };

        long total = baseSpec != null ? driverRepository.count(baseSpec) : driverRepository.count();
        long active = driverRepository.count(baseSpec != null ? baseSpec.and(activeSpec) : activeSpec);
        long inactive = driverRepository.count(baseSpec != null ? baseSpec.and(inactiveSpec) : inactiveSpec);

        return new DriverCountsDTO(total, active, inactive);
    }
}
