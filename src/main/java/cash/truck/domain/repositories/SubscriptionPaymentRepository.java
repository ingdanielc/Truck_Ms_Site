package cash.truck.domain.repositories;

import cash.truck.domain.entities.SubscriptionPayment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface SubscriptionPaymentRepository extends JpaRepository<SubscriptionPayment, Long> {

    Page<SubscriptionPayment> findAll(Specification<SubscriptionPayment> specification, Pageable pageable);

    /** Historico del propietario, lo ultimo primero. */
    List<SubscriptionPayment> findByOwnerIdOrderByCreationDateDesc(Long ownerId);

    /** La bandeja del administrador: lo que esta esperando comprobacion. */
    List<SubscriptionPayment> findByStatusOrderByCreationDateAsc(String status);

    /**
     * Evita que el propietario registre dos veces el mismo pago mientras el
     * primero sigue sin revisarse. No es una restriccion de la base porque un
     * pago rechazado si debe poder reintentarse.
     */
    boolean existsByOwnerIdAndStatus(Long ownerId, String status);
}
