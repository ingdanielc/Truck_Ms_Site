package cash.truck.domain.repositories;

import cash.truck.domain.entities.Expires;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ExpiresRepository extends JpaRepository<Expires, Long> {

}
