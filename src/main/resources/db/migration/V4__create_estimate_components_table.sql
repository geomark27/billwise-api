CREATE TABLE estimate_components
(
    id                UUID PRIMARY KEY      DEFAULT gen_random_uuid(),
    estimate_id       UUID         NOT NULL REFERENCES estimates (id) ON DELETE CASCADE,
    name              VARCHAR(255) NOT NULL,
    description       TEXT,
    type              VARCHAR(100) NOT NULL,
    complexity        VARCHAR(10)  NOT NULL CHECK (complexity IN ('LOW', 'MEDIUM', 'HIGH')),
    ambiguity         VARCHAR(10)  NOT NULL CHECK (ambiguity IN ('LOW', 'MEDIUM', 'HIGH')),
    hours_min         INTEGER      NOT NULL,
    hours_max         INTEGER      NOT NULL,
    hours_used        INTEGER,
    price_min         DECIMAL(12, 2),
    price_max         DECIMAL(12, 2),
    price_recommended DECIMAL(12, 2),
    is_manual         BOOLEAN      NOT NULL DEFAULT FALSE,
    sort_order        INTEGER      NOT NULL DEFAULT 0
);

CREATE INDEX idx_estimate_components_estimate_id ON estimate_components (estimate_id);