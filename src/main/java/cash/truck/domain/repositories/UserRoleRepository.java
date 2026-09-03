package cash.truck.domain.repositories;

import cash.truck.domain.entities.UserRole;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface UserRoleRepository extends JpaRepository<UserRole, Integer> {

    /**
     * Los usuarios de un rol, solo el id. Se proyecta y no se cargan las
     * entidades porque Users trae su lista de roles y UserRole trae user y role
     * en EAGER: pedir la fila completa para leer un entero saldria en varias
     * consultas por cada administrador.
     */
    @Query("SELECT ur.user.id FROM UserRole ur WHERE ur.role.id = :roleId")
    List<Integer> findUserIdsByRoleId(@Param("roleId") Integer roleId);
}
