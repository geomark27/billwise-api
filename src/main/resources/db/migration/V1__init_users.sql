-- ==========================================
-- V1: Esquema inicial — users + refresh_tokens
-- ==========================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TYPE user_role AS ENUM ('SUPERADMIN', 'USER');
CREATE TYPE experience_level AS ENUM ('JUNIOR', 'MID', 'SENIOR');
CREATE TYPE market_target AS ENUM ('LOCAL', 'REGIONAL', 'INTERNATIONAL');

CREATE TABLE users (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email           VARCHAR(255) NOT NULL UNIQUE,
    password_hash   VARCHAR(255) NOT NULL,
    name            VARCHAR(255),
    role            user_role NOT NULL DEFAULT 'USER',
    experience_level experience_level NOT NULL DEFAULT 'MID',
    hourly_rate     DECIMAL(10, 2),
    market_target   market_target NOT NULL DEFAULT 'LOCAL',
    created_at      TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE refresh_tokens (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token       VARCHAR(512) NOT NULL UNIQUE,
    expires_at  TIMESTAMP NOT NULL,
    revoked     BOOLEAN NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_refresh_tokens_token ON refresh_tokens(token);
CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
