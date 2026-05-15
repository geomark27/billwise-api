CREATE TABLE estimates
(
    id                      UUID PRIMARY KEY         DEFAULT gen_random_uuid(),
    user_id                 UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    title                   VARCHAR(255) NOT NULL,
    raw_input               TEXT,
    input_type              VARCHAR(20)  NOT NULL    DEFAULT 'TEXT'
        CHECK (input_type IN ('TEXT', 'FILE', 'FORM')),
    status                  VARCHAR(20)  NOT NULL    DEFAULT 'DRAFT'
        CHECK (status IN ('DRAFT', 'SENT', 'ACCEPTED', 'REJECTED')),
    total_hours_min         INTEGER,
    total_hours_max         INTEGER,
    total_price_min         DECIMAL(12, 2),
    total_price_max         DECIMAL(12, 2),
    total_price_recommended DECIMAL(12, 2),
    market_multiplier       DECIMAL(4, 2),
    risk_margin             DECIMAL(4, 2),
    created_at              TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at              TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_estimates_user_id ON estimates (user_id);
CREATE INDEX idx_estimates_status ON estimates (status);