package cash.truck.domain.enums;

import lombok.Getter;

@Getter
public enum PasswordResetStatusEnum {
    PENDING(1, "Pending"),       // Codigo enviado, esperando validacion.
    VERIFIED(2, "Verified"),     // Codigo validado, se emitio el token de cambio.
    USED(3, "Used"),             // La contrasena ya se cambio con esta solicitud.
    CANCELLED(4, "Cancelled");   // Invalidada por una solicitud posterior o por exceso de intentos.

    private final int code;
    private final String name;

    PasswordResetStatusEnum(int code, String name) {
        this.code = code;
        this.name = name;
    }

    public static PasswordResetStatusEnum fromName(String name) {
        for (PasswordResetStatusEnum status : PasswordResetStatusEnum.values()) {
            if (status.getName().equalsIgnoreCase(name)) {
                return status;
            }
        }
        throw new IllegalArgumentException("Invalid name: " + name);
    }
}
