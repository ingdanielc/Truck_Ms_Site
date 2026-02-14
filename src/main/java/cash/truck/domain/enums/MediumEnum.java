package cash.truck.domain.enums;

import lombok.Getter;

@Getter
public enum MediumEnum {
    EMAIL(1,"Email"),
    SMS(2, "SMS"),
    WHATSAPP(3, "WhatsApp"),
    FLOW(4, "Flow");

    private final int code;
    private final String name;

    MediumEnum(int code, String name) {
        this.code = code;
        this.name = name;
    }

    public static MediumEnum fromCode(int code) {
        for (MediumEnum type : MediumEnum.values()) {
            if (type.getCode() == code) {
                return type;
            }
        }
        throw new IllegalArgumentException("Invalid code: " + code);
    }

    public static MediumEnum fromName(String name) {
        for (MediumEnum type : MediumEnum.values()) {
            if (type.getName().equalsIgnoreCase(name)) {
                return type;
            }
        }
        throw new IllegalArgumentException("Invalid name: " + name);
    }
    
}
