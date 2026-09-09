package cash.truck.domain.dtos;

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

    /** Nequi, Bancolombia u Otro. */
    private String paymentMethod;

    /** Numero de transaccion transcrito del comprobante; opcional. */
    private String reference;

    /** URL que devolvio /common/upload-document al subir la imagen. */
    private String receiptUrl;
}
