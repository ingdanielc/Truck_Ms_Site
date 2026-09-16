package cash.truck.push;

import cash.truck.application.usecases.InAppNotificationUseCase;
import cash.truck.domain.entities.Notification;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.entities.Users;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

/**
 * Regla de pertenencia de la bandeja: cada persona ve y modifica solo su copia,
 * aunque el propietario y sus conductores compartan owner_id.
 */
class NotificationVisibilityTest {

    private static final int OWNER_USER = 10;
    private static final int DRIVER_USER = 20;

    private Notification notification(Integer targetUserId) {
        Users ownerUser = new Users();
        ownerUser.setId(OWNER_USER);
        Owner owner = new Owner();
        owner.setId(7L);
        owner.setUser(ownerUser);

        Notification notification = new Notification();
        notification.setOwner(owner);
        if (targetUserId != null) {
            Users target = new Users();
            target.setId(targetUserId);
            notification.setTargetUser(target);
        }
        return notification;
    }

    @Test
    void elPropietarioVeSuCopiaPeroNoLaDelConductor() {
        assertTrue(InAppNotificationUseCase.isVisibleTo(notification(null), OWNER_USER));
        assertFalse(InAppNotificationUseCase.isVisibleTo(notification(DRIVER_USER), OWNER_USER));
    }

    @Test
    void elConductorVeSuCopiaPeroNoLaDelPropietario() {
        assertTrue(InAppNotificationUseCase.isVisibleTo(notification(DRIVER_USER), DRIVER_USER));
        assertFalse(InAppNotificationUseCase.isVisibleTo(notification(null), DRIVER_USER));
    }

    @Test
    void sinIdentidadNoSeVeNada() {
        assertFalse(InAppNotificationUseCase.isVisibleTo(notification(null), null));
    }
}
