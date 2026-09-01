package cash.truck.domain.enums;

import com.fasterxml.jackson.annotation.JsonCreator;

/**
 * Entidad a la que pertenece un documento archivado. Es el mismo vocabulario
 * de la columna applies_to del catalogo, de modo que un tipo declarado para
 * vehiculo no pueda colgarse de un conductor.
 */
public enum DocumentHolderEnum {
    VEHICLE,
    DRIVER,
    OWNER;

    @JsonCreator
    public static DocumentHolderEnum fromValue(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        for (DocumentHolderEnum holder : values()) {
            if (holder.name().equalsIgnoreCase(value.trim())) {
                return holder;
            }
        }
        throw new IllegalArgumentException(
                "El portador '" + value + "' no es valido. Valores permitidos: VEHICLE, DRIVER, OWNER.");
    }
}
