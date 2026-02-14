package cash.truck.application.usecases;

import cash.truck.application.utility.filters.FilterRequest;
import cash.truck.application.utility.filters.GenericSpecification;
import cash.truck.application.utility.filters.SearchCriteria;
import cash.truck.application.utility.filters.UtilsFilter;
import cash.truck.domain.entities.AccessControl;
import cash.truck.domain.repositories.AccessControlRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class AccessControlUseCase {

    @Autowired
    private final AccessControlRepository accessControlRepository;
    public AccessControlUseCase(AccessControlRepository accessControlRepository){
        this.accessControlRepository = accessControlRepository;
    }

    public List<AccessControl> getAllAccessControls() {
        return accessControlRepository.findAll();
    }

    public AccessControl saveAccessControl(AccessControl accessControl) {
        return accessControlRepository.save(accessControl);
    }

    public Page<AccessControl> findWithFilterOptional(FilterRequest filterRequest) {

        // Crear objeto de pagina para filtros
        Pageable pageable = UtilsFilter.getPageable(filterRequest);

        // Convert FilterItem a SearchCriteria si hay filtros
        List<SearchCriteria> searchCriteriaList = UtilsFilter.getSearchCriteria(filterRequest);

        // Construir especificación utilizando los criterios si hay filtros
        Specification<AccessControl> specification = null;
        if (!searchCriteriaList.isEmpty()) {
            specification = new GenericSpecification<>(searchCriteriaList);
        }

        // Get page results
        Page<AccessControl> accessControlPage;
        if (specification != null) {
            accessControlPage = accessControlRepository.findAll(specification, pageable);
        } else {
            accessControlPage = accessControlRepository.findAll(pageable);
        }

        return new PageImpl<>(accessControlPage.getContent(), pageable, accessControlPage.getTotalElements());
    }

    public List<AccessControl> getAccessControlByPartner(Long partnerId) {
        return accessControlRepository.findByPartnerId(partnerId);
    }
}
