package cash.truck.domain.repositories;

import cash.truck.domain.entities.PasswordReset;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface PasswordResetRepository extends JpaRepository<PasswordReset, Integer> {

    /** La solicitud vigente de ese celular: siempre se valida contra la mas reciente. */
    Optional<PasswordReset> findFirstByPhoneAndStatusOrderByIdDesc(String phone, String status);

    Optional<PasswordReset> findFirstByResetTokenAndStatus(String resetToken, String status);

    /** Las anteriores se cancelan cuando el usuario pide un codigo nuevo. */
    List<PasswordReset> findByUserIdAndStatusIn(Integer userId, List<String> statuses);
}
