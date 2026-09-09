package cash.truck.domain.dtos;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

/**
 * Lo que el propietario debe pagar para renovar, ya desglosado.
 *
 * Trae las lineas armadas y no los precios sueltos para que el front pinte la
 * tabla sin recalcular nada: si el front multiplicara por su cuenta, el dia que
 * cambie la regla de cobro habria dos formulas que mantener y una podria
 * mostrar un total distinto al que se cobra.
 *
 * newEndDate es una previsualizacion, no una promesa: la fecha definitiva se
 * calcula al confirmar el pago, que puede ser dias despues.
 */
public record SubscriptionQuoteDTO(
        Long ownerId,
        Integer planId,
        String planName,
        Integer vehicleCount,
        Integer includedVehicles,
        Integer additionalVehicles,
        /** Anualidades cotizadas. Multiplica cada linea y el total. */
        Integer years,
        /** Meses que se sumaran al vencimiento: los del plan por los anos. */
        Integer months,
        LocalDate currentEndDate,
        LocalDate newEndDate,
        List<Item> items,
        BigDecimal total) {

    /**
     * Una fila de la tabla. quantity va aparte del concepto para que el front
     * pueda mostrar "Vehiculo adicional x2" sin partir cadenas.
     */
    public record Item(
            String concept,
            Integer quantity,
            BigDecimal unitPrice,
            BigDecimal value) {
    }
}
