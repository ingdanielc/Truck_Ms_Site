package cash.truck.domain.enums;

import com.fasterxml.jackson.annotation.JsonCreator;

public enum TripTypeEnum {
    CARGADO,
    REDONDO,
    VACIO;

    @JsonCreator
    public static TripTypeEnum fromValue(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        for (TripTypeEnum tripType : values()) {
            if (tripType.name().equalsIgnoreCase(value.trim())) {
                return tripType;
            }
        }
        throw new IllegalArgumentException(
                "El tipo de viaje '" + value + "' no es válido. Valores permitidos: CARGADO, REDONDO, VACIO.");
    }
}
