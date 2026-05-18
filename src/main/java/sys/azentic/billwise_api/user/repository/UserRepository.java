package sys.azentic.billwise_api.user.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sys.azentic.billwise_api.user.model.User;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
}
