package cash.truck.domain.dtos;

import com.fasterxml.jackson.annotation.JsonAlias;
import lombok.Data;

/**
 * Comprobante que registra el propietario tras pagar por Nequi o Bancolombia.
 *
 * No trae importes: el total se recalcula en el servidor con la tarifa vigente
 * y el cupo real del propietario. Aceptar el monto que mande el cliente
 * permitiria renovar por cualquier cifra.
 */
@Data
public class SubscriptionPaymentRequest {

    private Long ownerId;

    /** Anualidades que se estan pagando. Nulo se toma como una. */
    private Integer years;

    /**
     * Nequi, Bancolombia u Otro.
     *
     * El front lo manda como "method", de ahi el alias: renombrarlo alla
     * obligaria a tocar el formulario, y el nombre corto no estorba aqui.
     */
    @JsonAlias("method")
    private String paymentMethod;

    /** Numero de transaccion transcrito del comprobante; opcional. */
    private String reference;

    /** URL que devolvio /common/upload-document al subir la imagen. */
    private String receiptUrl;
}
