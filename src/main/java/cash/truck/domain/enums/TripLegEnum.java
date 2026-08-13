package cash.truck.domain.enums;

import com.fasterxml.jackson.annotation.JsonCreator;

public enum TripLegEnum {
    IDA,
    REGRESO;

    @JsonCreator
    public static TripLegEnum fromValue(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        for (TripLegEnum leg : values()) {
            if (leg.name().equalsIgnoreCase(value.trim())) {
                return leg;
            }
        }
        throw new IllegalArgumentException(
                "El tramo '" + value + "' no es válido. Valores permitidos: IDA, REGRESO.");
    }
}
