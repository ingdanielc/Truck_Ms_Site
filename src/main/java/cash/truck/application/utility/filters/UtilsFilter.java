package cash.truck.application.utility.filters;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

import java.util.ArrayList;
import java.util.List;

public class UtilsFilter {

    UtilsFilter() {}
    public static List<SearchCriteria> getSearchCriteria(FilterRequest filterRequest) {
        List<SearchCriteria> searchCriteriaList = new ArrayList<>();
        if (filterRequest.getFilter() != null && !filterRequest.getFilter().isEmpty()) {
            for (FilterItem filterItem : filterRequest.getFilter()) {
                searchCriteriaList.add(new SearchCriteria(filterItem.getFieldFilter(), filterItem.getCompFilter(), filterItem.getValueFilter()));
            }
        }
        return searchCriteriaList;

    }

    public static Pageable getPageable(FilterRequest filterRequest) {
        return PageRequest.of(
                filterRequest.getPagination().getCurrentPage(),
                filterRequest.getPagination().getPageSize(),
                Boolean.parseBoolean(filterRequest.getSort().getSortAsc()) ? Sort.Direction.ASC : Sort.Direction.DESC,
                filterRequest.getSort().getOrderBy()
        );

    }

}
