package cash.truck.application.utility.filters;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;
@Data
@AllArgsConstructor
@NoArgsConstructor
public class FilterRequest {
    private List<FilterItem> filter;
    private Pagination pagination;
    private Sort sort;
}
