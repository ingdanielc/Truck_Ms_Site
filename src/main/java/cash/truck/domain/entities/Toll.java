package cash.truck.domain.entities;

import cash.truck.domain.enums.TollRateSchemeEnum;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;

/**
 * Estacion de peaje del catalogo nacional (ANI / INVIAS).
 *
 * La tarifa no vive aqui sino en {@link TollRate}, porque una misma estacion
 * cobra distinto por categoria de vehiculo y esas tarifas cambian con cada
 * resolucion. Separarlas permite guardar el historico sin tocar la estacion.
 *
 * latitude y longitude son opcionales a proposito: el catalogo de origen trae
 * muchas estaciones sin georreferenciar. Una estacion sin coordenadas no puede
 * emparejarse contra la ruta y por eso queda fuera de la cotizacion; no es un
 * error de datos que deba romper la consulta.
 */
@Getter
@Setter
@Entity
@Table(name = "toll")
public class Toll {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "toll_key", nullable = false, length = 150, unique = true)
    private String tollKey;

    @Column(name = "name", nullable = false, length = 150)
    private String name;

    @Column(name = "department", length = 100)
    private String department;

    @Column(name = "municipality", length = 100)
    private String municipality;

    @Column(name = "divipola", length = 20)
    private String divipola;

    @Column(name = "project")
    private String project;

    @Column(name = "current_administrator", length = 100)
    private String currentAdministrator;

    @Column(name = "latitude", precision = 10, scale = 7)
    private BigDecimal latitude;

    @Column(name = "longitude", precision = 10, scale = 7)
    private BigDecimal longitude;

    @Column(name = "active", nullable = false)
    private Boolean active = true;

    /**
     * Escala de categorias que aplica esta estacion.
     *
     * Es un atributo de la estacion y no del vehiculo porque el mismo numero
     * romano cobra cosas distintas segun donde: sin este dato, los ejes del
     * camion no alcanzan para saber que tarifa le corresponde.
     *
     * Se deriva de las propias tarifas al cargar el catalogo y no se captura a
     * mano. Un nulo se trata como INVIAS_5, que es lo que corresponde a una
     * estacion cuya escala no llega a VII.
     */
    @Enumerated(EnumType.STRING)
    @Column(name = "rate_scheme", length = 20)
    private TollRateSchemeEnum rateScheme;
}
