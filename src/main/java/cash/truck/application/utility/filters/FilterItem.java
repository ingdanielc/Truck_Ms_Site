package cash.truck.application.utility.filters;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class FilterItem {
    private String fieldFilter;
    private String compFilter;
    private String valueFilter;
}
