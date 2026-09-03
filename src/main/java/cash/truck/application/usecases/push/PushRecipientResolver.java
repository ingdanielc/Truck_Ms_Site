package cash.truck.application.usecases.push;

import cash.truck.application.utility.Constants;
import cash.truck.domain.entities.Driver;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.entities.Users;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.UserRoleRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

/**
 * Traduce el destinatario de una notificacion al usuario que recibe el push.
 *
 * Hace falta porque los dos modelos no coinciden. Una notificacion interna se
 * direcciona por owner_id y target_role_id —de hecho target_user_id va siempre
 * en null hoy—, mientras que una suscripcion push cuelga de users.id. Sin este
 * puente no hay a quien enviarle.
 *
 * Que no haya usuario es normal, no un error: un propietario cargado por el
 * administrador puede no tener acceso a la app. En ese caso no hay push y la
 * notificacion interna sigue siendo su aviso, que es justo lo que el plan pide.
 */
@Service
public class PushRecipientResolver {

    private static final Logger logger = LoggerFactory.getLogger(PushRecipientResolver.class);

    private final OwnerRepository ownerRepository;
    private final DriverRepository driverRepository;
    private final UserRoleRepository userRoleRepository;

    public PushRecipientResolver(OwnerRepository ownerRepository, DriverRepository driverRepository,
                                 UserRoleRepository userRoleRepository) {
        this.ownerRepository = ownerRepository;
        this.driverRepository = driverRepository;
        this.userRoleRepository = userRoleRepository;
    }

    /**
     * Los administradores, para los avisos que no son de un propietario en
     * particular: hoy, que se creo una cuenta nueva. Son pocos y la consulta
     * trae solo ids, asi que no compensa cachearlos: un administrador dado de
     * alta hoy debe empezar a recibir avisos hoy, sin reiniciar el servicio.
     */
    public List<Integer> resolveAdminUserIds() {
        List<Integer> userIds = userRoleRepository.findUserIdsByRoleId(Constants.ROLE_ID_ADMIN);
        if (userIds.isEmpty()) {
            logger.warn("No hay usuarios con rol administrador: nadie recibe el aviso");
        }
        return userIds;
    }

    public Optional<Integer> resolveOwnerUserId(Long ownerId) {
        if (ownerId == null) {
            return Optional.empty();
        }
        Optional<Integer> userId = ownerRepository.findById(ownerId)
                .map(Owner::getUser)
                .map(Users::getId);
        if (userId.isEmpty()) {
            logger.debug("El propietario {} no tiene usuario: no hay push que enviar", ownerId);
        }
        return userId;
    }

    public Optional<Integer> resolveDriverUserId(Long driverId) {
        if (driverId == null) {
            return Optional.empty();
        }
        Optional<Integer> userId = driverRepository.findById(driverId)
                .map(Driver::getUser)
                .map(Users::getId);
        if (userId.isEmpty()) {
            logger.debug("El conductor {} no tiene usuario: no hay push que enviar", driverId);
        }
        return userId;
    }
}
