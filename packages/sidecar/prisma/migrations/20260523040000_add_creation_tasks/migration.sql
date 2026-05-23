CREATE TABLE "creation_tasks" (
    "id" TEXT NOT NULL,
    "creation_type" TEXT NOT NULL,
    "goal" TEXT NOT NULL,
    "asset_ids" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "status" TEXT NOT NULL,
    "current_step_id" TEXT,
    "summary" TEXT,
    "skill_name" TEXT,
    "steps" JSONB NOT NULL DEFAULT '[]',
    "requirement_items" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "workspace_path" TEXT,
    "error" JSONB,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "creation_tasks_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "creation_events" (
    "id" TEXT NOT NULL,
    "task_id" TEXT NOT NULL,
    "step_id" TEXT,
    "type" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "creation_events_pkey" PRIMARY KEY ("id")
);

CREATE TABLE "creation_artifacts" (
    "id" TEXT NOT NULL,
    "task_id" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "local_path" TEXT,
    "share_id" TEXT,
    "share_url" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "creation_artifacts_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "idx_creation_tasks_status" ON "creation_tasks"("status");
CREATE INDEX "idx_creation_tasks_created_at" ON "creation_tasks"("created_at");
CREATE INDEX "idx_creation_events_task_id" ON "creation_events"("task_id");
CREATE INDEX "idx_creation_events_type" ON "creation_events"("type");
CREATE INDEX "idx_creation_artifacts_task_id" ON "creation_artifacts"("task_id");
CREATE INDEX "idx_creation_artifacts_kind" ON "creation_artifacts"("kind");

ALTER TABLE "creation_events"
  ADD CONSTRAINT "creation_events_task_id_fkey"
  FOREIGN KEY ("task_id") REFERENCES "creation_tasks"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "creation_artifacts"
  ADD CONSTRAINT "creation_artifacts_task_id_fkey"
  FOREIGN KEY ("task_id") REFERENCES "creation_tasks"("id") ON DELETE CASCADE ON UPDATE CASCADE;
