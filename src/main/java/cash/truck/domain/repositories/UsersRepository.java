package cash.truck.domain.repositories;

import cash.truck.domain.entities.Users;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UsersRepository extends JpaRepository<Users, Integer> {
    Optional<Users> findByEmailAndPassword(String email, String password);
    Optional<Users> findByNameAndEmail(String name, String email);
    Optional<Users> findByEmail(String email);
    Page<Users> findAll(Specification<Users> specification, Pageable pageable);
}
