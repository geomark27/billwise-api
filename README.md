# Billwise API

Backend del sistema **Billwise** — herramienta SaaS que convierte la descripción o documentación de un proyecto de software en un estimado económico fundamentado, ajustado al mercado del freelancer.

> Elimina la subjetividad del proceso de cotización y le da al desarrollador independiente un argumento técnico respaldado por datos para sostener su precio.

---

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| Backend | Spring Boot 4.x + Java 21 |
| Base de datos | PostgreSQL 16 |
| ORM | Spring Data JPA + Hibernate |
| Migraciones | Flyway |
| Autenticación | JWT + Spring Security |
| IA | Claude API (claude-sonnet) |
| Almacenamiento | AWS S3 / Cloudflare R2 |

---

## Arquitectura

```
Cliente (Next.js)
      │ HTTPS / REST
      ▼
Spring Boot API
  ├── Auth Module       (JWT + Refresh Tokens)
  ├── Estimate Module   (Motor de cálculo)
  ├── AI Service Layer  (Claude API — extracción de componentes)
  ├── File Parser       (PDF / DOCX / MD)
  └── Export Service    (Generación de PDF)
      │
      ├── PostgreSQL    (Datos core)
      └── S3 / R2       (Archivos subidos)
```

---

## Requisitos previos

- Java 21+
- Docker y Docker Compose
- Maven (o usar el wrapper `./mvnw` incluido)

---

## Configuración local

### 1. Variables de entorno

```bash
cp .env.example .env
```

Edita `.env` con tus valores:

```env
# Base de datos
DB_NAME=billwise_dev
DB_USER=tu_usuario
DB_PASSWORD=tu_password
DB_PORT=5433

# Spring Boot
SPRING_PROFILES_ACTIVE=dev

# JWT — genera uno seguro con: make gen-jwt
JWT_SECRET=tu_secreto_jwt
```

### 2. Levantar infraestructura y arrancar

```bash
make start
```

Este comando ejecuta en secuencia:
1. Levanta PostgreSQL vía Docker Compose
2. Compila el proyecto
3. Ejecuta la aplicación con el perfil `dev`

### Comandos disponibles

```bash
make help          # Ver todos los comandos disponibles
make db-up         # Solo levantar PostgreSQL
make db-down       # Detener PostgreSQL
make db-connect    # Conectarse a la DB por terminal
make compile       # Solo compilar
make run           # Solo ejecutar (requiere DB activa)
make start         # db-up + compile + run
make gen-jwt       # Generar un JWT_SECRET seguro
```

---

## Estructura del proyecto

```
src/main/java/sys/azentic/billwise_api/
├── auth/
│   ├── controller/     AuthController
│   ├── dto/            LoginRequest, RegisterRequest, RefreshRequest, AuthResponse
│   ├── model/          RefreshToken
│   ├── repository/     RefreshTokenRepository
│   └── service/        AuthService
├── config/
│   ├── ApplicationConfig     (AuthenticationProvider, PasswordEncoder)
│   └── SecurityConfig        (Rutas públicas y protegidas)
├── exception/
│   ├── ApiError
│   └── GlobalExceptionHandler
├── security/
│   ├── JwtService
│   ├── JwtAuthFilter
│   └── UserDetailsServiceImpl
└── user/
    ├── model/          User, Role, ExperienceLevel, MarketTarget
    └── repository/     UserRepository
```

---

## API — Endpoints implementados

### Autenticación

| Método | Endpoint | Descripción | Auth |
|--------|----------|-------------|------|
| `POST` | `/api/auth/register` | Registro de usuario | No |
| `POST` | `/api/auth/login` | Login — retorna JWT + refresh token | No |
| `POST` | `/api/auth/refresh` | Renovar access token | No |

#### Registro

```http
POST /api/auth/register
Content-Type: application/json

{
  "name": "Juan Pérez",
  "email": "juan@example.com",
  "password": "secreto123"
}
```

#### Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "juan@example.com",
  "password": "secreto123"
}
```

Respuesta:
```json
{
  "accessToken": "eyJhbGci...",
  "refreshToken": "uuid-refresh-token"
}
```

---

## Modelo de datos

### Tablas actuales

**`users`** — Usuarios del sistema
```
id, email, password_hash, name, experience_level,
hourly_rate, market_target, role, created_at, updated_at
```

**`refresh_tokens`** — Tokens de renovación JWT
```
id, token, user_id (FK), expires_at, revoked
```

### Migraciones Flyway

```
V1__create_users_table.sql
V2__create_refresh_tokens_table.sql
```

---

## Seguridad

- Passwords hasheados con **BCrypt** (strength 12)
- **JWT** con expiración de 24h
- **Refresh tokens** con expiración de 7 días y rotación en logout
- Todas las rutas protegidas validan que el recurso pertenezca al usuario autenticado
- Credenciales y secretos gestionados exclusivamente por variables de entorno

---

## Roadmap de desarrollo

| Sprint | Objetivo | Estado |
|--------|----------|--------|
| Sprint 1 | Fundación backend — Auth + JWT + DB | ✅ Completado |
| Sprint 2 | Modelo de datos completo + CRUD de estimados | 🔜 Pendiente |
| Sprint 3 | Integración con Claude API — motor de IA | 🔜 Pendiente |
| Sprint 4 | Procesamiento de archivos (PDF, DOCX) | 🔜 Pendiente |
| Sprint 5 | Frontend — Auth + flujo principal | 🔜 Pendiente |
| Sprint 6 | Frontend — Upload + exportación PDF | 🔜 Pendiente |
| Sprint 7 | Pulido + deploy producción | 🔜 Pendiente |

**Estimación total:** 14 semanas / 144–192 horas

---

## Lógica de negocio — Fórmula de estimación

```
precio_componente = horas_medias × tarifa_hora × multiplicador_mercado × (1 + margen_riesgo)
precio_total      = Σ(precio_componente)
```

**Multiplicadores de mercado:**

| Mercado | Multiplicador |
|---------|--------------|
| Local | 1.0× |
| Regional (Latinoamérica) | 1.3× |
| Internacional (EE.UU. / Europa) | 2.0× |

**Margen de riesgo por ambigüedad:** LOW → 0% | MEDIUM → 10% | HIGH → 20%

---

## Planes

| Plan | Precio | Límite |
|------|--------|--------|
| Free | $0/mes | 5 estimados/mes |
| Pro | $12/mes | Ilimitado + historial + calibración personal + exportación con branding |
| Team | $35/mes | Todo Pro para 5 usuarios *(largo plazo)* |
