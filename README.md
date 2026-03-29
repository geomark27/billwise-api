# Billwise API

Backend de Billwise construido con Spring Boot 3 + Java 21.

## Requisitos

- Java 21
- Maven 3.9+
- PostgreSQL 15+

## Setup local

### 1. Clonar y configurar variables de entorno

```bash
cp .env.example .env
# Editar .env con tus valores
```

### 2. Crear la base de datos

```sql
CREATE DATABASE billwise_dev;
```

### 3. Correr la aplicación

```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

Flyway corre automáticamente las migraciones al iniciar.

### 4. Verificar que funciona

```bash
# Registro
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@billwise.com","password":"password123"}'

# Login
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@billwise.com","password":"password123"}'
```

## Tests

```bash
./mvnw test
```

## Estructura de paquetes

```
com.billwise
├── BillwiseApplication.java
├── auth/
│   ├── User.java
│   ├── RefreshToken.java
│   ├── UserRepository.java
│   ├── RefreshTokenRepository.java
│   ├── controller/
│   │   └── AuthController.java
│   ├── service/
│   │   ├── AuthService.java
│   │   └── JwtService.java
│   └── dto/
│       ├── RegisterRequest.java
│       ├── LoginRequest.java
│       ├── RefreshRequest.java
│       └── AuthResponse.java
├── config/
│   ├── SecurityConfig.java
│   └── JwtAuthFilter.java
└── exception/
    ├── AuthException.java
    └── GlobalExceptionHandler.java
```

## Endpoints — Sprint 1

| Método | Endpoint | Auth | Descripción |
|--------|----------|------|-------------|
| POST | `/api/auth/register` | No | Registro de usuario |
| POST | `/api/auth/login` | No | Login, retorna JWT + refresh token |
| POST | `/api/auth/refresh` | No | Renovar access token |

## Sprints

- [x] **Sprint 1** — Auth + JWT + Base de datos
- [ ] Sprint 2 — Modelo de estimados + motor de cálculo
- [ ] Sprint 3 — Integración Claude API
- [ ] Sprint 4 — Procesamiento de archivos
- [ ] Sprint 5 — Frontend
- [ ] Sprint 6 — Export + configuración
- [ ] Sprint 7 — Deploy + pulido
