-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- Required by Unsupported("vector(1536)") columns in the Prisma schema.
CREATE EXTENSION IF NOT EXISTS vector;

-- CreateTable
CREATE TABLE "children" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "birthday" DATE,
    "notes" TEXT,
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "children_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "assets" (
    "id" TEXT NOT NULL,
    "child_id" TEXT,
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL DEFAULT '',
    "tags" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "image_path" TEXT,
    "thumbnail_path" TEXT,
    "source_url" TEXT,
    "license" TEXT NOT NULL,
    "hash" TEXT,
    "content_type" TEXT,
    "size_bytes" BIGINT,
    "original_filename" TEXT,
    "original_path" TEXT,
    "storage_provider" TEXT NOT NULL DEFAULT 'local',
    "storage_status" TEXT NOT NULL DEFAULT 'local_only',
    "storage_path" TEXT,
    "remote_url" TEXT,
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "metadata_embedding" vector(1536),
    "embedding_status" TEXT NOT NULL DEFAULT 'pending',
    "embedding_version" INTEGER NOT NULL DEFAULT 0,
    "searchable" BOOLEAN NOT NULL DEFAULT false,
    "embedding_updated_at" TIMESTAMPTZ(6),
    "last_embedding_error_code" TEXT,
    "last_embedding_error_message" TEXT,
    "captured_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "assets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "asset_embeddings" (
    "asset_id" TEXT NOT NULL,
    "embedding" vector(1536),
    "embedding_data" JSONB,
    "model" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "asset_embeddings_pkey" PRIMARY KEY ("asset_id")
);

-- CreateTable
CREATE TABLE "books" (
    "id" TEXT NOT NULL,
    "child_id" TEXT,
    "title" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "html_path" TEXT,
    "pdf_path" TEXT,
    "metadata" JSONB NOT NULL DEFAULT '{}',
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "books_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "book_pages" (
    "id" TEXT NOT NULL,
    "book_id" TEXT NOT NULL,
    "page_index" INTEGER NOT NULL,
    "kind" TEXT NOT NULL,
    "asset_id" TEXT,
    "title" TEXT NOT NULL,
    "body" TEXT NOT NULL DEFAULT '',
    "metadata" JSONB NOT NULL DEFAULT '{}',

    CONSTRAINT "book_pages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agent_jobs" (
    "id" TEXT NOT NULL,
    "child_id" TEXT,
    "status" TEXT NOT NULL,
    "runner" TEXT NOT NULL,
    "workspace_path" TEXT,
    "selected_asset_ids" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "error_message" TEXT,
    "book_id" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "agent_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "embedding_jobs" (
    "id" TEXT NOT NULL,
    "asset_id" TEXT NOT NULL,
    "metadata_version" INTEGER NOT NULL,
    "status" TEXT NOT NULL,
    "attempt" INTEGER NOT NULL DEFAULT 0,
    "max_attempts" INTEGER NOT NULL DEFAULT 5,
    "run_after" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "locked_by" TEXT,
    "locked_at" TIMESTAMPTZ(6),
    "source_query" TEXT,
    "last_error_code" TEXT,
    "last_error_message" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "embedding_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "candidate_pool_items" (
    "child_id" TEXT NOT NULL,
    "asset_id" TEXT NOT NULL,
    "source_query" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "candidate_pool_items_pkey" PRIMARY KEY ("child_id","asset_id")
);

-- CreateTable
CREATE TABLE "storage_sync_jobs" (
    "id" TEXT NOT NULL,
    "target_type" TEXT NOT NULL,
    "target_id" TEXT NOT NULL,
    "provider" TEXT NOT NULL DEFAULT 'supabase',
    "object_path" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "attempt" INTEGER NOT NULL DEFAULT 0,
    "max_attempts" INTEGER NOT NULL DEFAULT 5,
    "run_after" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "locked_by" TEXT,
    "locked_at" TIMESTAMPTZ(6),
    "last_error_code" TEXT,
    "last_error_message" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "storage_sync_jobs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "export_artifacts" (
    "id" TEXT NOT NULL,
    "job_id" TEXT NOT NULL,
    "kind" TEXT NOT NULL,
    "local_path" TEXT NOT NULL,
    "storage_provider" TEXT NOT NULL DEFAULT 'local',
    "storage_status" TEXT NOT NULL DEFAULT 'local_only',
    "storage_path" TEXT,
    "remote_url" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "export_artifacts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "web_companion_upload_sessions" (
    "id" TEXT NOT NULL,
    "child_id" TEXT NOT NULL,
    "token_hash" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "max_items" INTEGER NOT NULL DEFAULT 200,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "closed_at" TIMESTAMPTZ(6),
    "last_seen_at" TIMESTAMPTZ(6),

    CONSTRAINT "web_companion_upload_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "web_companion_upload_items" (
    "id" TEXT NOT NULL,
    "session_id" TEXT NOT NULL,
    "asset_id" TEXT NOT NULL,
    "client_file_id" TEXT,
    "original_filename" TEXT NOT NULL,
    "safe_filename" TEXT NOT NULL,
    "content_type" TEXT NOT NULL,
    "size_bytes" BIGINT NOT NULL,
    "provider" TEXT NOT NULL,
    "bucket" TEXT,
    "object_key" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "remote_etag" TEXT,
    "local_path" TEXT,
    "hash_sha256" TEXT,
    "error_code" TEXT,
    "error_message" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "committed_at" TIMESTAMPTZ(6),
    "ready_at" TIMESTAMPTZ(6),

    CONSTRAINT "web_companion_upload_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "share_tokens" (
    "id" TEXT NOT NULL,
    "token_hash" TEXT NOT NULL,
    "child_id" TEXT NOT NULL,
    "created_by_session" TEXT,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "access_type" TEXT NOT NULL,
    "resource_type" TEXT NOT NULL,
    "resource_id" TEXT,
    "access_count" INTEGER NOT NULL DEFAULT 0,
    "max_access_count" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_accessed_at" TIMESTAMPTZ(6),
    "status" TEXT NOT NULL DEFAULT 'active',
    "metadata" JSONB NOT NULL DEFAULT '{}',

    CONSTRAINT "share_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "share_access_logs" (
    "id" TEXT NOT NULL,
    "share_token_id" TEXT NOT NULL,
    "client_ip" INET,
    "user_agent" TEXT,
    "access_result" TEXT NOT NULL,
    "resource_accessed" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "metadata" JSONB NOT NULL DEFAULT '{}',

    CONSTRAINT "share_access_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "direct_upload_pullbacks" (
    "id" TEXT NOT NULL,
    "session_id" TEXT NOT NULL,
    "child_id" TEXT NOT NULL,
    "object_key" TEXT NOT NULL,
    "remote_size_bytes" BIGINT,
    "remote_content_type" TEXT,
    "remote_last_modified" TIMESTAMPTZ(6),
    "asset_id" TEXT,
    "local_path" TEXT,
    "status" TEXT NOT NULL,
    "error_code" TEXT,
    "error_message" TEXT,
    "pulled_at" TIMESTAMPTZ(6),
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "direct_upload_pullbacks_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lan_sessions" (
    "id" TEXT NOT NULL,
    "device_id" TEXT NOT NULL,
    "child_id" TEXT NOT NULL,
    "token_hash" TEXT NOT NULL,
    "expires_at" TIMESTAMPTZ(6) NOT NULL,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_seen_at" TIMESTAMPTZ(6),
    "max_concurrent_uploads" INTEGER NOT NULL DEFAULT 3,
    "current_uploads" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "lan_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "lan_uploads" (
    "id" TEXT NOT NULL,
    "session_id" TEXT NOT NULL,
    "asset_id" TEXT,
    "filename" TEXT NOT NULL,
    "content_type" TEXT NOT NULL,
    "size_bytes" BIGINT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'processing',
    "local_path" TEXT,
    "hash_sha256" TEXT,
    "error_code" TEXT,
    "error_message" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completed_at" TIMESTAMPTZ(6),

    CONSTRAINT "lan_uploads_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agent_configs" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "provider" TEXT NOT NULL,
    "model" TEXT NOT NULL,
    "base_url" TEXT,
    "api_key_encrypted" TEXT NOT NULL,
    "temperature" DECIMAL(3,2) NOT NULL DEFAULT 0.7,
    "max_tokens" INTEGER NOT NULL DEFAULT 4000,
    "system_prompt" TEXT,
    "tools_enabled" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "workspace_config" JSONB NOT NULL DEFAULT '{}',
    "is_default" BOOLEAN NOT NULL DEFAULT false,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "last_tested_at" TIMESTAMPTZ(6),
    "test_result" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "metadata" JSONB NOT NULL DEFAULT '{}',

    CONSTRAINT "agent_configs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agent_runs" (
    "id" TEXT NOT NULL,
    "agent_config_id" TEXT NOT NULL,
    "child_id" TEXT NOT NULL,
    "book_id" TEXT,
    "input_assets" TEXT[] DEFAULT ARRAY[]::TEXT[],
    "instructions" TEXT,
    "status" TEXT NOT NULL DEFAULT 'pending',
    "started_at" TIMESTAMPTZ(6),
    "completed_at" TIMESTAMPTZ(6),
    "error_message" TEXT,
    "output_book_json" JSONB,
    "output_book_html" TEXT,
    "tokens_used" INTEGER,
    "duration_ms" INTEGER,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "metadata" JSONB NOT NULL DEFAULT '{}',

    CONSTRAINT "agent_runs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "backup_snapshots" (
    "id" TEXT NOT NULL,
    "manifest" JSONB NOT NULL,
    "archive_path" TEXT,
    "created_at" TIMESTAMPTZ(6) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "metadata" JSONB NOT NULL DEFAULT '{}',

    CONSTRAINT "backup_snapshots_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "idx_assets_child_embedding_status" ON "assets"("child_id", "embedding_status", "searchable");

-- CreateIndex
CREATE INDEX "idx_assets_child_captured_at" ON "assets"("child_id", "captured_at");

-- CreateIndex
CREATE INDEX "idx_assets_child_id" ON "assets"("child_id");

-- CreateIndex
CREATE INDEX "idx_assets_type" ON "assets"("type");

-- CreateIndex
CREATE INDEX "idx_assets_storage_status" ON "assets"("storage_status");

-- CreateIndex
CREATE INDEX "idx_assets_embedding_status" ON "assets"("embedding_status");

-- CreateIndex
CREATE INDEX "idx_assets_updated_at" ON "assets"("updated_at");

-- CreateIndex
CREATE INDEX "idx_assets_child_type" ON "assets"("child_id", "type");

-- CreateIndex
CREATE INDEX "idx_embedding_jobs_status_run_after" ON "embedding_jobs"("status", "run_after");

-- CreateIndex
CREATE INDEX "idx_embedding_jobs_locked_at" ON "embedding_jobs"("locked_at");

-- CreateIndex
CREATE INDEX "idx_embedding_jobs_asset_id" ON "embedding_jobs"("asset_id");

-- CreateIndex
CREATE INDEX "idx_embedding_jobs_status" ON "embedding_jobs"("status");

-- CreateIndex
CREATE INDEX "idx_embedding_jobs_created_at" ON "embedding_jobs"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "embedding_jobs_asset_id_metadata_version_key" ON "embedding_jobs"("asset_id", "metadata_version");

-- CreateIndex
CREATE INDEX "idx_storage_sync_jobs_status_run_after" ON "storage_sync_jobs"("status", "run_after");

-- CreateIndex
CREATE INDEX "idx_storage_sync_jobs_locked_at" ON "storage_sync_jobs"("locked_at");

-- CreateIndex
CREATE INDEX "idx_storage_sync_jobs_target_type_id" ON "storage_sync_jobs"("target_type", "target_id");

-- CreateIndex
CREATE INDEX "idx_storage_sync_jobs_status" ON "storage_sync_jobs"("status");

-- CreateIndex
CREATE INDEX "idx_storage_sync_jobs_created_at" ON "storage_sync_jobs"("created_at");

-- CreateIndex
CREATE UNIQUE INDEX "storage_sync_jobs_target_type_target_id_provider_object_pat_key" ON "storage_sync_jobs"("target_type", "target_id", "provider", "object_path");

-- CreateIndex
CREATE INDEX "idx_export_artifacts_job_id" ON "export_artifacts"("job_id");

-- CreateIndex
CREATE INDEX "idx_export_artifacts_kind" ON "export_artifacts"("kind");

-- CreateIndex
CREATE INDEX "idx_upload_items_session_status" ON "web_companion_upload_items"("session_id", "status");

-- CreateIndex
CREATE INDEX "idx_upload_items_asset_id" ON "web_companion_upload_items"("asset_id");

-- CreateIndex
CREATE UNIQUE INDEX "web_companion_upload_items_session_id_client_file_id_key" ON "web_companion_upload_items"("session_id", "client_file_id");

-- CreateIndex
CREATE UNIQUE INDEX "share_tokens_token_hash_key" ON "share_tokens"("token_hash");

-- CreateIndex
CREATE INDEX "idx_share_tokens_token_hash" ON "share_tokens"("token_hash");

-- CreateIndex
CREATE INDEX "idx_share_tokens_child_id" ON "share_tokens"("child_id");

-- CreateIndex
CREATE INDEX "idx_share_tokens_expires_at" ON "share_tokens"("expires_at");

-- CreateIndex
CREATE INDEX "idx_share_tokens_status" ON "share_tokens"("status");

-- CreateIndex
CREATE INDEX "idx_share_access_logs_share_token_id" ON "share_access_logs"("share_token_id");

-- CreateIndex
CREATE INDEX "idx_share_access_logs_created_at" ON "share_access_logs"("created_at");

-- CreateIndex
CREATE INDEX "idx_direct_upload_pullbacks_session_id" ON "direct_upload_pullbacks"("session_id");

-- CreateIndex
CREATE INDEX "idx_direct_upload_pullbacks_child_id" ON "direct_upload_pullbacks"("child_id");

-- CreateIndex
CREATE INDEX "idx_direct_upload_pullbacks_status" ON "direct_upload_pullbacks"("status");

-- CreateIndex
CREATE INDEX "idx_direct_upload_pullbacks_updated_at" ON "direct_upload_pullbacks"("updated_at");

-- CreateIndex
CREATE UNIQUE INDEX "direct_upload_pullbacks_session_id_object_key_key" ON "direct_upload_pullbacks"("session_id", "object_key");

-- CreateIndex
CREATE INDEX "idx_lan_sessions_device_id" ON "lan_sessions"("device_id");

-- CreateIndex
CREATE INDEX "idx_lan_sessions_child_id" ON "lan_sessions"("child_id");

-- CreateIndex
CREATE INDEX "idx_lan_sessions_expires_at" ON "lan_sessions"("expires_at");

-- CreateIndex
CREATE INDEX "idx_lan_sessions_created_at" ON "lan_sessions"("created_at");

-- CreateIndex
CREATE INDEX "idx_lan_uploads_session_id" ON "lan_uploads"("session_id");

-- CreateIndex
CREATE INDEX "idx_lan_uploads_status" ON "lan_uploads"("status");

-- CreateIndex
CREATE INDEX "idx_lan_uploads_created_at" ON "lan_uploads"("created_at");

-- CreateIndex
CREATE INDEX "idx_lan_uploads_asset_id" ON "lan_uploads"("asset_id");

-- CreateIndex
CREATE INDEX "idx_agent_configs_provider" ON "agent_configs"("provider");

-- CreateIndex
CREATE INDEX "idx_agent_configs_is_active" ON "agent_configs"("is_active");

-- CreateIndex
CREATE INDEX "idx_agent_runs_agent_config_id" ON "agent_runs"("agent_config_id");

-- CreateIndex
CREATE INDEX "idx_agent_runs_child_id" ON "agent_runs"("child_id");

-- CreateIndex
CREATE INDEX "idx_agent_runs_status" ON "agent_runs"("status");

-- CreateIndex
CREATE INDEX "idx_agent_runs_created_at" ON "agent_runs"("created_at");

-- AddForeignKey
ALTER TABLE "assets" ADD CONSTRAINT "assets_child_id_fkey" FOREIGN KEY ("child_id") REFERENCES "children"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "asset_embeddings" ADD CONSTRAINT "asset_embeddings_asset_id_fkey" FOREIGN KEY ("asset_id") REFERENCES "assets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "books" ADD CONSTRAINT "books_child_id_fkey" FOREIGN KEY ("child_id") REFERENCES "children"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "book_pages" ADD CONSTRAINT "book_pages_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "books"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "book_pages" ADD CONSTRAINT "book_pages_asset_id_fkey" FOREIGN KEY ("asset_id") REFERENCES "assets"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agent_jobs" ADD CONSTRAINT "agent_jobs_book_id_fkey" FOREIGN KEY ("book_id") REFERENCES "books"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "embedding_jobs" ADD CONSTRAINT "embedding_jobs_asset_id_fkey" FOREIGN KEY ("asset_id") REFERENCES "assets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "candidate_pool_items" ADD CONSTRAINT "candidate_pool_items_child_id_fkey" FOREIGN KEY ("child_id") REFERENCES "children"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "candidate_pool_items" ADD CONSTRAINT "candidate_pool_items_asset_id_fkey" FOREIGN KEY ("asset_id") REFERENCES "assets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "web_companion_upload_sessions" ADD CONSTRAINT "web_companion_upload_sessions_child_id_fkey" FOREIGN KEY ("child_id") REFERENCES "children"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "web_companion_upload_items" ADD CONSTRAINT "web_companion_upload_items_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "web_companion_upload_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "web_companion_upload_items" ADD CONSTRAINT "web_companion_upload_items_asset_id_fkey" FOREIGN KEY ("asset_id") REFERENCES "assets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_tokens" ADD CONSTRAINT "share_tokens_child_id_fkey" FOREIGN KEY ("child_id") REFERENCES "children"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_tokens" ADD CONSTRAINT "share_tokens_created_by_session_fkey" FOREIGN KEY ("created_by_session") REFERENCES "web_companion_upload_sessions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_access_logs" ADD CONSTRAINT "share_access_logs_share_token_id_fkey" FOREIGN KEY ("share_token_id") REFERENCES "share_tokens"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "lan_uploads" ADD CONSTRAINT "lan_uploads_session_id_fkey" FOREIGN KEY ("session_id") REFERENCES "lan_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agent_runs" ADD CONSTRAINT "agent_runs_agent_config_id_fkey" FOREIGN KEY ("agent_config_id") REFERENCES "agent_configs"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "agent_runs" ADD CONSTRAINT "agent_runs_child_id_fkey" FOREIGN KEY ("child_id") REFERENCES "children"("id") ON DELETE CASCADE ON UPDATE CASCADE;
