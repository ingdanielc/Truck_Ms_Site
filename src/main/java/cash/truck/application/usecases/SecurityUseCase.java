package cash.truck.application.usecases;

import com.fasterxml.jackson.core.JsonProcessingException;
import cash.truck.application.utility.Constants;
import cash.truck.application.utility.JWTManager;
import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.*;
import cash.truck.domain.repositories.RolesRepository;
import cash.truck.domain.repositories.UserRoleRepository;
import cash.truck.domain.repositories.UsersRepository;
import jakarta.persistence.EntityNotFoundException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.List;
import java.util.Optional;
import java.util.function.Consumer;

import static cash.truck.application.exception.PartnerException.duplicateEntityException;

@Service
public class SecurityUseCase {

    private static final Logger logger = LoggerFactory.getLogger(SecurityUseCase.class);

    @Autowired
    private final UsersRepository usersRepository;
    private final RolesRepository rolesRepository;
    private final UserRoleRepository userRoleRepository;

    public SecurityUseCase(UsersRepository usersRepository,
                           RolesRepository rolesRepository,
                           UserRoleRepository userRoleRepository){
        this.usersRepository = usersRepository;
        this.rolesRepository = rolesRepository;
        this.userRoleRepository = userRoleRepository;
    }

    public List<Users> getAllUsers() {
        return usersRepository.findAll();
    }

    public Users saveUser(Users user) {
        Users userNew;

        // Validate duplicated
        if (user.getName() != null && user.getEmail() != null) {
            Optional<Users> existingUser = usersRepository.findByNameAndEmail(
                    user.getName(),
                    user.getEmail()
            );
            if (existingUser.isPresent() &&
                    (user.getId() == null || !existingUser.get().getId().equals(user.getId()))) {
                throw duplicateEntityException();
            }

            existingUser = usersRepository.findByEmail(user.getEmail());
            if (existingUser.isPresent() &&
                    (user.getId() == null || !existingUser.get().getId().equals(user.getId()))) {
                throw duplicateEntityException();
            }
        }
        if (user.getId() != null) {
            userNew = usersRepository.findById(user.getId())
                    .orElseThrow(() -> new EntityNotFoundException("User not found"));
        } else {
            userNew = new Users();
        }

        createUser(userNew, user);
        userNew = usersRepository.save(userNew);

        // Set rol user
        if(user.getId() == null) {
            UserRole userRole = new UserRole();
            userRole.setUser(userNew);
            userRole.setRole(user.getUserRoles().get(0).getRole());
            userRoleRepository.save(userRole);
        }
        return userNew;
    }

    private void createUser(Users userNew, Users user) {
        setIfNotNull(user.getName(), userNew::setName);
        setIfNotNull(user.getEmail(), userNew::setEmail);
        setIfNotNull(user.getPassword(), userNew::setPassword);
        setIfNotNull(user.getStatus(), userNew::setStatus);
    }

    private <T> void setIfNotNull(T value, Consumer<T> setter) {
        if (value != null) {
            setter.accept(value);
        }
    }

    public JSONObject checkAuthentication(Users dataUser) {
        try {
            JSONObject outputToResponse = new JSONObject();
            Optional<Users> userOpt = usersRepository.findByEmailAndPassword(dataUser.getEmail(), dataUser.getPassword());
            if (userOpt.isPresent()) {
                Users user = userOpt.get();
                if (dataUser.getPassword().equals(user.getPassword()) && user.getStatus().equals(Constants.STATUS_ACTIVE)) {
                    outputToResponse = buildInformation(user);
                } else {
                    outputToResponse.put(Constants.PARAMETER_AUTHORIZED, Constants.PARAMETER_INVALID_LOGIN);
                }
            } else {
                userOpt = usersRepository.findByEmail(dataUser.getEmail());
                if (userOpt.isPresent()) {
                    outputToResponse.put(Constants.PARAMETER_AUTHORIZED, Constants.PARAMETER_INVALID_LOGIN);
                } else {
                    outputToResponse.put(Constants.PARAMETER_AUTHORIZED, Constants.PARAMETER_INVALID_USER);
                }
            }
            return outputToResponse;
        } catch (Exception e){
            JSONObject outputToResponse = new JSONObject();
            logger.error(e.getMessage());
            outputToResponse.put(Constants.PARAMETER_AUTHORIZED, Constants.PARAMETER_INVALID_KEY);
            return outputToResponse;
        }
    }

    public static String getHashSHA512(String input) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-512");
            byte[] encodedHash = digest.digest(input.getBytes(StandardCharsets.UTF_8));

            // Convert bytes to hexadecimal
            StringBuilder hexString = new StringBuilder();
            for (byte b : encodedHash) {
                hexString.append(String.format("%02x", b));
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("Error getting hash SHA-512", e);
        }
    }

    public JSONObject buildInformation(Users user) throws JsonProcessingException {
        JSONObject outputToResponse = new JSONObject();
        JSONObject dataInJWT = new JSONObject();
        dataInJWT.put(Constants.PARAMETER_ID, user.getId());
        dataInJWT.put(Constants.PARAMETER_EMAIL, user.getEmail());
        dataInJWT.put(Constants.PARAMETER_NAME, user.getName());

        String jwtValid= JWTManager.createJWT(dataInJWT);

        //Create JWT Header
        outputToResponse.put(Constants.PARAMETER_AUTHORIZED, Constants.PARAMETER_OK);
        outputToResponse.put(Constants.PARAMETER_JWT, jwtValid);
        return outputToResponse;
    }

    public Page<Users> findWithFilterOptional(FilterRequest filterRequest) {

        // Create object page
        Pageable pageable = UtilsFilter.getPageable(filterRequest);

        // Convertir FilterItem a SearchCriteria si hay filtros
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        // Construir especificación utilizando los criterios si hay filtros
        Specification<Users> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        // Get page result
        Page<Users> userPage;
        if (specification != null) {
            userPage = usersRepository.findAll(specification, pageable);
        } else {
            userPage = usersRepository.findAll(pageable);
        }

        return new PageImpl<>(userPage.getContent(), pageable, userPage.getTotalElements());
    }

    public List<Roles> getAllRoles() {
        return rolesRepository.findAll();
    }
}
