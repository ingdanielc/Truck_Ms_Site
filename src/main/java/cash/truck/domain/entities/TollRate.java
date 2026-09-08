package cash.truck.domain.entities;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

/**
 * Tarifa de una estacion de peaje para una categoria de vehiculo, vigente
 * desde startDate hasta endDate.
 *
 * endDate nulo significa vigencia abierta: es la tarifa actual mientras no
 * aparezca una resolucion que la reemplace. Es el caso normal de la tarifa
 * viva; las filas con endDate son cortes historicos ya cerrados.
 *
 * El importe va en INT porque las tarifas de peaje en Colombia se publican en
 * pesos enteros: no hay centavos que redondear.
 */
@Getter
@Setter
@Entity
@Table(name = "toll_rate")
public class TollRate {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "toll_id", nullable = false)
    private Long tollId;

    @Column(name = "category", nullable = false, length = 20)
    private String category;

    @Column(name = "rate", nullable = false)
    private Integer rate;

    @Column(name = "start_date", nullable = false)
    private LocalDate startDate;

    @Column(name = "end_date")
    private LocalDate endDate;

    @Column(name = "source")
    private String source;

    @Column(name = "source_entity", length = 100)
    private String sourceEntity;
}
