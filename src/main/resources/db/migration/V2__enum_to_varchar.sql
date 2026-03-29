-- ==========================================
-- V2: Convertir enums nativos de PostgreSQL a VARCHAR
--     para compatibilidad con Hibernate @Enumerated(EnumType.STRING)
-- ==========================================

-- 1. Quitar defaults que referencian los tipos enum
ALTER TABLE users ALTER COLUMN role DROP DEFAULT;
ALTER TABLE users ALTER COLUMN experience_level DROP DEFAULT;
ALTER TABLE users ALTER COLUMN market_target DROP DEFAULT;

-- 2. Convertir columnas a VARCHAR
ALTER TABLE users ALTER COLUMN role TYPE VARCHAR(50) USING role::VARCHAR;
ALTER TABLE users ALTER COLUMN experience_level TYPE VARCHAR(50) USING experience_level::VARCHAR;
ALTER TABLE users ALTER COLUMN market_target TYPE VARCHAR(50) USING market_target::VARCHAR;

-- 3. Restaurar defaults como literales VARCHAR
ALTER TABLE users ALTER COLUMN role SET DEFAULT 'USER';
ALTER TABLE users ALTER COLUMN experience_level SET DEFAULT 'MID';
ALTER TABLE users ALTER COLUMN market_target SET DEFAULT 'LOCAL';

-- 4. Ahora ya se pueden eliminar los tipos
DROP TYPE user_role;
DROP TYPE experience_level;
DROP TYPE market_target;

-- 5. Check constraints para mantener integridad
ALTER TABLE users ADD CONSTRAINT chk_role
    CHECK (role IN ('SUPERADMIN', 'USER'));
ALTER TABLE users ADD CONSTRAINT chk_experience_level
    CHECK (experience_level IN ('JUNIOR', 'MID', 'SENIOR'));
ALTER TABLE users ADD CONSTRAINT chk_market_target
    CHECK (market_target IN ('LOCAL', 'REGIONAL', 'INTERNATIONAL'));
