CREATE TABLE ai_usage_log
(
    id                UUID PRIMARY KEY         DEFAULT gen_random_uuid(),
    user_id           UUID         NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    estimate_id       UUID         REFERENCES estimates (id) ON DELETE SET NULL,
    model             VARCHAR(100) NOT NULL,
    prompt_tokens     INTEGER      NOT NULL    DEFAULT 0,
    completion_tokens INTEGER      NOT NULL    DEFAULT 0,
    total_tokens      INTEGER      NOT NULL    DEFAULT 0,
    created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_ai_usage_log_user_id ON ai_usage_log (user_id);