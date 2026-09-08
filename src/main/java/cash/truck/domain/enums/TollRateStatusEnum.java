package cash.truck.domain.enums;

/**
 * Calidad de la tarifa con que se cotizo cada estacion.
 *
 * Existe porque el catalogo se alimenta de resoluciones con fecha de corte y no
 * siempre esta al dia. Una tarifa vencida sigue siendo la mejor informacion
 * disponible, pero el cliente debe poder distinguirla de una vigente antes de
 * mostrarla como un valor en firme.
 */
public enum TollRateStatusEnum {

    /** La fecha de viaje cae dentro de la vigencia de la tarifa. */
    VIGENTE,

    /** La tarifa mas reciente conocida ya vencio a la fecha de viaje. */
    VENCIDA,

    /** La estacion esta en la ruta pero no tiene tarifa cargada para la categoria. */
    SIN_TARIFA
}
