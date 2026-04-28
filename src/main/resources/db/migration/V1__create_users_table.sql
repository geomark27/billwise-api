CREATE TABLE users (
    id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email            VARCHAR(255) UNIQUE NOT NULL,
    password_hash    VARCHAR(255) NOT NULL,
    name             VARCHAR(255),
    experience_level VARCHAR(20) CHECK (experience_level IN ('JUNIOR', 'MID', 'SENIOR')),
    hourly_rate      DECIMAL(10, 2),
    market_target    VARCHAR(20) CHECK (market_target IN ('LOCAL', 'REGIONAL', 'INTERNATIONAL')),
    role             VARCHAR(20) NOT NULL DEFAULT 'USER',
    created_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at       TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
