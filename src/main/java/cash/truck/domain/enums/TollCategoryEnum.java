package cash.truck.domain.enums;

/**
 * Categoria tarifaria de peaje.
 *
 * El numero romano por si solo no dice nada: su significado depende de la
 * escala que use la estacion. Un camion de cinco ejes es VI bajo
 * {@link TollRateSchemeEnum#OETR_7} y IV bajo
 * {@link TollRateSchemeEnum#INVIAS_5}. Por eso aqui no hay una traduccion de
 * ejes a categoria, sino una por escala.
 *
 * Las categorias I y II no se asignan nunca desde el codigo bajo la escala de
 * siete —son livianos y buses— pero si bajo la de cinco, donde la II incluye a
 * los camiones de dos ejes.
 */
public enum TollCategoryEnum {

    I,
    II,
    III,
    IV,
    V,
    VI,
    VII;

    /**
     * Categoria que le corresponde a un camion por su numero de ejes, dentro de
     * la escala que use la estacion.
     *
     * Menos de dos ejes se trata como dos: un vehiculo de la flota siempre es de
     * carga, y bajar mas seria darle la tarifa de un automovil por un dato mal
     * capturado.
     *
     * Un camion de dos ejes bajo la escala de siete queda en IV y no en III. La
     * escala parte esa fila en dos por el tamano de la llanta trasera —doble
     * pequena en III, doble grande en IV— y el numero de ejes no distingue una
     * de otra. Se toma la mas alta a proposito: es el unico supuesto del calculo
     * que puede cobrar de mas, y se avisa en la respuesta para que nadie lo lea
     * como un valor en firme. Corregirlo pide un atributo nuevo del vehiculo,
     * no mas logica.
     */
    public static TollCategoryEnum forAxles(int axles, TollRateSchemeEnum scheme) {
        int effectiveAxles = Math.max(2, axles);

        if (scheme == TollRateSchemeEnum.INVIAS_5) {
            if (effectiveAxles == 2) {
                return II;
            }
            if (effectiveAxles <= 4) {
                return III;
            }
            if (effectiveAxles == 5) {
                return IV;
            }
            return V;
        }

        // OETR_7
        if (effectiveAxles == 2) {
            return IV;
        }
        if (effectiveAxles <= 4) {
            return V;
        }
        if (effectiveAxles == 5) {
            return VI;
        }
        return VII;
    }

    /** true cuando la categoria salio del supuesto de llanta grande para un camion de dos ejes. */
    public static boolean isAxleSizeAssumption(int axles, TollRateSchemeEnum scheme) {
        return scheme == TollRateSchemeEnum.OETR_7 && Math.max(2, axles) == 2;
    }

    /** Traduce el texto guardado en toll_rate.category, o null si no es una categoria conocida. */
    public static TollCategoryEnum fromCode(String code) {
        if (code == null) {
            return null;
        }
        for (TollCategoryEnum category : values()) {
            if (category.name().equalsIgnoreCase(code.trim())) {
                return category;
            }
        }
        return null;
    }
}
