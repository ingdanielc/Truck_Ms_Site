package cash.truck.domain.enums;

/**
 * Escala de categorias tarifarias que aplica una estacion de peaje.
 *
 * En Colombia conviven dos, y el mismo numero romano significa cosas distintas
 * en cada una: un camion de cinco ejes es VI en la escala de la OETR y IV en la
 * de INVIAS. Sin saber cual usa la estacion, la categoria no se puede deducir
 * del vehiculo.
 *
 * Cual aplica cada estacion se deriva de sus propias tarifas al cargar el
 * catalogo: solo la escala de siete llega a VII. Ver
 * scripts/tolls_update_rate_scheme.sql.
 */
public enum TollRateSchemeEnum {

    /**
     * Escala de siete categorias de la Operacion Estadistica de Trafico y
     * Recaudo (ANI-OETR):
     *
     * I livianos · II buses pequenos · III camion de 2 ejes con doble llanta
     * pequena · IV camion de 2 ejes con doble llanta grande · V camion de 3 y 4
     * ejes · VI camion de 5 ejes · VII camion de 6 ejes o mas.
     */
    OETR_7,

    /**
     * Escala general de cinco categorias de INVIAS:
     *
     * I livianos · II buses y camiones de 2 ejes · III carga de 3 y 4 ejes ·
     * IV carga de 5 ejes · V carga de 6 ejes.
     */
    INVIAS_5
}
