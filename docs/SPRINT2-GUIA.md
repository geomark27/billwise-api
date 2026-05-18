# Sprint 2 — Guía de desarrollo

> Escribe cada archivo en el orden indicado. Cada sección depende de la anterior.

---

## PARTE 1 — Cerrar Sprint 1

### 1.1 Excepciones personalizadas

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/exception/ResourceNotFoundException.java`

```java
package sys.azentic.billwise_api.exception;

public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/exception/ConflictException.java`

```java
package sys.azentic.billwise_api.exception;

public class ConflictException extends RuntimeException {
    public ConflictException(String message) {
        super(message);
    }
}
```

---

### 1.2 Actualizar GlobalExceptionHandler

**Archivo:** `src/main/java/sys/azentic/billwise_api/exception/GlobalExceptionHandler.java`

Reemplaza el archivo completo con:

```java
package sys.azentic.billwise_api.exception;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Instant;
import java.util.List;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiError handleValidation(MethodArgumentNotValidException ex, HttpServletRequest req) {
        List<String> details = ex.getBindingResult().getFieldErrors().stream()
                .map(FieldError::getDefaultMessage)
                .toList();
        return ApiError.builder()
                .status(400).error("Validation Failed")
                .message("One or more fields are invalid")
                .path(req.getRequestURI()).timestamp(Instant.now())
                .details(details).build();
    }

    @ExceptionHandler(BadCredentialsException.class)
    @ResponseStatus(HttpStatus.UNAUTHORIZED)
    public ApiError handleBadCredentials(BadCredentialsException ex, HttpServletRequest req) {
        return ApiError.builder()
                .status(401).error("Unauthorized")
                .message("Invalid email or password")
                .path(req.getRequestURI()).timestamp(Instant.now()).build();
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    public ApiError handleNotFound(ResourceNotFoundException ex, HttpServletRequest req) {
        return ApiError.builder()
                .status(404).error("Not Found")
                .message(ex.getMessage())
                .path(req.getRequestURI()).timestamp(Instant.now()).build();
    }

    @ExceptionHandler(ConflictException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ApiError handleConflict(ConflictException ex, HttpServletRequest req) {
        return ApiError.builder()
                .status(409).error("Conflict")
                .message(ex.getMessage())
                .path(req.getRequestURI()).timestamp(Instant.now()).build();
    }

    @ExceptionHandler(IllegalArgumentException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ApiError handleIllegalArgument(IllegalArgumentException ex, HttpServletRequest req) {
        return ApiError.builder()
                .status(400).error("Bad Request")
                .message(ex.getMessage())
                .path(req.getRequestURI()).timestamp(Instant.now()).build();
    }

    @ExceptionHandler(Exception.class)
    @ResponseStatus(HttpStatus.INTERNAL_SERVER_ERROR)
    public ApiError handleGeneric(Exception ex, HttpServletRequest req) {
        return ApiError.builder()
                .status(500).error("Internal Server Error")
                .message("An unexpected error occurred")
                .path(req.getRequestURI()).timestamp(Instant.now()).build();
    }
}
```

---

### 1.3 Logout

**Archivo:** `src/main/java/sys/azentic/billwise_api/auth/dto/LogoutRequest.java`

```java
package sys.azentic.billwise_api.auth.dto;

import jakarta.validation.constraints.NotBlank;

public record LogoutRequest(
        @NotBlank String refreshToken
) {}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/auth/service/AuthService.java`

Agrega este método al final de la clase (antes del último `}`):

```java
@Transactional
public void logout(String tokenValue) {
    var stored = refreshTokenRepository.findByToken(tokenValue)
            .orElseThrow(() -> new ResourceNotFoundException("Refresh token not found"));
    stored.setRevoked(true);
    refreshTokenRepository.save(stored);
}
```

> Agrega también el import: `import sys.azentic.billwise_api.exception.ResourceNotFoundException;`

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/auth/controller/AuthController.java`

Agrega este endpoint (antes del último `}`):

```java
@PostMapping("/logout")
@ResponseStatus(HttpStatus.NO_CONTENT)
public void logout(@Valid @RequestBody LogoutRequest request) {
    authService.logout(request.refreshToken());
}
```

> Agrega también los imports:
> ```java
> import sys.azentic.billwise_api.auth.dto.LogoutRequest;
> ```

---

### 1.4 Perfil de usuario

**Archivo:** `src/main/java/sys/azentic/billwise_api/user/dto/UserProfileResponse.java`

```java
package sys.azentic.billwise_api.user.dto;

import sys.azentic.billwise_api.user.model.ExperienceLevel;
import sys.azentic.billwise_api.user.model.MarketTarget;

import java.math.BigDecimal;
import java.util.UUID;

public record UserProfileResponse(
        UUID id,
        String name,
        String email,
        ExperienceLevel experienceLevel,
        BigDecimal hourlyRate,
        MarketTarget marketTarget
) {}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/user/dto/UpdateProfileRequest.java`

```java
package sys.azentic.billwise_api.user.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import sys.azentic.billwise_api.user.model.ExperienceLevel;
import sys.azentic.billwise_api.user.model.MarketTarget;

import java.math.BigDecimal;

public record UpdateProfileRequest(
        String name,
        ExperienceLevel experienceLevel,
        @DecimalMin("0.0") @Digits(integer = 8, fraction = 2) BigDecimal hourlyRate,
        MarketTarget marketTarget
) {}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/user/service/UserService.java`

```java
package sys.azentic.billwise_api.user.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sys.azentic.billwise_api.user.dto.UpdateProfileRequest;
import sys.azentic.billwise_api.user.dto.UserProfileResponse;
import sys.azentic.billwise_api.user.model.User;
import sys.azentic.billwise_api.user.repository.UserRepository;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    public UserProfileResponse getProfile(User user) {
        return toResponse(user);
    }

    @Transactional
    public UserProfileResponse updateProfile(User user, UpdateProfileRequest request) {
        if (request.name() != null) user.setName(request.name());
        if (request.experienceLevel() != null) user.setExperienceLevel(request.experienceLevel());
        if (request.hourlyRate() != null) user.setHourlyRate(request.hourlyRate());
        if (request.marketTarget() != null) user.setMarketTarget(request.marketTarget());
        return toResponse(userRepository.save(user));
    }

    private UserProfileResponse toResponse(User user) {
        return new UserProfileResponse(
                user.getId(), user.getName(), user.getEmail(),
                user.getExperienceLevel(), user.getHourlyRate(), user.getMarketTarget()
        );
    }
}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/user/controller/UserController.java`

```java
package sys.azentic.billwise_api.user.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import sys.azentic.billwise_api.user.dto.UpdateProfileRequest;
import sys.azentic.billwise_api.user.dto.UserProfileResponse;
import sys.azentic.billwise_api.user.model.User;
import sys.azentic.billwise_api.user.service.UserService;

@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @GetMapping("/me")
    public UserProfileResponse getProfile(@AuthenticationPrincipal User user) {
        return userService.getProfile(user);
    }

    @PatchMapping("/me")
    public UserProfileResponse updateProfile(@AuthenticationPrincipal User user,
                                             @Valid @RequestBody UpdateProfileRequest request) {
        return userService.updateProfile(user, request);
    }
}
```

---

## PARTE 2 — Migraciones Flyway

Crea estos archivos en `src/main/resources/db/migration/`:

---

**Archivo:** `V3__create_estimates_table.sql`

```sql
CREATE TABLE estimates (
    id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id           UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    title             VARCHAR(255) NOT NULL,
    raw_input         TEXT,
    input_type        VARCHAR(20)  NOT NULL DEFAULT 'TEXT'
                          CHECK (input_type IN ('TEXT', 'FILE', 'FORM')),
    status            VARCHAR(20)  NOT NULL DEFAULT 'DRAFT'
                          CHECK (status IN ('DRAFT', 'SENT', 'ACCEPTED', 'REJECTED')),
    total_hours_min   INTEGER,
    total_hours_max   INTEGER,
    total_price_min   DECIMAL(12, 2),
    total_price_max   DECIMAL(12, 2),
    total_price_recommended DECIMAL(12, 2),
    market_multiplier DECIMAL(4, 2),
    risk_margin       DECIMAL(4, 2),
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_estimates_user_id ON estimates (user_id);
CREATE INDEX idx_estimates_status   ON estimates (status);
```

---

**Archivo:** `V4__create_estimate_components_table.sql`

```sql
CREATE TABLE estimate_components (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    estimate_id  UUID NOT NULL REFERENCES estimates (id) ON DELETE CASCADE,
    name         VARCHAR(255) NOT NULL,
    description  TEXT,
    type         VARCHAR(100) NOT NULL,
    complexity   VARCHAR(10)  NOT NULL CHECK (complexity IN ('LOW', 'MEDIUM', 'HIGH')),
    ambiguity    VARCHAR(10)  NOT NULL CHECK (ambiguity IN ('LOW', 'MEDIUM', 'HIGH')),
    hours_min    INTEGER      NOT NULL,
    hours_max    INTEGER      NOT NULL,
    hours_used   INTEGER,
    price_min    DECIMAL(12, 2),
    price_max    DECIMAL(12, 2),
    price_recommended DECIMAL(12, 2),
    is_manual    BOOLEAN      NOT NULL DEFAULT FALSE,
    sort_order   INTEGER      NOT NULL DEFAULT 0
);

CREATE INDEX idx_estimate_components_estimate_id ON estimate_components (estimate_id);
```

---

**Archivo:** `V5__create_component_hour_templates_table.sql`

```sql
CREATE TABLE component_hour_templates (
    id           UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    type         VARCHAR(100) NOT NULL,
    complexity   VARCHAR(10)  NOT NULL CHECK (complexity IN ('LOW', 'MEDIUM', 'HIGH')),
    hours_min    INTEGER      NOT NULL,
    hours_max    INTEGER      NOT NULL,
    UNIQUE (type, complexity)
);

-- Valores iniciales extraídos de la lógica de negocio
INSERT INTO component_hour_templates (type, complexity, hours_min, hours_max) VALUES
('AUTH',            'LOW',    4,  6),
('AUTH',            'MEDIUM', 8,  12),
('AUTH',            'HIGH',   14, 20),
('CRUD',            'LOW',    2,  4),
('CRUD',            'MEDIUM', 5,  8),
('CRUD',            'HIGH',   10, 16),
('API_INTEGRATION', 'LOW',    4,  8),
('API_INTEGRATION', 'MEDIUM', 10, 16),
('API_INTEGRATION', 'HIGH',   18, 28),
('DASHBOARD',       'LOW',    6,  10),
('DASHBOARD',       'MEDIUM', 14, 20),
('DASHBOARD',       'HIGH',   22, 35),
('ROLES',           'LOW',    6,  10),
('ROLES',           'MEDIUM', 12, 18),
('ROLES',           'HIGH',   20, 30),
('FILE_PROCESSING', 'LOW',    4,  8),
('FILE_PROCESSING', 'MEDIUM', 10, 16),
('FILE_PROCESSING', 'HIGH',   18, 26),
('PWA_OFFLINE',     'LOW',    4,  6),
('PWA_OFFLINE',     'MEDIUM', 8,  14),
('PWA_OFFLINE',     'HIGH',   16, 24),
('INFRASTRUCTURE',  'LOW',    3,  5),
('INFRASTRUCTURE',  'MEDIUM', 6,  10),
('INFRASTRUCTURE',  'HIGH',   12, 18),
('NOTIFICATIONS',   'LOW',    2,  4),
('NOTIFICATIONS',   'MEDIUM', 6,  10),
('NOTIFICATIONS',   'HIGH',   12, 18),
('AI_ENGINE',       'LOW',    8,  14),
('AI_ENGINE',       'MEDIUM', 16, 24),
('AI_ENGINE',       'HIGH',   28, 40);
```

---

**Archivo:** `V6__create_user_calibrations_table.sql`

```sql
CREATE TABLE user_calibrations (
    id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    component_type VARCHAR(100) NOT NULL,
    complexity     VARCHAR(10)  NOT NULL CHECK (complexity IN ('LOW', 'MEDIUM', 'HIGH')),
    avg_hours      DECIMAL(6, 2) NOT NULL,
    sample_count   INTEGER       NOT NULL DEFAULT 1,
    updated_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (user_id, component_type, complexity)
);
```

---

**Archivo:** `V7__create_ai_usage_log_table.sql`

```sql
CREATE TABLE ai_usage_log (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    estimate_id     UUID REFERENCES estimates (id) ON DELETE SET NULL,
    model           VARCHAR(100) NOT NULL,
    prompt_tokens   INTEGER NOT NULL DEFAULT 0,
    completion_tokens INTEGER NOT NULL DEFAULT 0,
    total_tokens    INTEGER NOT NULL DEFAULT 0,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_ai_usage_log_user_id ON ai_usage_log (user_id);
```

---

## PARTE 3 — Módulo de Estimados

### 3.1 Enums

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/model/InputType.java`

```java
package sys.azentic.billwise_api.estimate.model;

public enum InputType { TEXT, FILE, FORM }
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/model/EstimateStatus.java`

```java
package sys.azentic.billwise_api.estimate.model;

public enum EstimateStatus { DRAFT, SENT, ACCEPTED, REJECTED }
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/model/Complexity.java`

```java
package sys.azentic.billwise_api.estimate.model;

public enum Complexity { LOW, MEDIUM, HIGH }
```

---

### 3.2 Entidades JPA

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/model/Estimate.java`

```java
package sys.azentic.billwise_api.estimate.model;

import jakarta.persistence.*;
import lombok.*;
import sys.azentic.billwise_api.user.model.User;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "estimates")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class Estimate {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String rawInput;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private InputType inputType = InputType.TEXT;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    @Builder.Default
    private EstimateStatus status = EstimateStatus.DRAFT;

    private Integer totalHoursMin;
    private Integer totalHoursMax;
    private BigDecimal totalPriceMin;
    private BigDecimal totalPriceMax;
    private BigDecimal totalPriceRecommended;
    private BigDecimal marketMultiplier;
    private BigDecimal riskMargin;

    @OneToMany(mappedBy = "estimate", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<EstimateComponent> components = new ArrayList<>();

    private Instant createdAt;
    private Instant updatedAt;

    @PrePersist
    protected void onCreate() { createdAt = updatedAt = Instant.now(); }

    @PreUpdate
    protected void onUpdate() { updatedAt = Instant.now(); }
}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/model/EstimateComponent.java`

```java
package sys.azentic.billwise_api.estimate.model;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "estimate_components")
@Getter @Setter @Builder @NoArgsConstructor @AllArgsConstructor
public class EstimateComponent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "estimate_id", nullable = false)
    private Estimate estimate;

    @Column(nullable = false)
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(nullable = false)
    private String type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Complexity complexity;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Complexity ambiguity;

    @Column(nullable = false)
    private Integer hoursMin;

    @Column(nullable = false)
    private Integer hoursMax;

    private Integer hoursUsed;
    private BigDecimal priceMin;
    private BigDecimal priceMax;
    private BigDecimal priceRecommended;

    @Builder.Default
    private boolean isManual = false;

    @Builder.Default
    private Integer sortOrder = 0;
}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/model/ComponentHourTemplate.java`

```java
package sys.azentic.billwise_api.estimate.model;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "component_hour_templates")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class ComponentHourTemplate {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String type;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private Complexity complexity;

    @Column(nullable = false)
    private Integer hoursMin;

    @Column(nullable = false)
    private Integer hoursMax;
}
```

---

### 3.3 Repositorios

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/repository/EstimateRepository.java`

```java
package sys.azentic.billwise_api.estimate.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sys.azentic.billwise_api.estimate.model.Estimate;
import sys.azentic.billwise_api.estimate.model.EstimateStatus;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface EstimateRepository extends JpaRepository<Estimate, UUID> {
    List<Estimate> findByUserIdOrderByCreatedAtDesc(UUID userId);
    List<Estimate> findByUserIdAndStatusOrderByCreatedAtDesc(UUID userId, EstimateStatus status);
    Optional<Estimate> findByIdAndUserId(UUID id, UUID userId);
}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/repository/EstimateComponentRepository.java`

```java
package sys.azentic.billwise_api.estimate.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sys.azentic.billwise_api.estimate.model.EstimateComponent;

import java.util.Optional;
import java.util.UUID;

public interface EstimateComponentRepository extends JpaRepository<EstimateComponent, UUID> {
    Optional<EstimateComponent> findByIdAndEstimateId(UUID id, UUID estimateId);
}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/repository/ComponentHourTemplateRepository.java`

```java
package sys.azentic.billwise_api.estimate.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import sys.azentic.billwise_api.estimate.model.ComponentHourTemplate;
import sys.azentic.billwise_api.estimate.model.Complexity;

import java.util.Optional;
import java.util.UUID;

public interface ComponentHourTemplateRepository extends JpaRepository<ComponentHourTemplate, UUID> {
    Optional<ComponentHourTemplate> findByTypeAndComplexity(String type, Complexity complexity);
}
```

---

### 3.4 DTOs

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/dto/ComponentRequest.java`

```java
package sys.azentic.billwise_api.estimate.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import sys.azentic.billwise_api.estimate.model.Complexity;

public record ComponentRequest(
        @NotBlank String name,
        String description,
        @NotBlank String type,
        @NotNull Complexity complexity,
        @NotNull Complexity ambiguity
) {}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/dto/CreateEstimateRequest.java`

```java
package sys.azentic.billwise_api.estimate.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;

import java.util.List;

public record CreateEstimateRequest(
        @NotBlank String title,
        String rawInput,
        @NotEmpty @Valid List<ComponentRequest> components
) {}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/dto/UpdateComponentRequest.java`

```java
package sys.azentic.billwise_api.estimate.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import sys.azentic.billwise_api.estimate.model.Complexity;

public record UpdateComponentRequest(
        @NotNull @Min(1) Integer hoursUsed,
        Complexity complexity,
        Complexity ambiguity
) {}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/dto/UpdateEstimateStatusRequest.java`

```java
package sys.azentic.billwise_api.estimate.dto;

import jakarta.validation.constraints.NotNull;
import sys.azentic.billwise_api.estimate.model.EstimateStatus;

public record UpdateEstimateStatusRequest(
        @NotNull EstimateStatus status
) {}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/dto/ComponentResponse.java`

```java
package sys.azentic.billwise_api.estimate.dto;

import sys.azentic.billwise_api.estimate.model.Complexity;
import sys.azentic.billwise_api.estimate.model.EstimateComponent;

import java.math.BigDecimal;
import java.util.UUID;

public record ComponentResponse(
        UUID id,
        String name,
        String description,
        String type,
        Complexity complexity,
        Complexity ambiguity,
        Integer hoursMin,
        Integer hoursMax,
        Integer hoursUsed,
        BigDecimal priceMin,
        BigDecimal priceMax,
        BigDecimal priceRecommended,
        boolean isManual
) {
    public static ComponentResponse from(EstimateComponent c) {
        return new ComponentResponse(
                c.getId(), c.getName(), c.getDescription(), c.getType(),
                c.getComplexity(), c.getAmbiguity(),
                c.getHoursMin(), c.getHoursMax(), c.getHoursUsed(),
                c.getPriceMin(), c.getPriceMax(), c.getPriceRecommended(),
                c.isManual()
        );
    }
}
```

---

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/dto/EstimateResponse.java`

```java
package sys.azentic.billwise_api.estimate.dto;

import sys.azentic.billwise_api.estimate.model.Estimate;
import sys.azentic.billwise_api.estimate.model.EstimateStatus;
import sys.azentic.billwise_api.estimate.model.InputType;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record EstimateResponse(
        UUID id,
        String title,
        InputType inputType,
        EstimateStatus status,
        Integer totalHoursMin,
        Integer totalHoursMax,
        BigDecimal totalPriceMin,
        BigDecimal totalPriceMax,
        BigDecimal totalPriceRecommended,
        BigDecimal marketMultiplier,
        BigDecimal riskMargin,
        List<ComponentResponse> components,
        Instant createdAt,
        Instant updatedAt
) {
    public static EstimateResponse from(Estimate e) {
        return new EstimateResponse(
                e.getId(), e.getTitle(), e.getInputType(), e.getStatus(),
                e.getTotalHoursMin(), e.getTotalHoursMax(),
                e.getTotalPriceMin(), e.getTotalPriceMax(), e.getTotalPriceRecommended(),
                e.getMarketMultiplier(), e.getRiskMargin(),
                e.getComponents().stream().map(ComponentResponse::from).toList(),
                e.getCreatedAt(), e.getUpdatedAt()
        );
    }
}
```

---

### 3.5 PriceCalculatorService

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/service/PriceCalculatorService.java`

```java
package sys.azentic.billwise_api.estimate.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import sys.azentic.billwise_api.estimate.model.Complexity;
import sys.azentic.billwise_api.estimate.model.EstimateComponent;
import sys.azentic.billwise_api.estimate.repository.ComponentHourTemplateRepository;
import sys.azentic.billwise_api.user.model.MarketTarget;
import sys.azentic.billwise_api.user.model.User;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PriceCalculatorService {

    private final ComponentHourTemplateRepository templateRepository;

    // Resuelve horas del template en DB; si no existe el tipo usa LOW como fallback
    public int[] resolveHours(String type, Complexity complexity) {
        return templateRepository.findByTypeAndComplexity(type, complexity)
                .map(t -> new int[]{t.getHoursMin(), t.getHoursMax()})
                .orElse(new int[]{4, 8});
    }

    public BigDecimal marketMultiplier(MarketTarget target) {
        if (target == null) return BigDecimal.ONE;
        return switch (target) {
            case LOCAL         -> new BigDecimal("1.0");
            case REGIONAL      -> new BigDecimal("1.3");
            case INTERNATIONAL -> new BigDecimal("2.0");
        };
    }

    public BigDecimal riskMargin(Complexity ambiguity) {
        return switch (ambiguity) {
            case LOW    -> new BigDecimal("0.00");
            case MEDIUM -> new BigDecimal("0.10");
            case HIGH   -> new BigDecimal("0.20");
        };
    }

    // Calcula el margen de riesgo general basado en la ambigüedad promedio
    public Complexity dominantAmbiguity(List<EstimateComponent> components) {
        long high = components.stream().filter(c -> c.getAmbiguity() == Complexity.HIGH).count();
        long medium = components.stream().filter(c -> c.getAmbiguity() == Complexity.MEDIUM).count();
        if (high > 0) return Complexity.HIGH;
        if (medium > 0) return Complexity.MEDIUM;
        return Complexity.LOW;
    }

    public void calculateComponentPrice(EstimateComponent component, User user,
                                        BigDecimal multiplier, BigDecimal margin) {
        BigDecimal rate = user.getHourlyRate() != null
                ? user.getHourlyRate() : BigDecimal.ZERO;

        int hours = component.getHoursUsed() != null
                ? component.getHoursUsed()
                : (component.getHoursMin() + component.getHoursMax()) / 2;

        BigDecimal factor = BigDecimal.ONE.add(margin).multiply(multiplier);

        component.setPriceMin(rate.multiply(BigDecimal.valueOf(component.getHoursMin()))
                .multiply(factor).setScale(2, RoundingMode.HALF_UP));
        component.setPriceMax(rate.multiply(BigDecimal.valueOf(component.getHoursMax()))
                .multiply(factor).setScale(2, RoundingMode.HALF_UP));
        component.setPriceRecommended(rate.multiply(BigDecimal.valueOf(hours))
                .multiply(factor).setScale(2, RoundingMode.HALF_UP));
    }
}
```

---

### 3.6 EstimateService

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/service/EstimateService.java`

```java
package sys.azentic.billwise_api.estimate.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import sys.azentic.billwise_api.estimate.dto.*;
import sys.azentic.billwise_api.estimate.model.*;
import sys.azentic.billwise_api.estimate.repository.EstimateComponentRepository;
import sys.azentic.billwise_api.estimate.repository.EstimateRepository;
import sys.azentic.billwise_api.exception.ResourceNotFoundException;
import sys.azentic.billwise_api.user.model.User;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class EstimateService {

    private final EstimateRepository estimateRepository;
    private final EstimateComponentRepository componentRepository;
    private final PriceCalculatorService calculator;

    @Transactional
    public EstimateResponse create(User user, CreateEstimateRequest request) {
        BigDecimal multiplier = calculator.marketMultiplier(user.getMarketTarget());

        List<EstimateComponent> components = new ArrayList<>();
        for (int i = 0; i < request.components().size(); i++) {
            ComponentRequest cr = request.components().get(i);
            int[] hours = calculator.resolveHours(cr.type(), cr.complexity());
            EstimateComponent component = EstimateComponent.builder()
                    .name(cr.name()).description(cr.description())
                    .type(cr.type()).complexity(cr.complexity()).ambiguity(cr.ambiguity())
                    .hoursMin(hours[0]).hoursMax(hours[1])
                    .sortOrder(i).build();
            components.add(component);
        }

        BigDecimal margin = calculator.riskMargin(calculator.dominantAmbiguity(components));
        components.forEach(c -> calculator.calculateComponentPrice(c, user, multiplier, margin));

        int totalMin = components.stream().mapToInt(EstimateComponent::getHoursMin).sum();
        int totalMax = components.stream().mapToInt(EstimateComponent::getHoursMax).sum();
        BigDecimal priceMin = components.stream().map(EstimateComponent::getPriceMin)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal priceMax = components.stream().map(EstimateComponent::getPriceMax)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal priceRec = components.stream().map(EstimateComponent::getPriceRecommended)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        Estimate estimate = Estimate.builder()
                .user(user).title(request.title()).rawInput(request.rawInput())
                .inputType(InputType.TEXT)
                .totalHoursMin(totalMin).totalHoursMax(totalMax)
                .totalPriceMin(priceMin).totalPriceMax(priceMax).totalPriceRecommended(priceRec)
                .marketMultiplier(multiplier).riskMargin(margin)
                .build();

        components.forEach(c -> c.setEstimate(estimate));
        estimate.getComponents().addAll(components);

        return EstimateResponse.from(estimateRepository.save(estimate));
    }

    public List<EstimateResponse> listByUser(User user) {
        return estimateRepository.findByUserIdOrderByCreatedAtDesc(user.getId())
                .stream().map(EstimateResponse::from).toList();
    }

    public EstimateResponse getById(User user, UUID id) {
        return EstimateResponse.from(findOwned(id, user.getId()));
    }

    @Transactional
    public EstimateResponse updateStatus(User user, UUID id, UpdateEstimateStatusRequest request) {
        Estimate estimate = findOwned(id, user.getId());
        estimate.setStatus(request.status());
        return EstimateResponse.from(estimateRepository.save(estimate));
    }

    @Transactional
    public EstimateResponse updateComponent(User user, UUID estimateId, UUID componentId,
                                            UpdateComponentRequest request) {
        Estimate estimate = findOwned(estimateId, user.getId());
        EstimateComponent component = componentRepository
                .findByIdAndEstimateId(componentId, estimateId)
                .orElseThrow(() -> new ResourceNotFoundException("Component not found"));

        component.setHoursUsed(request.hoursUsed());
        if (request.complexity() != null) component.setComplexity(request.complexity());
        if (request.ambiguity() != null) component.setAmbiguity(request.ambiguity());
        component.setManual(true);

        BigDecimal multiplier = calculator.marketMultiplier(user.getMarketTarget());
        BigDecimal margin = calculator.riskMargin(component.getAmbiguity());
        calculator.calculateComponentPrice(component, user, multiplier, margin);

        componentRepository.save(component);
        return EstimateResponse.from(estimateRepository.findByIdAndUserId(estimateId, user.getId()).orElseThrow());
    }

    private Estimate findOwned(UUID id, UUID userId) {
        return estimateRepository.findByIdAndUserId(id, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Estimate not found"));
    }
}
```

---

### 3.7 EstimateController

**Archivo:** `src/main/java/sys/azentic/billwise_api/estimate/controller/EstimateController.java`

```java
package sys.azentic.billwise_api.estimate.controller;

import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import sys.azentic.billwise_api.estimate.dto.*;
import sys.azentic.billwise_api.estimate.service.EstimateService;
import sys.azentic.billwise_api.user.model.User;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/estimates")
@RequiredArgsConstructor
public class EstimateController {

    private final EstimateService estimateService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public EstimateResponse create(@AuthenticationPrincipal User user,
                                   @Valid @RequestBody CreateEstimateRequest request) {
        return estimateService.create(user, request);
    }

    @GetMapping
    public List<EstimateResponse> list(@AuthenticationPrincipal User user) {
        return estimateService.listByUser(user);
    }

    @GetMapping("/{id}")
    public EstimateResponse getById(@AuthenticationPrincipal User user,
                                    @PathVariable UUID id) {
        return estimateService.getById(user, id);
    }

    @PatchMapping("/{id}")
    public EstimateResponse updateStatus(@AuthenticationPrincipal User user,
                                         @PathVariable UUID id,
                                         @Valid @RequestBody UpdateEstimateStatusRequest request) {
        return estimateService.updateStatus(user, id, request);
    }

    @PutMapping("/{id}/components/{componentId}")
    public EstimateResponse updateComponent(@AuthenticationPrincipal User user,
                                            @PathVariable UUID id,
                                            @PathVariable UUID componentId,
                                            @Valid @RequestBody UpdateComponentRequest request) {
        return estimateService.updateComponent(user, id, componentId, request);
    }
}
```

---

## Orden de creación recomendado

```
1. exception/ResourceNotFoundException.java
2. exception/ConflictException.java
3. exception/GlobalExceptionHandler.java        ← reemplazar
4. auth/dto/LogoutRequest.java
5. auth/service/AuthService.java                ← agregar logout()
6. auth/controller/AuthController.java          ← agregar endpoint logout
7. user/dto/UserProfileResponse.java
8. user/dto/UpdateProfileRequest.java
9. user/service/UserService.java
10. user/controller/UserController.java
11. db/migration/V3__create_estimates_table.sql
12. db/migration/V4__create_estimate_components_table.sql
13. db/migration/V5__create_component_hour_templates_table.sql
14. db/migration/V6__create_user_calibrations_table.sql
15. db/migration/V7__create_ai_usage_log_table.sql
16. estimate/model/InputType.java
17. estimate/model/EstimateStatus.java
18. estimate/model/Complexity.java
19. estimate/model/Estimate.java
20. estimate/model/EstimateComponent.java
21. estimate/model/ComponentHourTemplate.java
22. estimate/repository/EstimateRepository.java
23. estimate/repository/EstimateComponentRepository.java
24. estimate/repository/ComponentHourTemplateRepository.java
25. estimate/dto/ComponentRequest.java
26. estimate/dto/CreateEstimateRequest.java
27. estimate/dto/UpdateComponentRequest.java
28. estimate/dto/UpdateEstimateStatusRequest.java
29. estimate/dto/ComponentResponse.java
30. estimate/dto/EstimateResponse.java
31. estimate/service/PriceCalculatorService.java
32. estimate/service/EstimateService.java
33. estimate/controller/EstimateController.java
```

## Verificación final

Después de escribir todo, corre:

```bash
make start
```

Prueba en orden:
1. `POST /api/auth/register`
2. `POST /api/auth/login`
3. `PATCH /api/users/me` — setear `hourlyRate` y `marketTarget`
4. `POST /api/estimates` — crear estimado con componentes manuales
5. `GET /api/estimates` — listar
6. `PUT /api/estimates/{id}/components/{cid}` — editar horas
