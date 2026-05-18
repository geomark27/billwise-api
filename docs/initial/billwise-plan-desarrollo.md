# Billwise — Plan de Desarrollo y Sprints

## Metodología

Sprints de **2 semanas**. Al final de cada sprint debe existir algo funcionando y demostrable, no solo código. El criterio de "done" siempre incluye prueba manual del flujo completo afectado.

Equipo asumido: **1 desarrollador fullstack** (tú). Las horas por sprint son reales, no optimistas.

---

## Visión por fases

| Fase | Objetivo | Resultado |
|------|----------|-----------|
| Fase 1 — Fundación | Backend + auth + DB funcional | API lista para consumirse |
| Fase 2 — Core AI | Motor de estimación con IA | Estimado generado desde texto |
| Fase 3 — Frontend MVP | UI completa del flujo principal | App usable end-to-end |
| Fase 4 — Pulido | Exportación, calibración, historial | Producto listo para primeros usuarios |
| Fase 5 — Go Live | Deploy, monetización, feedback | Versión pública |

---

## Sprint 1 — Fundación del backend
**Duración:** 2 semanas | **Horas estimadas:** 20–28 h

### Objetivos
- Proyecto Spring Boot inicializado con estructura de paquetes definida
- Base de datos PostgreSQL corriendo (local + Railway para staging)
- Migraciones Flyway con esquema inicial
- Módulo de autenticación completo (registro, login, JWT)

### Tareas

**Setup del proyecto**
- [ ] Inicializar proyecto con Spring Initializr (Web, Security, JPA, Flyway, PostgreSQL)
- [ ] Definir estructura de paquetes: `controller`, `service`, `repository`, `model`, `dto`, `config`, `exception`
- [ ] Configurar `application.yml` para perfiles `dev` y `prod`
- [ ] Setup de Flyway con migración V1 (esquema inicial de `users`)

**Autenticación**
- [ ] Entidad `User` + `UserRepository`
- [ ] `AuthController` con endpoints `POST /api/auth/register` y `POST /api/auth/login`
- [ ] `JwtService` — generación y validación de tokens
- [ ] `JwtAuthFilter` — filtro de Spring Security
- [ ] `SecurityConfig` — rutas públicas y protegidas
- [ ] BCrypt para hashing de contraseñas
- [ ] `POST /api/auth/refresh` — refresh token

**Testing**
- [ ] Tests de integración para endpoints de auth con MockMvc
- [ ] Validar que rutas protegidas retornan 401 sin token

### Criterio de done
Puedo registrarme, hacer login y recibir un JWT. Con ese JWT puedo acceder a un endpoint protegido de prueba. Sin JWT, recibo 401.

---

## Sprint 2 — Modelo de datos y módulo de estimados
**Duración:** 2 semanas | **Horas estimadas:** 22–30 h

### Objetivos
- Esquema completo de base de datos implementado
- CRUD de estimados funcional
- Endpoint para crear estimado desde texto (sin IA aún — componentes hardcodeados de prueba)

### Tareas

**Migraciones Flyway**
- [ ] V2: tabla `estimates`
- [ ] V3: tabla `estimate_components`
- [ ] V4: tabla `user_calibrations`
- [ ] V5: tabla `uploaded_files`
- [ ] V6: tabla `ai_usage_log`

**Estimate Module**
- [ ] Entidades JPA: `Estimate`, `EstimateComponent`, `UploadedFile`
- [ ] Repositorios con queries custom (listado por usuario, filtros por estado)
- [ ] `EstimateService` — lógica de negocio del módulo
- [ ] `EstimateController`:
  - `POST /api/estimates` — crear desde texto
  - `GET /api/estimates` — listar del usuario autenticado
  - `GET /api/estimates/{id}` — detalle
  - `PATCH /api/estimates/{id}` — actualizar estado
  - `PUT /api/estimates/{id}/components/{cid}` — editar componente

**Motor de cálculo (sin IA)**
- [ ] `PriceCalculatorService` — implementar fórmula core
- [ ] Lógica de multiplicadores de mercado
- [ ] Lógica de margen de riesgo por ambigüedad
- [ ] Cálculo de rango min/max y precio recomendado

**Validaciones**
- [ ] DTOs con Bean Validation (`@NotBlank`, `@Min`, etc.)
- [ ] `GlobalExceptionHandler` con respuestas de error estandarizadas

### Criterio de done
Puedo crear un estimado enviando texto + lista de componentes manualmente y recibir el precio calculado correctamente. El listado muestra solo mis estimados.

---

## Sprint 3 — Integración con Claude API
**Duración:** 2 semanas | **Horas estimadas:** 24–32 h

### Objetivos
- `AIService` funcional que extrae componentes desde texto usando Claude
- Prompts versionados y testeados con casos reales
- Flujo completo: texto → IA → componentes → precio

### Tareas

**AI Service Layer**
- [ ] Configurar `WebClient` para llamadas HTTP a Claude API
- [ ] `ClaudeApiClient` — wrapper del cliente con manejo de errores y reintentos
- [ ] `AIService` — orquesta llamada + parseo de respuesta
- [ ] Diseñar y versionar el system prompt de extracción
- [ ] `ComponentDTO` — DTO de respuesta de la IA
- [ ] Parseo de JSON con Jackson + validación de estructura
- [ ] Manejo de reintentos (máximo 2) con backoff exponencial

**Ingeniería de prompts**
- [ ] Prompt v1: extracción de componentes básica
- [ ] Testar con mínimo 5 casos reales (incluyendo el caso DixlyApp)
- [ ] Ajustar prompt hasta lograr JSON consistente
- [ ] Documentar prompt en archivo versionado (`prompts/component-extraction-v1.txt`)

**Logging de uso**
- [ ] `AiUsageLog` entidad + repositorio
- [ ] Guardar tokens consumidos, modelo usado, timestamp por cada llamada
- [ ] `UsageLimitService` — verificar límite mensual del usuario (plan gratuito: 5/mes)

**Integración con Estimate Module**
- [ ] `POST /api/estimates` ahora llama al AI Service cuando `input_type = TEXT`
- [ ] Los componentes extraídos se persisten en `estimate_components`
- [ ] El motor de cálculo corre sobre los componentes extraídos automáticamente

### Criterio de done
Envío el texto del proyecto DixlyApp y recibo un estimado desglosado con componentes identificados por la IA y precio calculado. El flujo completo corre en menos de 15 segundos.

---

## Sprint 4 — Procesamiento de archivos
**Duración:** 2 semanas | **Horas estimadas:** 18–24 h

### Objetivos
- Upload de archivos PDF y DOCX funcional
- Extracción de texto y procesamiento con el mismo pipeline de IA
- Almacenamiento en S3 / Cloudflare R2

### Tareas

**File Parser**
- [ ] Dependencias: Apache PDFBox, Apache POI
- [ ] `FileParserService` — detecta tipo MIME y delega al parser correcto
- [ ] `PdfParser` — extrae texto plano de PDF
- [ ] `DocxParser` — extrae texto plano de DOCX
- [ ] `MarkdownParser` — limpieza básica de MD
- [ ] Límite: máximo 10MB, máximo 30 páginas para PDF

**Storage**
- [ ] Configurar cliente AWS S3 (o R2 con SDK compatible)
- [ ] `StorageService` — upload, generación de URL prefirmada, delete
- [ ] Guardar referencia en `uploaded_files`

**Endpoint de upload**
- [ ] `POST /api/estimates/upload` — recibe `multipart/form-data`
- [ ] Validación de tipo MIME en backend (no confiar en extensión)
- [ ] Flujo: upload → parse → texto → AI → componentes → precio

### Criterio de done
Subo un PDF con documentación de un proyecto y recibo el estimado. El archivo queda guardado y referenciado en el estimado.

---

## Sprint 5 — Frontend: autenticación y flujo principal
**Duración:** 2 semanas | **Horas estimadas:** 24–30 h

### Objetivos
- Proyecto Next.js 14 inicializado
- Auth completa en el frontend (login, registro, protección de rutas)
- Flujo de creación de estimado desde texto funcional end-to-end

### Tareas

**Setup del proyecto**
- [ ] Next.js 14 con App Router + TypeScript
- [ ] Tailwind CSS + configuración de tema
- [ ] `axios` o `fetch` wrapper con interceptor para JWT
- [ ] Middleware de Next.js para proteger rutas autenticadas
- [ ] Variables de entorno para la URL del backend

**Páginas de autenticación**
- [ ] `/login` — formulario de login
- [ ] `/register` — formulario de registro
- [ ] Manejo de tokens en `httpOnly cookies` o `localStorage` (decisión: cookies por seguridad)
- [ ] Redirect automático si no autenticado

**Dashboard**
- [ ] `/dashboard` — listado de estimados del usuario
- [ ] Estado de cada estimado (draft, sent, accepted, rejected)
- [ ] CTA para crear nuevo estimado

**Flujo de creación — texto**
- [ ] `/estimates/new` — selector de tipo de entrada (texto / archivo / formulario)
- [ ] Textarea para texto libre con contador de caracteres
- [ ] Loading state mientras la IA procesa
- [ ] Redirect a vista de resultados al completar

**Vista de resultados**
- [ ] `/estimates/{id}` — desglose completo del estimado
- [ ] Cards por componente con horas y precio
- [ ] Resumen ejecutivo (mínimo / recomendado / máximo)
- [ ] Posibilidad de editar horas por componente

### Criterio de done
Puedo registrarme, ingresar texto de un proyecto, ver el estimado desglosado y editar componentes. Todo desde el browser, comunicándose con el backend real.

---

## Sprint 6 — Frontend: upload, configuración y exportación
**Duración:** 2 semanas | **Horas estimadas:** 20–26 h

### Objetivos
- Upload de archivos en el frontend
- Panel de configuración de perfil (tarifa, mercado)
- Exportación del estimado a PDF

### Tareas

**Upload de archivos**
- [ ] Componente drag & drop para subir archivos
- [ ] Validación de tipo y tamaño en cliente
- [ ] Barra de progreso durante upload
- [ ] Mismo flujo de resultados que texto

**Perfil y configuración**
- [ ] `/settings` — editar tarifa hora, nivel de experiencia, mercado objetivo
- [ ] Los cambios se reflejan en estimados futuros (no retroactivos)
- [ ] Indicador de plan actual y uso mensual de IA

**Exportación PDF**
- [ ] Botón "Exportar propuesta" en vista de estimado
- [ ] Llama a `GET /api/estimates/{id}/export`
- [ ] Descarga el PDF automáticamente

**Historial y filtros**
- [ ] Filtrar estimados por estado en el dashboard
- [ ] Buscar por título o fecha

### Criterio de done
El flujo completo de Billwise funciona: entro, configuro mi perfil, subo un documento, veo el estimado, lo edito, y descargo la propuesta en PDF.

---

## Sprint 7 — Pulido, deploy y preparación para usuarios
**Duración:** 2 semanas | **Horas estimadas:** 16–22 h

### Objetivos
- Deploy en producción funcional
- Performance y edge cases cubiertos
- Preparación para primeros usuarios reales

### Tareas

**Deploy**
- [ ] Backend en Railway (variables de entorno configuradas)
- [ ] PostgreSQL en Railway (o Supabase)
- [ ] Frontend en Vercel con variables de entorno
- [ ] Dominio personalizado configurado
- [ ] HTTPS en ambos servicios

**Performance y errores**
- [ ] Manejo de errores en frontend (toasts, estados vacíos, errores de red)
- [ ] Timeout handling en llamadas a IA (máximo 30s)
- [ ] Paginación en listado de estimados
- [ ] Lazy loading de componentes pesados

**Monitoring básico**
- [ ] Logs estructurados en backend (Logback JSON)
- [ ] Alertas básicas de error en Railway
- [ ] Sentry en frontend para errores JS

**Calibración personal**
- [ ] `CalibrationService` corriendo async al editar componentes
- [ ] Influencia sutil en estimados futuros del mismo tipo

### Criterio de done
Billwise está en producción. Un usuario externo puede registrarse, crear un estimado y descargar su propuesta sin intervención mía.

---

## Resumen de tiempos

| Sprint | Semanas | Horas estimadas |
|--------|---------|-----------------|
| 1 — Fundación backend | 2 | 20–28 h |
| 2 — Modelo de datos + CRUD | 2 | 22–30 h |
| 3 — Integración Claude API | 2 | 24–32 h |
| 4 — Procesamiento de archivos | 2 | 18–24 h |
| 5 — Frontend auth + flujo principal | 2 | 24–30 h |
| 6 — Frontend upload + export + config | 2 | 20–26 h |
| 7 — Pulido + deploy | 2 | 16–22 h |
| **Total** | **14 semanas** | **144–192 h** |

**Punto medio:** ~168 horas a lo largo de ~3.5 meses trabajando part-time (15h/semana) o ~2 meses a tiempo completo.
