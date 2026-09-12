package cash.truck.domain.dtos;

/**
 * Se publica cuando ya quedo guardada una fila en notification.
 *
 * Lleva los datos crudos y no la entidad a proposito: quien lo escucha corre
 * despues del commit, fuera de la sesion de Hibernate que la cargo, y tocar ahi
 * una relacion perezosa —owner, por ejemplo— reventaria con
 * LazyInitializationException.
 *
 * actorUserId es el usuario que provoco el evento, cuando se conoce. Solo sirve
 * para no mandarle por push el aviso de su propia accion; la notificacion
 * interna se guarda igual para todos.
 */
public record NotificationCreatedEvent(
        Long notificationId,
        String eventType,
        String message,
        Long ownerId,
        Long referenceId,
        Integer targetUserId,
        Integer actorUserId) {

    public NotificationCreatedEvent(Long notificationId, String eventType, String message,
            Long ownerId, Long referenceId, Integer targetUserId) {
        this(notificationId, eventType, message, ownerId, referenceId, targetUserId, null);
    }
}
