package sys.azentic.billwise_api.auth.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import sys.azentic.billwise_api.auth.dto.AuthResponse;
import sys.azentic.billwise_api.auth.dto.LoginRequest;
import sys.azentic.billwise_api.auth.dto.RefreshRequest;
import sys.azentic.billwise_api.auth.dto.RegisterRequest;
import sys.azentic.billwise_api.auth.service.AuthService;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @ResponseStatus(HttpStatus.CREATED)
    public AuthResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/refresh")
    public AuthResponse refresh(@Valid @RequestBody RefreshRequest request) {
        return authService.refresh(request.token());
    }
}
