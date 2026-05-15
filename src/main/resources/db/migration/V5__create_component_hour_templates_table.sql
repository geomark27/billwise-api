CREATE TABLE component_hour_templates
(
    id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type       VARCHAR(100) NOT NULL,
    complexity VARCHAR(10)  NOT NULL CHECK (complexity IN ('LOW', 'MEDIUM', 'HIGH')),
    hours_min  INTEGER      NOT NULL,
    hours_max  INTEGER      NOT NULL,
    UNIQUE (type, complexity)
);

-- Valores iniciales extraídos de la lógica de negocio
INSERT INTO component_hour_templates (type, complexity, hours_min, hours_max)
VALUES ('AUTH', 'LOW', 4, 6),
       ('AUTH', 'MEDIUM', 8, 12),
       ('AUTH', 'HIGH', 14, 20),
       ('CRUD', 'LOW', 2, 4),
       ('CRUD', 'MEDIUM', 5, 8),
       ('CRUD', 'HIGH', 10, 16),
       ('API_INTEGRATION', 'LOW', 4, 8),
       ('API_INTEGRATION', 'MEDIUM', 10, 16),
       ('API_INTEGRATION', 'HIGH', 18, 28),
       ('DASHBOARD', 'LOW', 6, 10),
       ('DASHBOARD', 'MEDIUM', 14, 20),
       ('DASHBOARD', 'HIGH', 22, 35),
       ('ROLES', 'LOW', 6, 10),
       ('ROLES', 'MEDIUM', 12, 18),
       ('ROLES', 'HIGH', 20, 30),
       ('FILE_PROCESSING', 'LOW', 4, 8),
       ('FILE_PROCESSING', 'MEDIUM', 10, 16),
       ('FILE_PROCESSING', 'HIGH', 18, 26),
       ('PWA_OFFLINE', 'LOW', 4, 6),
       ('PWA_OFFLINE', 'MEDIUM', 8, 14),
       ('PWA_OFFLINE', 'HIGH', 16, 24),
       ('INFRASTRUCTURE', 'LOW', 3, 5),
       ('INFRASTRUCTURE', 'MEDIUM', 6, 10),
       ('INFRASTRUCTURE', 'HIGH', 12, 18),
       ('NOTIFICATIONS', 'LOW', 2, 4),
       ('NOTIFICATIONS', 'MEDIUM', 6, 10),
       ('NOTIFICATIONS', 'HIGH', 12, 18),
       ('AI_ENGINE', 'LOW', 8, 14),
       ('AI_ENGINE', 'MEDIUM', 16, 24),
       ('AI_ENGINE', 'HIGH', 28, 40);