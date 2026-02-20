package cash.truck.application.utility.filters;

import jakarta.persistence.criteria.*;
import org.springframework.data.jpa.domain.Specification;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class GenericSpecification<T> implements Specification<T>, Serializable {
    private static final long serialVersionUID = 1L;
    private final transient List<SearchCriteria> criteria;

    public GenericSpecification(List<SearchCriteria> criteria) {
        this.criteria = criteria;
    }

    @Override
    public Predicate toPredicate(Root<T> root, CriteriaQuery<?> query, CriteriaBuilder builder) {
        List<Predicate> predicates = new ArrayList<>();
        for (SearchCriteria criterion : this.criteria) {
            Path<Object> path = getPath(root, criterion.getKey());
            switch (criterion.getOperation()) {
                case "=":
                    predicates.add(builder.equal(path, criterion.getValue()));
                    break;
                case "!=":
                    predicates.add(builder.notEqual(path, criterion.getValue()));
                    break;
                case "like":
                    predicates.add(builder.like(builder.lower(path.as(String.class)),
                            "%" + criterion.getValue().toString().toLowerCase() + "%"));
                    break;
                case "startswith":
                    predicates.add(builder.like(builder.lower(path.as(String.class)),
                            criterion.getValue().toString().toLowerCase() + "%"));
                    break;
                case "endswith":
                    predicates.add(builder.like(builder.lower(path.as(String.class)),
                            "%" + criterion.getValue().toString().toLowerCase()));
                    break;
                case "equalsIgnoreCase":
                    predicates.add(builder.equal(builder.lower(path.as(String.class)),
                            criterion.getValue().toString().toLowerCase()));
                    break;
                case "in":
                    CriteriaBuilder.In<Object> in = builder.in(path);
                    String[] values = criterion.getValue().toString().split(",");
                    for (String value : values) {
                        in.value(value.trim());
                    }
                    predicates.add(in);
                    break;
                case "notin":
                    CriteriaBuilder.In<Object> notIn = builder.in(path);
                    String[] notInValues = criterion.getValue().toString().split(",");
                    for (String value : notInValues) {
                        notIn.value(value.trim());
                    }
                    predicates.add(builder.not(notIn));
                    break;
                case "isnull":
                    predicates.add(builder.isNull(path));
                    break;
                case "isnotnull":
                    predicates.add(builder.isNotNull(path));
                    break;
                case ">":
                    predicates.add(builder.greaterThan(root.get(criterion.getKey()).as(String.class),
                            criterion.getValue().toString()));
                    break;
                case "<":
                    predicates.add(builder.lessThan(root.get(criterion.getKey()).as(String.class),
                            criterion.getValue().toString()));
                    break;
                case ">=":
                    predicates.add(builder.greaterThanOrEqualTo(root.get(criterion.getKey()).as(String.class),
                            criterion.getValue().toString()));
                    break;
                case "<=":
                    predicates.add(builder.lessThanOrEqualTo(root.get(criterion.getKey()).as(String.class),
                            criterion.getValue().toString()));
                    break;
                case "==":
                    predicates.add(builder.equal(root.get(criterion.getKey()).as(String.class),
                            criterion.getValue().toString()));
                    break;
                default:
                    throw new IllegalArgumentException("Operación no soportada: " + criterion.getOperation());
            }
        }
        return builder.and(predicates.toArray(new Predicate[0]));
    }

    private Path<Object> getPath(Root<T> root, String fieldName) {
        String[] fieldNames = fieldName.split("\\.");
        Path<Object> path = root.get(fieldNames[0]);
        for (int i = 1; i < fieldNames.length; i++) {
            path = path.get(fieldNames[i]);
        }
        return path;
    }
}