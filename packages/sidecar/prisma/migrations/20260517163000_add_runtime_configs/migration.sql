CREATE TABLE "runtime_configs" (
    "key" TEXT NOT NULL,
    "value" JSONB NOT NULL,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "runtime_configs_pkey" PRIMARY KEY ("key")
);
