-- CreateSchema
CREATE SCHEMA IF NOT EXISTS "public";

-- CreateTable
CREATE TABLE "devices" (
    "id" TEXT NOT NULL,
    "machineId" TEXT NOT NULL,
    "deviceName" TEXT,
    "platform" TEXT,
    "lastHeartbeat" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "devices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "upload_sessions" (
    "id" TEXT NOT NULL,
    "childId" TEXT NOT NULL,
    "status" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "maxItems" INTEGER NOT NULL DEFAULT 100,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "upload_sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "upload_items" (
    "id" TEXT NOT NULL,
    "sessionId" TEXT NOT NULL,
    "deviceId" TEXT,
    "objectKey" TEXT NOT NULL,
    "fileName" TEXT NOT NULL,
    "fileSize" BIGINT,
    "mimeType" TEXT,
    "status" TEXT NOT NULL,
    "uploadedAt" TIMESTAMP(3),
    "syncedAt" TIMESTAMP(3),
    "errorMessage" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "upload_items_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "share_tokens" (
    "id" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "childId" TEXT NOT NULL,
    "bookId" TEXT,
    "accessLimit" INTEGER,
    "accessCount" INTEGER NOT NULL DEFAULT 0,
    "expiresAt" TIMESTAMP(3),
    "revokedAt" TIMESTAMP(3),
    "createdBy" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "share_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "share_access_logs" (
    "id" TEXT NOT NULL,
    "tokenId" TEXT NOT NULL,
    "ipAddress" TEXT NOT NULL,
    "userAgent" TEXT,
    "accessedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "share_access_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "devices_machineId_key" ON "devices"("machineId");

-- CreateIndex
CREATE INDEX "devices_machineId_idx" ON "devices"("machineId");

-- CreateIndex
CREATE INDEX "devices_lastHeartbeat_idx" ON "devices"("lastHeartbeat");

-- CreateIndex
CREATE INDEX "upload_sessions_childId_idx" ON "upload_sessions"("childId");

-- CreateIndex
CREATE INDEX "upload_sessions_status_idx" ON "upload_sessions"("status");

-- CreateIndex
CREATE INDEX "upload_sessions_expiresAt_idx" ON "upload_sessions"("expiresAt");

-- CreateIndex
CREATE INDEX "upload_items_sessionId_idx" ON "upload_items"("sessionId");

-- CreateIndex
CREATE INDEX "upload_items_deviceId_idx" ON "upload_items"("deviceId");

-- CreateIndex
CREATE INDEX "upload_items_status_idx" ON "upload_items"("status");

-- CreateIndex
CREATE INDEX "upload_items_uploadedAt_idx" ON "upload_items"("uploadedAt");

-- CreateIndex
CREATE UNIQUE INDEX "share_tokens_token_key" ON "share_tokens"("token");

-- CreateIndex
CREATE INDEX "share_tokens_token_idx" ON "share_tokens"("token");

-- CreateIndex
CREATE INDEX "share_tokens_childId_idx" ON "share_tokens"("childId");

-- CreateIndex
CREATE INDEX "share_tokens_expiresAt_idx" ON "share_tokens"("expiresAt");

-- CreateIndex
CREATE INDEX "share_access_logs_tokenId_idx" ON "share_access_logs"("tokenId");

-- CreateIndex
CREATE INDEX "share_access_logs_accessedAt_idx" ON "share_access_logs"("accessedAt");

-- AddForeignKey
ALTER TABLE "upload_items" ADD CONSTRAINT "upload_items_sessionId_fkey" FOREIGN KEY ("sessionId") REFERENCES "upload_sessions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "upload_items" ADD CONSTRAINT "upload_items_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES "devices"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "share_access_logs" ADD CONSTRAINT "share_access_logs_tokenId_fkey" FOREIGN KEY ("tokenId") REFERENCES "share_tokens"("id") ON DELETE CASCADE ON UPDATE CASCADE;
