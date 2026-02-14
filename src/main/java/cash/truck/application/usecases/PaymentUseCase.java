package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.*;
import cash.truck.domain.repositories.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PaymentUseCase {

    @Autowired
    private final PaymentRepository paymentRepository;
    private final PaymentMethodRepository paymentMethodRepository;

    public PaymentUseCase(PaymentRepository paymentRepository,
                          PaymentMethodRepository paymentMethodRepository){
        this.paymentRepository = paymentRepository;
        this.paymentMethodRepository = paymentMethodRepository;
    }

    public List<Payment> getAllPayments() {
        return paymentRepository.findAll();
    }

    public Payment savePayment(Payment payment) {
        return paymentRepository.save(payment);
    }

    public Page<Payment> findWithFilterOptional(FilterRequest filterRequest) {

        // Crear objeto de pagina para filtros
        Pageable pageable = UtilsFilter.getPageable(filterRequest);

        // Convert FilterItem a SearchCriteria si hay filtros
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        // Construir especificación utilizando los criterios si hay filtros
        Specification<Payment> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        // Get page results
        Page<Payment> paymentPage;
        if (specification != null) {
            paymentPage = paymentRepository.findAll(specification, pageable);
        } else {
            paymentPage = paymentRepository.findAll(pageable);
        }

        for (Payment payment : paymentPage.getContent()) {
            payment.setBalance(payment.getPartnerMembership().getPrice().subtract(payment.getAmount()));
        }

        return new PageImpl<>(paymentPage.getContent(), pageable, paymentPage.getTotalElements());
    }

    public List<PaymentMethod> getAllPaymentMethods() {
        return paymentMethodRepository.findAll();
    }
}
