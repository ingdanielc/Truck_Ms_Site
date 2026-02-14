package cash.truck.application.utility.filters;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Sort {
    private String orderBy;
    private String sortAsc;
}
