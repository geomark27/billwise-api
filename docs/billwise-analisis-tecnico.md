# Billwise — Análisis Técnico

## 1. Stack tecnológico

| Capa | Tecnología | Justificación |
|------|-----------|---------------|
| Frontend | Next.js 14 + React | SSR para SEO, App Router, soporte nativo para rutas protegidas |
| Estilos | Tailwind CSS | Velocidad de desarrollo, consistencia visual |
| Backend | Spring Boot 3.x + Java 21 | Tipado fuerte para motor de cálculo, ecosistema maduro, Spring Security robusto |
| ORM | Spring Data JPA + Hibernate | Abstracción de queries, migraciones con Flyway |
| Base de datos | PostgreSQL | Relacional, soporte JSON nativo para guardar componentes dinámicos |
| IA | Claude API (claude-sonnet-4-5) | Extracción de componentes y análisis de documentos |
| Autenticación | JWT + Spring Security | Stateless, escalable, compatible con futuros providers OAuth |
| Almacenamiento | AWS S3 o Cloudflare R2 | Para archivos subidos por el usuario (PDFs, docs) |
| Deploy backend | Railway o Render | Soporte nativo para JARs, PostgreSQL incluido |
| Deploy frontend | Vercel | Optimizado para Next.js |

---

## 2. Arquitectura general

```
┌─────────────────────────────────────────────────────┐
│                   Cliente (Browser)                  │
│              Next.js — App Router                    │
└────────────────────┬────────────────────────────────┘
                     │ HTTPS / REST
┌────────────────────▼────────────────────────────────┐
│              Spring Boot API                         │
│                                                      │
│  ┌──────────────┐  ┌────────────────┐               │
│  │ Auth Module  │  │ Estimate Module│               │
│  │ JWT + Roles  │  │ Motor de cálc. │               │
│  └──────────────┘  └───────┬────────┘               │
│                            │                         │
│  ┌─────────────────────────▼──────────┐             │
│  │         AI Service Layer           │             │
│  │   Claude API — extracción + análisis│            │
│  └────────────────────────────────────┘             │
│                                                      │
│  ┌──────────────┐  ┌────────────────┐               │
│  │  File Parser │  │ Export Service │               │
│  │  PDF / DOCX  │  │ PDF generator  │               │
│  └──────────────┘  └────────────────┘               │
└────────────────────┬────────────────────────────────┘
                     │
       ┌─────────────┴──────────────┐
       │                            │
┌──────▼───────┐          ┌─────────▼──────┐
│  PostgreSQL  │          │  S3 / R2       │
│  Datos core  │          │  Archivos      │
└──────────────┘          └────────────────┘
```

---

## 3. Modelo de datos

### 3.1 Entidades principales

**users**
```sql
id              UUID PRIMARY KEY
email           VARCHAR(255) UNIQUE NOT NULL
password_hash   VARCHAR(255) NOT NULL
name            VARCHAR(255)
experience_level ENUM('JUNIOR', 'MID', 'SENIOR')
hourly_rate     DECIMAL(10,2)
market_target   ENUM('LOCAL', 'REGIONAL', 'INTERNATIONAL')
created_at      TIMESTAMP
updated_at      TIMESTAMP
```

**estimates**
```sql
id              UUID PRIMARY KEY
user_id         UUID REFERENCES users(id)
title           VARCHAR(255)
raw_input       TEXT                    -- texto libre o nombre del archivo
input_type      ENUM('TEXT', 'FILE', 'FORM')
status          ENUM('DRAFT', 'SENT', 'ACCEPTED', 'REJECTED')
total_hours_min INTEGER
total_hours_max INTEGER
total_price_min DECIMAL(10,2)
total_price_max DECIMAL(10,2)
market_multiplier DECIMAL(4,2)
risk_margin     DECIMAL(4,2)
created_at      TIMESTAMP
updated_at      TIMESTAMP
```

**estimate_components**
```sql
id              UUID PRIMARY KEY
estimate_id     UUID REFERENCES estimates(id)
name            VARCHAR(255)
description     TEXT
type            VARCHAR(100)            -- auth, crud, integration, etc.
complexity      ENUM('LOW', 'MEDIUM', 'HIGH')
ambiguity       ENUM('LOW', 'MEDIUM', 'HIGH')
hours_min       INTEGER
hours_max       INTEGER
hours_used      INTEGER                 -- valor editado por el usuario (si aplica)
is_manual       BOOLEAN DEFAULT FALSE   -- indica si fue editado manualmente
sort_order      INTEGER
```

**user_calibrations**
```sql
id              UUID PRIMARY KEY
user_id         UUID REFERENCES users(id)
component_type  VARCHAR(100)
complexity      ENUM('LOW', 'MEDIUM', 'HIGH')
avg_hours       DECIMAL(6,2)            -- promedio histórico del usuario
sample_count    INTEGER
updated_at      TIMESTAMP
```

**uploaded_files**
```sql
id              UUID PRIMARY KEY
estimate_id     UUID REFERENCES estimates(id)
original_name   VARCHAR(255)
storage_key     VARCHAR(512)            -- clave en S3/R2
mime_type       VARCHAR(100)
size_bytes      INTEGER
created_at      TIMESTAMP
```

---

## 4. Módulos Spring Boot

### 4.1 Auth Module
- `POST /api/auth/register` — registro de usuario
- `POST /api/auth/login` — login, retorna JWT
- `POST /api/auth/refresh` — renovar token
- Spring Security filtra todas las rutas excepto `/api/auth/**`

### 4.2 Estimate Module
- `POST /api/estimates` — crear estimado desde texto
- `POST /api/estimates/upload` — crear estimado desde archivo
- `GET /api/estimates` — listar estimados del usuario autenticado
- `GET /api/estimates/{id}` — detalle de un estimado
- `PATCH /api/estimates/{id}` — actualizar estado (sent, accepted, rejected)
- `PUT /api/estimates/{id}/components/{componentId}` — editar componente manualmente

### 4.3 AI Service Layer
- Responsabilidad única: comunicarse con Claude API
- Recibe texto plano (post-parsing si viene de archivo)
- Retorna lista de `ComponentDTO` estructurados
- Maneja reintentos y timeouts
- El prompt base es versionado internamente (cambiarlo no requiere redeploy)

### 4.4 File Parser
- Soporta: `.pdf`, `.docx`, `.md`, `.txt`
- Librerías: Apache PDFBox (PDF), Apache POI (DOCX)
- Output: texto plano extraído, enviado al AI Service Layer
- Archivos almacenados en S3/R2 antes del procesamiento

### 4.5 Export Service
- Genera PDF del estimado usando iText o JasperReports
- Formato: resumen ejecutivo + desglose + scope + notas
- `GET /api/estimates/{id}/export` — descarga el PDF

### 4.6 Calibration Service
- Corre en background (Spring `@Async`) cuando el usuario edita un componente
- Actualiza `user_calibrations` con el nuevo promedio móvil
- Influye en estimados futuros del mismo usuario

---

## 5. Integración con Claude API

### 5.1 Estrategia de prompt

El sistema usa un prompt estructurado con dos secciones:

**System prompt** (fijo, versionado):
```
Eres un asistente de estimación de proyectos de software. 
Dado el siguiente texto, identifica todos los componentes técnicos 
del proyecto y devuelve ÚNICAMENTE un JSON con esta estructura: [...]
```

**User prompt** (dinámico):
```
Texto del proyecto: {input}
Stack tecnológico declarado: {stack}
Contexto adicional: {context}
```

### 5.2 Manejo de respuesta

Claude retorna JSON. El servicio valida con Jackson y mapea a `List<ComponentDTO>`. Si el JSON es inválido o incompleto, se reintenta hasta 2 veces antes de retornar error al usuario.

### 5.3 Control de costos

- Se registra cada llamada a la API con tokens consumidos en tabla `ai_usage_log`
- En versión gratuita: máximo 5 estimados por mes
- En versión de pago: ilimitado (con throttle de 10 req/min)

---

## 6. Seguridad

- Passwords hasheados con BCrypt (strength 12)
- JWT con expiración de 24h, refresh token de 7 días
- Rate limiting en endpoints de auth (5 intentos por IP por minuto)
- Archivos subidos: validación de tipo MIME + tamaño máximo 10MB
- Todos los endpoints autenticados validan que el recurso pertenece al usuario (row-level security en queries)
- Variables sensibles (API keys, DB credentials) via variables de entorno, nunca hardcodeadas

---

## 7. Deuda técnica anticipada y mitigaciones

| Riesgo | Probabilidad | Mitigación |
|--------|-------------|------------|
| Respuesta IA inconsistente (JSON malformado) | Media | Validación estricta + reintentos + fallback a componentes genéricos |
| Parsing incorrecto de PDFs complejos | Alta | Límite de páginas, extracción por bloques, aviso al usuario si el texto es escaso |
| Costos de API IA descontrolados | Media | Límite por usuario + log de consumo + alertas |
| Modelo de horas desactualizado | Baja | Tabla configurable en BD, editable sin redeploy |
| JWT robado | Baja | Refresh token rotation + blacklist en logout |

---

## 8. Decisiones técnicas registradas

| Decisión | Alternativa descartada | Razón |
|----------|------------------------|-------|
| Spring Boot sobre NestJS | NestJS + TypeScript | Tipado fuerte nativo para motor de cálculo, experiencia previa del equipo |
| PostgreSQL sobre MongoDB | MongoDB | El modelo es relacional por naturaleza; los componentes JSON se guardan como JSONB cuando sea necesario |
| JWT stateless sobre sesiones | Spring Session | Facilita escalar horizontalmente sin state compartido |
| Claude API para extracción | GPT-4 / Gemini | Mejor desempeño en tareas de extracción estructurada de texto técnico |
