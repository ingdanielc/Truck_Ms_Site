package cash.truck.application.usecases.push;

import cash.truck.domain.entities.Driver;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.entities.Users;
import cash.truck.domain.repositories.DriverRepository;
import cash.truck.domain.repositories.OwnerRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

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

    public PushRecipientResolver(OwnerRepository ownerRepository, DriverRepository driverRepository) {
        this.ownerRepository = ownerRepository;
        this.driverRepository = driverRepository;
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
