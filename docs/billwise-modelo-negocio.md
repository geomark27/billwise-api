# Billwise — Modelo de Negocio

## 1. Propuesta de valor

**Para el freelancer desarrollador**, Billwise elimina la parte más incómoda e incierta del trabajo independiente: poner precio a un proyecto. En lugar de adivinar o cobrar de más/de menos por miedo, el freelancer obtiene un estimado técnico fundamentado, ajustado a su mercado, que puede defender frente al cliente con argumentos concretos.

**Problema que resuelve:** El 70% de los freelancers cobra por intuición. Resultado: proyectos subvalorados, scope creep sin compensación, y clientes que cuestionan el precio porque no hay desglose que lo respalde.

**Beneficio diferencial:** No es solo un número — es un documento de propuesta completo que incluye el desglose, el scope definido, y la justificación de la complejidad. Eso sube la percepción de profesionalismo del freelancer y reduce las negociaciones a la baja.

---

## 2. Segmento de clientes

### Segmento primario
**Desarrolladores freelance independientes** — junior a mid-level, con 0 a 5 años de experiencia, que trabajan solos y no tienen un proceso de cotización establecido. Mercado objetivo: Latinoamérica apuntando a clientes locales o internacionales.

### Segmento secundario
**Agencias pequeñas (2–5 personas)** — equipos que necesitan estandarizar cómo presentan propuestas a clientes y quieren reducir el tiempo que invierten en cotizar.

### Segmento terciario (largo plazo)
**Desarrolladores senior / consultores** — que ya saben cotizar pero quieren velocidad y consistencia. Para estos, Billwise agrega valor como herramienta de productividad, no como guía.

---

## 3. Canales de adquisición

| Canal | Estrategia | Costo |
|-------|-----------|-------|
| Comunidades de devs | Posts en Reddit (r/freelance, r/webdev), Indie Hackers, Discord communities | $0 — orgánico |
| Redes sociales | Twitter/X y LinkedIn — casos reales de estimados generados | $0 — orgánico |
| SEO | Posts en blog: "cómo cobrar como freelance", "cuánto cobrar por una app" | $0 — largo plazo |
| Product Hunt | Lanzamiento en Product Hunt cuando MVP esté pulido | $0 — evento único |
| Referidos | Programa de referidos con descuento en plan pago | Variable |

### Estrategia de entrada al mercado
**Freemium como tope de embudo.** El plan gratuito es suficiente para que un freelancer lo use una vez y lo comparta. El límite de 5 estimados/mes es el punto de conversión natural — cuando el freelancer encuentra valor real, el upgrade se justifica solo.

---

## 4. Modelo de precios

### Plan Free
- 5 estimados por mes
- Entrada por texto libre únicamente
- Exportación a PDF incluida
- Sin historial (solo los últimos 3 estimados visibles)
- **$0/mes**

### Plan Pro
- Estimados ilimitados
- Entrada por texto, archivo (PDF, DOCX, MD) y formulario guiado
- Historial completo con estados (draft, sent, accepted, rejected)
- Calibración personal (el sistema aprende de tus ediciones)
- Exportación de propuesta con branding personalizable
- **$12/mes** (o $99/año — 31% de descuento)

### Plan Team *(largo plazo — no MVP)*
- Todo lo de Pro para hasta 5 usuarios
- Templates de estimados compartidos
- Analytics de conversión (qué proyectos se aceptan más)
- **$35/mes**

### Justificación del precio Pro
$12/mes es menos de lo que cuesta una hora de trabajo mal cotizada. Si Billwise ayuda al freelancer a no perder una sola hora de trabajo al mes, se paga solo. El precio está deliberadamente por debajo del umbral de "necesito pensarlo".

---

## 5. Fuentes de ingreso

| Fuente | Tipo | Proyección año 1 |
|--------|------|-----------------|
| Suscripciones Pro mensuales | Recurrente | Principal |
| Suscripciones Pro anuales | Recurrente | Con descuento |
| Plan Team (año 2+) | Recurrente | Secundario |

**Meta conservadora año 1:** 200 usuarios Pro × $12/mes = **$2,400/mes** (~$28,800/año).  
**Meta moderada año 1:** 500 usuarios Pro = **$6,000/mes** (~$72,000/año).

Estos números son alcanzables con una comunidad activa pequeña y sin inversión publicitaria, dado el mercado global de freelancers.

---

## 6. Estructura de costos

| Costo | Monto estimado | Frecuencia |
|-------|---------------|------------|
| Railway (backend + DB) | $20 – $50 | Mensual |
| Vercel (frontend) | $0 (plan hobby) → $20 | Mensual |
| Cloudflare R2 (archivos) | $0 – $5 (primeros 10GB gratis) | Mensual |
| Claude API | Variable (~$0.003 por estimado) | Por uso |
| Dominio | $12 – $15 | Anual |
| **Total fijo inicial** | **~$40–75/mes** | Mensual |

**Punto de equilibrio:** Con $75/mes de costos fijos, se necesitan apenas **7 usuarios Pro** para cubrir infraestructura. Todo lo demás es ganancia operativa.

**Costo de IA por usuario Free:** 5 estimados × $0.003 = $0.015/mes por usuario gratuito. Marginal, no amenaza la unidad económica.

---

## 7. Métricas clave (KPIs)

| Métrica | Definición | Meta mes 3 |
|---------|-----------|------------|
| Usuarios registrados | Total de cuentas creadas | 500 |
| DAU / MAU ratio | Engagement (activos diarios / mensuales) | > 15% |
| Free → Pro conversion | % de usuarios Free que pasan a Pro | > 5% |
| Churn mensual | % de Pro que cancelan cada mes | < 8% |
| Estimados por usuario activo | Uso real de la herramienta | > 3/mes |
| NPS | Net Promoter Score | > 40 |

---

## 8. Ventaja competitiva y diferenciadores

| Competidor / alternativa | Debilidad | Ventaja de Billwise |
|--------------------------|-----------|---------------------|
| Spreadsheets manuales | Sin inteligencia, depende del freelancer saberlo todo | IA extrae componentes automáticamente |
| Calculadoras de tarifa genéricas | Solo calculan tarifa/hora, no el proyecto | Analiza el proyecto específico |
| Toggl / Harvest | Trackers de tiempo, no estimadores previos | Trabaja ANTES del proyecto, no durante |
| Agencias con equipo de ventas | No accesible para freelancers independientes | Self-service, sin onboarding |
| Cotizar "por ojo" | Inconsistente, difícil de defender ante el cliente | Desglose técnico exportable |

**Moat a largo plazo:** La calibración personal. Mientras más usa Billwise un freelancer, más precisos se vuelven sus estimados basados en su historial real. Eso crea un costo de cambio genuino — irse a otro tool significa perder ese aprendizaje acumulado.

---

## 9. Hoja de ruta de negocio

### Mes 1–3: Validación
- MVP en producción con plan Free y Pro
- 50 usuarios activos, al menos 10 Pro
- Recolectar feedback activo (formulario en app, entrevistas directas)
- Ajustar motor de estimación con casos reales

### Mes 4–6: Crecimiento orgánico
- Blog con contenido SEO ("cómo cobrar como dev freelance en Ecuador / Latinoamérica")
- Presencia en comunidades de freelancers
- Primer lanzamiento en Product Hunt
- Meta: 200 usuarios, 20+ Pro

### Mes 7–12: Monetización sólida
- Programa de referidos
- Plan anual con descuento
- Explorar Plan Team con primeros clientes agencia
- Meta: 500 usuarios, 50+ Pro, punto de equilibrio superado

### Año 2+: Expansión
- Templates de industria (apps móviles, e-commerce, SaaS, etc.)
- API pública para integraciones
- Versión blanca (white-label) para agencias
- Posible integración con plataformas freelance (Upwork, Workana)
