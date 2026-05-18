package sys.azentic.billwise_api.auth.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sys.azentic.billwise_api.auth.model.RefreshToken;

import java.util.Optional;
import java.util.UUID;

public interface RefreshTokenRepository extends JpaRepository<RefreshToken, UUID> {
    Optional<RefreshToken> findByToken(String token);
}
