package cash.truck.domain.enums;

/**
 * Como se emparejaron los peajes contra la ruta.
 *
 * Viaja en la respuesta porque las dos modalidades no son igual de confiables y
 * el cliente tiene que poder decirlo: con POLYLINE la cotizacion sigue el
 * trazado real que devolvio el proveedor de rutas; con CORRIDOR es una
 * estimacion sobre la recta entre origen y destino.
 */
public enum RouteMatchModeEnum {

    /** Trazado real recibido del proveedor de rutas. Es el modo normal. */
    POLYLINE,

    /**
     * Modo degradado: el cliente no envio trazado utilizable. Se aproxima con
     * la recta origen-destino y una tolerancia ancha, de forma que la respuesta
     * es orientativa y puede incluir o perder estaciones.
     */
    CORRIDOR
}
