package cash.truck.application.usecases;

import cash.truck.application.exception.SubscriptionValidationException;
import cash.truck.application.usecases.notifications.OwnerNotificationUseCase;
import cash.truck.application.utility.Constants;
import cash.truck.domain.dtos.SubscriptionPaymentRequest;
import cash.truck.domain.dtos.SubscriptionQuoteDTO;
import cash.truck.domain.entities.Owner;
import cash.truck.domain.entities.SubscriptionPayment;
import cash.truck.domain.entities.SubscriptionPlan;
import cash.truck.domain.repositories.OwnerRepository;
import cash.truck.domain.repositories.SubscriptionPaymentRepository;
import cash.truck.domain.repositories.SubscriptionPlanRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

/**
 * Renovacion de la suscripcion de un propietario.
 *
 * No hay pasarela de pagos: el propietario paga leyendo un QR de Nequi o
 * Bancolombia, sube el comprobante y un administrador lo verifica a mano. Por
 * eso el flujo son tres pasos separados —cotizar, registrar, confirmar— y no
 * uno solo: entre que el propietario dice que pago y alguien lo comprueba pasa
 * tiempo, y ese estado intermedio tiene que existir en la base.
 *
 * La fecha de suscripcion solo se toca al confirmar. Registrar el comprobante
 * no da acceso a nada, que es justo lo que protege al negocio mientras la
 * comprobacion sea manual.
 */
@Service
public class SubscriptionUseCase {

    private static final Logger logger = LoggerFactory.getLogger(SubscriptionUseCase.class);

    private final OwnerRepository ownerRepository;
    private final SubscriptionPlanRepository subscriptionPlanRepository;
    private final SubscriptionPaymentRepository subscriptionPaymentRepository;
    private final OwnerNotificationUseCase ownerNotificationUseCase;
    private final InAppNotificationUseCase inAppNotificationUseCase;

    public SubscriptionUseCase(OwnerRepository ownerRepository,
                               SubscriptionPlanRepository subscriptionPlanRepository,
                               SubscriptionPaymentRepository subscriptionPaymentRepository,
                               OwnerNotificationUseCase ownerNotificationUseCase,
                               InAppNotificationUseCase inAppNotificationUseCase) {
        this.ownerRepository = ownerRepository;
        this.subscriptionPlanRepository = subscriptionPlanRepository;
        this.subscriptionPaymentRepository = subscriptionPaymentRepository;
        this.ownerNotificationUseCase = ownerNotificationUseCase;
        this.inAppNotificationUseCase = inAppNotificationUseCase;
    }

    // -----------------------------------------------------------------------
    // Cotizacion
    // -----------------------------------------------------------------------

    /**
     * Cuanto debe pagar el propietario, desglosado en las lineas que el front
     * pinta tal cual.
     *
     * Se cobra por el cupo contratado (owner.maxVehicles) y no por los
     * vehiculos que tenga registrados hoy: el cupo es lo que el propietario
     * contrato y no cambia entre que ve el total y paga, mientras que el conteo
     * real si podria moverse en ese rato y cobrarle algo distinto a lo que vio.
     */
    public SubscriptionQuoteDTO quote(Long ownerId, Integer years) {
        Owner owner = requireOwner(ownerId);
        SubscriptionPlan plan = currentPlan();
        return buildQuote(owner, plan, requireYears(years));
    }

    /**
     * Cada anualidad multiplica el total completo, no solo la linea base: dos
     * anos con un vehiculo adicional son dos anualidades y dos adicionales. No
     * hay descuento por comprar varias; si algun dia lo hay, esta es la unica
     * formula que habria que tocar.
     */
    private SubscriptionQuoteDTO buildQuote(Owner owner, SubscriptionPlan plan, int years) {
        int vehicleCount = owner.getMaxVehicles() == null ? 0 : owner.getMaxVehicles();
        int included = plan.getIncludedVehicles() == null ? 0 : plan.getIncludedVehicles();
        // Nunca negativo: un cupo menor al incluido no genera un descuento.
        int additional = Math.max(0, vehicleCount - included);

        BigDecimal annualTotal = plan.getAnnualPrice().multiply(BigDecimal.valueOf(years));
        // La cantidad de la linea es vehiculos por anos: un adicional durante
        // dos anos se cobra dos veces, igual que la anualidad.
        int additionalUnits = additional * years;
        BigDecimal additionalTotal = plan.getAdditionalVehiclePrice()
                .multiply(BigDecimal.valueOf(additionalUnits));
        BigDecimal total = annualTotal.add(additionalTotal);

        List<SubscriptionQuoteDTO.Item> items = new ArrayList<>();
        items.add(new SubscriptionQuoteDTO.Item("Suscripción anual", years,
                plan.getAnnualPrice(), annualTotal));
        // La linea de adicionales se omite cuando no hay: una fila en cero
        // confunde mas de lo que informa.
        if (additionalUnits > 0) {
            items.add(new SubscriptionQuoteDTO.Item("Vehículo adicional", additionalUnits,
                    plan.getAdditionalVehiclePrice(), additionalTotal));
        }

        return new SubscriptionQuoteDTO(owner.getId(), plan.getId(), plan.getName(), vehicleCount,
                included, additional, years, plan.getMonths() * years, owner.getSubscriptionEndDate(),
                nextEndDate(owner.getSubscriptionEndDate(), plan, years), items, total);
    }

    /**
     * No hay suscripcion menor a un ano, asi que el periodo se cuenta en anos y
     * nunca en meses sueltos. Nulo se toma como uno para que el front pueda
     * omitirlo en el caso corriente.
     */
    private int requireYears(Integer years) {
        int value = years == null ? Constants.SUBSCRIPTION_MIN_YEARS : years;
        if (value < Constants.SUBSCRIPTION_MIN_YEARS || value > Constants.SUBSCRIPTION_MAX_YEARS) {
            throw new SubscriptionValidationException(Constants.SUBSCRIPTION_YEARS_INVALID);
        }
        return value;
    }

    /**
     * Hasta cuando queda la suscripcion tras renovar.
     *
     * Si todavia esta vigente se encadena al vencimiento anterior, para que
     * renovar temprano no le haga perder los dias que le quedaban. Si ya
     * vencio se cuenta desde hoy: el servicio estuvo cortado y cobrarle meses
     * en los que no pudo entrar seria venderle tiempo que ya paso.
     */
    private LocalDate nextEndDate(LocalDate currentEndDate, SubscriptionPlan plan, int years) {
        LocalDate today = LocalDate.now(ZoneId.of(Constants.ZONE_BOGOTA));
        LocalDate base = (currentEndDate == null || currentEndDate.isBefore(today))
                ? today
                : currentEndDate;
        return base.plusMonths((long) plan.getMonths() * years);
    }

    // -----------------------------------------------------------------------
    // Registro del comprobante
    // -----------------------------------------------------------------------

    /**
     * El propietario declara que ya pago y adjunta la evidencia. La fila nace
     * Pendiente y no cambia nada de su suscripcion.
     *
     * Los importes se recalculan aqui con la tarifa vigente en vez de tomarse
     * del cuerpo de la peticion: aceptar el monto que manda el cliente dejaria
     * renovar por cualquier cifra.
     */
    @Transactional
    public SubscriptionPayment registerPayment(SubscriptionPaymentRequest request) {
        if (request == null) {
            throw new SubscriptionValidationException(Constants.SUBSCRIPTION_OWNER_REQUIRED);
        }
        Owner owner = requireOwner(request.getOwnerId());

        String method = request.getPaymentMethod();
        if (method == null || !Constants.PAYMENT_METHODS.contains(method)) {
            throw new SubscriptionValidationException(Constants.SUBSCRIPTION_METHOD_INVALID);
        }
        // Sin comprobante no hay nada que comprobar, y la revision es manual.
        if (request.getReceiptUrl() == null || request.getReceiptUrl().isBlank()) {
            throw new SubscriptionValidationException(Constants.SUBSCRIPTION_RECEIPT_REQUIRED);
        }
        if (subscriptionPaymentRepository.existsByOwnerIdAndStatus(owner.getId(),
                Constants.PAYMENT_STATUS_PENDING)) {
            throw new SubscriptionValidationException(Constants.SUBSCRIPTION_PAYMENT_DUPLICATED);
        }

        SubscriptionPlan plan = currentPlan();
        int years = requireYears(request.getYears());
        SubscriptionQuoteDTO quote = buildQuote(owner, plan, years);

        SubscriptionPayment payment = new SubscriptionPayment();
        payment.setYears(years);
        payment.setOwnerId(owner.getId());
        payment.setPlanId(plan.getId());
        payment.setVehicleCount(quote.vehicleCount());
        payment.setAdditionalVehicles(quote.additionalVehicles());
        payment.setAnnualPrice(plan.getAnnualPrice());
        payment.setAdditionalVehiclePrice(plan.getAdditionalVehiclePrice());
        payment.setTotalAmount(quote.total());
        payment.setPaymentMethod(method);
        payment.setReference(request.getReference());
        payment.setReceiptUrl(request.getReceiptUrl());
        payment.setStatus(Constants.PAYMENT_STATUS_PENDING);
        payment.setPreviousEndDate(owner.getSubscriptionEndDate());

        SubscriptionPayment saved = subscriptionPaymentRepository.save(payment);

        // Sin este aviso nadie se entera de que hay algo que comprobar, y el
        // pago se quedaria esperando hasta que un administrador entrara a
        // mirar por su cuenta.
        inAppNotificationUseCase.createNotification(Constants.SUBSCRIPTION_EVENT_TYPE,
                "El propietario " + owner.getName() + " registró un pago de suscripción por "
                        + quote.total().toPlainString() + " pendiente de comprobación.",
                Constants.ROLE_ID_ADMIN, null, null, saved.getId());

        logger.info("Pago {} registrado para el propietario {}", saved.getId(), owner.getId());
        return saved;
    }

    // -----------------------------------------------------------------------
    // Revision
    // -----------------------------------------------------------------------

    /**
     * El administrador confirma que el dinero llego: se corre la fecha de
     * suscripcion y se avisa al propietario por WhatsApp.
     *
     * La fecha se recalcula en este momento y no se toma de la que se
     * previsualizo al cotizar: entre registrar el pago y comprobarlo pueden
     * pasar dias, y encadenar sobre una fecha ya vencida regalaria o quitaria
     * tiempo segun cuanto se hubiera demorado la revision.
     */
    @Transactional
    public SubscriptionPayment confirmPayment(Long paymentId, Integer reviewerUserId) {
        if (reviewerUserId == null) {
            throw new SubscriptionValidationException(Constants.SUBSCRIPTION_REVIEWER_REQUIRED);
        }
        SubscriptionPayment payment = requirePendingPayment(paymentId);
        Owner owner = requireOwner(payment.getOwnerId());
        SubscriptionPlan plan = subscriptionPlanRepository.findById(payment.getPlanId())
                .orElseThrow(() -> new SubscriptionValidationException(Constants.SUBSCRIPTION_PLAN_NOT_FOUND));

        LocalDate previousEndDate = owner.getSubscriptionEndDate();
        // Los anos salen del pago y no de la peticion de confirmacion: lo que
        // se renueva es lo que el propietario pago, no lo que decida el
        // administrador al revisarlo.
        int years = payment.getYears() == null ? Constants.SUBSCRIPTION_MIN_YEARS : payment.getYears();
        LocalDate newEndDate = nextEndDate(previousEndDate, plan, years);

        owner.setSubscriptionEndDate(newEndDate);
        ownerRepository.save(owner);

        payment.setStatus(Constants.PAYMENT_STATUS_CONFIRMED);
        payment.setPreviousEndDate(previousEndDate);
        payment.setNewEndDate(newEndDate);
        payment.setReviewedByUserId(reviewerUserId);
        payment.setReviewedAt(new Date());
        SubscriptionPayment saved = subscriptionPaymentRepository.save(payment);

        // El envio es asincrono y en transaccion propia: que WhatsApp falle no
        // puede deshacer una renovacion que el propietario ya pago.
        ownerNotificationUseCase.sendSubscriptionRenewed(owner, newEndDate);

        logger.info("Pago {} confirmado: propietario {} activo hasta {}", saved.getId(), owner.getId(),
                newEndDate);
        return saved;
    }

    /**
     * El administrador no encontro el dinero. Queda constancia con el motivo,
     * que es lo que le permite al propietario corregir y volver a intentarlo.
     */
    @Transactional
    public SubscriptionPayment rejectPayment(Long paymentId, Integer reviewerUserId, String reason) {
        if (reviewerUserId == null) {
            throw new SubscriptionValidationException(Constants.SUBSCRIPTION_REVIEWER_REQUIRED);
        }
        if (reason == null || reason.isBlank()) {
            throw new SubscriptionValidationException(Constants.SUBSCRIPTION_REJECTION_REASON_REQUIRED);
        }
        SubscriptionPayment payment = requirePendingPayment(paymentId);

        payment.setStatus(Constants.PAYMENT_STATUS_REJECTED);
        payment.setRejectionReason(reason);
        payment.setReviewedByUserId(reviewerUserId);
        payment.setReviewedAt(new Date());
        SubscriptionPayment saved = subscriptionPaymentRepository.save(payment);

        // Sin este aviso el propietario solo se entera entrando al historico, y
        // mientras tanto cree que ya renovo. El motivo viaja en el mensaje
        // porque es lo unico que le permite corregir y reintentar.
        Owner owner = requireOwner(payment.getOwnerId());
        ownerNotificationUseCase.sendSubscriptionRejected(owner, reason);

        logger.info("Pago {} rechazado: {}", paymentId, reason);
        return saved;
    }

    // -----------------------------------------------------------------------
    // Consulta
    // -----------------------------------------------------------------------

    /** Historico del propietario, para que vea en que quedo cada intento. */
    public List<SubscriptionPayment> findByOwner(Long ownerId) {
        return subscriptionPaymentRepository.findByOwnerIdOrderByCreationDateDesc(ownerId);
    }

    /** Bandeja del administrador: lo mas viejo primero, que es lo que urge. */
    public List<SubscriptionPayment> findPending() {
        return subscriptionPaymentRepository.findByStatusOrderByCreationDateAsc(
                Constants.PAYMENT_STATUS_PENDING);
    }

    // -----------------------------------------------------------------------

    private Owner requireOwner(Long ownerId) {
        if (ownerId == null) {
            throw new SubscriptionValidationException(Constants.SUBSCRIPTION_OWNER_REQUIRED);
        }
        return ownerRepository.findById(ownerId)
                .orElseThrow(() -> new SubscriptionValidationException(Constants.SUBSCRIPTION_OWNER_NOT_FOUND));
    }

    /**
     * La tarifa de hoy. Si hubiera mas de una abierta gana la mas reciente, en
     * vez de fallar: quedarse sin poder cobrar es peor que cobrar con la ultima
     * tarifa cargada.
     */
    private SubscriptionPlan currentPlan() {
        List<SubscriptionPlan> plans = subscriptionPlanRepository.findApplicable(
                LocalDate.now(ZoneId.of(Constants.ZONE_BOGOTA)));
        if (plans.isEmpty()) {
            throw new SubscriptionValidationException(Constants.SUBSCRIPTION_PLAN_NOT_FOUND);
        }
        if (plans.size() > 1) {
            logger.warn("Hay {} tarifas vigentes a la vez; se aplica la mas reciente", plans.size());
        }
        return plans.get(0);
    }

    /**
     * Un pago ya revisado no se vuelve a decidir: confirmarlo dos veces
     * correria la fecha de suscripcion dos anos por un solo pago.
     */
    private SubscriptionPayment requirePendingPayment(Long paymentId) {
        SubscriptionPayment payment = subscriptionPaymentRepository.findById(paymentId)
                .orElseThrow(() -> new SubscriptionValidationException(Constants.SUBSCRIPTION_PAYMENT_NOT_FOUND));
        if (!Constants.PAYMENT_STATUS_PENDING.equals(payment.getStatus())) {
            throw new SubscriptionValidationException(Constants.SUBSCRIPTION_PAYMENT_NOT_PENDING);
        }
        return payment;
    }
}
