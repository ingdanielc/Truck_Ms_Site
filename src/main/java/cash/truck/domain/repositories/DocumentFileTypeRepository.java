package cash.truck.domain.repositories;

import cash.truck.domain.entities.DocumentFileType;
import cash.truck.domain.enums.DocumentHolderEnum;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DocumentFileTypeRepository extends JpaRepository<DocumentFileType, Integer> {

    List<DocumentFileType> findByIsActiveTrueOrderByNameAsc();

    List<DocumentFileType> findByAppliesToAndIsActiveTrueOrderByNameAsc(DocumentHolderEnum appliesTo);
}
