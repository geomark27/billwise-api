package sys.azentic.billwise_api.auth.service;

import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sys.azentic.billwise_api.auth.dto.AuthResponse;
import sys.azentic.billwise_api.auth.dto.LoginRequest;
import sys.azentic.billwise_api.auth.dto.RegisterRequest;
import sys.azentic.billwise_api.auth.model.RefreshToken;
import sys.azentic.billwise_api.auth.repository.RefreshTokenRepository;
import sys.azentic.billwise_api.security.JwtService;
import sys.azentic.billwise_api.user.model.User;
import sys.azentic.billwise_api.user.repository.UserRepository;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new IllegalArgumentException("Email already registered");
        }
        var user = User.builder()
                .name(request.name())
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .build();
        userRepository.save(user);
        return issueTokens(user);
    }

    public AuthResponse login(LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.email(), request.password()));
        var user = userRepository.findByEmail(request.email()).orElseThrow();
        return issueTokens(user);
    }

    @Transactional
    public AuthResponse refresh(String tokenValue) {
        var stored = refreshTokenRepository.findByToken(tokenValue)
                .orElseThrow(() -> new IllegalArgumentException("Invalid refresh token"));
        if (stored.isRevoked() || stored.getExpiresAt().isBefore(Instant.now())) {
            throw new IllegalArgumentException("Refresh token expired or revoked");
        }
        stored.setRevoked(true);
        refreshTokenRepository.save(stored);
        return issueTokens(stored.getUser());
    }

    private AuthResponse issueTokens(User user) {
        String accessToken = jwtService.generateToken(user);
        String refreshTokenValue = UUID.randomUUID().toString();
        refreshTokenRepository.save(RefreshToken.builder()
                .token(refreshTokenValue)
                .user(user)
                .expiresAt(Instant.now().plusSeconds(7 * 24 * 3600))
                .revoked(false)
                .build());
        return AuthResponse.of(accessToken, refreshTokenValue);
    }
}
