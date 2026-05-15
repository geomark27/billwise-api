CREATE TABLE user_calibrations
(
    id             UUID PRIMARY KEY         DEFAULT gen_random_uuid(),
    user_id        UUID          NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    component_type VARCHAR(100)  NOT NULL,
    complexity     VARCHAR(10)   NOT NULL CHECK (complexity IN ('LOW', 'MEDIUM', 'HIGH')),
    avg_hours      DECIMAL(6, 2) NOT NULL,
    sample_count   INTEGER       NOT NULL   DEFAULT 1,
    updated_at     TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE (user_id, component_type, complexity)
);