# Billwise — Lógica de Negocio

## 1. Propósito del sistema

Billwise es una herramienta SaaS orientada a desarrolladores freelance que convierte la descripción o documentación de un proyecto de software en un estimado económico fundamentado, ajustado al mercado del usuario. El objetivo es eliminar la subjetividad del proceso de cotización y darle al freelancer un argumento técnico respaldado por datos para sostener su precio.

---

## 2. Actor principal

**El freelancer desarrollador** — persona independiente con conocimiento técnico que necesita cotizar proyectos de software para clientes. Puede ser junior, mid-level o senior. La app no asume experiencia en gestión comercial.

---

## 3. Entradas del sistema

El sistema acepta tres formas de entrada, procesadas de forma equivalente:

| Tipo | Descripción | Ejemplo |
|------|-------------|---------|
| Texto libre | Descripción informal del proyecto | Mensaje de WhatsApp, email del cliente |
| Documento estructurado | PRD, brief técnico, AGENTS.md, README | Archivos `.md`, `.txt`, `.pdf`, `.docx` |
| Formulario guiado | Lista de funcionalidades con parámetros | UI interactiva con checkboxes y campos |

---

## 4. Pipeline de procesamiento

```
Entrada → Extracción de componentes → Estimación de horas → Ajuste de mercado → Estimado final
```

### 4.1 Extracción de componentes (IA)

El LLM (Claude API) analiza la entrada y extrae una lista de componentes técnicos identificados. Cada componente tiene:

- `nombre`: identificador del componente
- `descripcion`: qué hace o implica
- `tipo`: categoría (auth, CRUD, integración, UI, infraestructura, etc.)
- `complejidad`: `LOW | MEDIUM | HIGH`
- `ambiguedad`: `LOW | MEDIUM | HIGH` — qué tan bien definido está el requisito

**Regla de ambigüedad:** si un componente tiene ambigüedad `HIGH`, su estimado de horas se infla automáticamente en un 20% como margen de riesgo.

### 4.2 Estimación de horas

Cada componente se mapea a un rango de horas `[min, max]` según su tipo y complejidad. Esta tabla es configurable por el administrador del sistema y ajustable por el usuario.

| Tipo | LOW | MEDIUM | HIGH |
|------|-----|--------|------|
| Autenticación básica | 4–6 h | 8–12 h | 14–20 h |
| CRUD simple | 2–4 h | 5–8 h | 10–16 h |
| Integración API externa | 4–8 h | 10–16 h | 18–28 h |
| Dashboard / reportes | 6–10 h | 14–20 h | 22–35 h |
| Sistema de roles | 6–10 h | 12–18 h | 20–30 h |
| Procesamiento de archivos | 4–8 h | 10–16 h | 18–26 h |
| PWA / offline | 4–6 h | 8–14 h | 16–24 h |
| Infraestructura / deploy | 3–5 h | 6–10 h | 12–18 h |
| Notificaciones | 2–4 h | 6–10 h | 12–18 h |
| Motor de IA / prompts | 8–14 h | 16–24 h | 28–40 h |

**Punto central:** el sistema trabaja con el valor medio `(min + max) / 2` como base de cálculo. El rango completo se muestra al usuario para transparencia.

### 4.3 Ajuste de mercado

La tarifa base se ajusta mediante dos parámetros configurables por el usuario:

**Mercado objetivo** — a quién le cobra el freelancer:

| Mercado | Multiplicador |
|---------|--------------|
| Local (mismo país) | 1.0× |
| Regional (Latinoamérica) | 1.3× |
| Internacional (EE.UU. / Europa) | 2.0× |

**Tarifa hora base** — ingresada manualmente por el usuario en su perfil (USD). Valor sugerido según experiencia:

| Nivel | Rango sugerido |
|-------|----------------|
| Junior (< 2 años) | $10 – $18/h |
| Mid-level (2–5 años) | $20 – $35/h |
| Senior (5+ años) | $35 – $60/h |

### 4.4 Fórmula de cálculo

```
precio_componente = horas_medias × tarifa_hora × multiplicador_mercado × (1 + margen_riesgo)

precio_total = Σ(precio_componente) para todos los componentes identificados
```

Donde `margen_riesgo` es:
- `0.0` si ambigüedad general es LOW
- `0.10` si ambigüedad general es MEDIUM
- `0.20` si ambigüedad general es HIGH

---

## 5. Salida del sistema

El estimado generado incluye:

1. **Resumen ejecutivo** — precio mínimo, precio recomendado, precio máximo
2. **Desglose por componente** — horas y costo por cada ítem identificado
3. **Justificación de complejidad** — por qué cada componente tiene la complejidad asignada
4. **Notas de alcance (scope)** — qué está incluido y qué queda explícitamente fuera
5. **Recomendación de modalidad de cobro** — precio fijo vs por hora, con justificación

---

## 6. Reglas de negocio críticas

- **Nunca se muestra un precio sin desglose.** El usuario siempre ve de dónde viene el número.
- **El usuario puede editar cualquier componente.** Si el LLM se equivoca al identificar algo, el freelancer puede corregir horas, complejidad o eliminar/añadir ítems manualmente.
- **El sistema aprende de las ediciones.** Cuando el usuario ajusta un estimado, esa corrección alimenta el perfil de calibración personal (no un modelo global).
- **Los estimados se guardan con estado.** Un estimado puede ser `borrador`, `enviado al cliente`, `aceptado`, `rechazado`. Esto permite análisis histórico.
- **El scope generado es exportable.** El freelancer puede descargar un PDF listo para enviar al cliente como parte de la propuesta.

---

## 7. Restricciones del sistema

- El sistema **no** reemplaza la negociación — solo provee una base argumentada.
- El sistema **no** garantiza que el cliente acepte el precio — es una herramienta de fundamentación.
- Los multiplicadores de mercado son referencias, no datos en tiempo real. En versiones futuras se pueden alimentar con datos de plataformas como Upwork o Glassdoor.
