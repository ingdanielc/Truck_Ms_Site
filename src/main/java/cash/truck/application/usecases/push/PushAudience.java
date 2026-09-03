package cash.truck.application.usecases.push;

/**
 * A quien va dirigido el push de un evento.
 *
 * No coincide siempre con el destinatario de la notificacion interna, y por eso
 * existe: la creacion de un propietario se guarda sin owner_id porque es un
 * aviso para el administrador, mientras que un viaje o un vencimiento son del
 * propietario del vehiculo.
 */
public enum PushAudience {

    /** El propietario al que pertenece el objeto del evento. */
    OWNER,

    /** Todos los usuarios con rol ADMINISTRADOR. */
    ADMIN,

    /** El evento no sale por push. */
    NONE
}
