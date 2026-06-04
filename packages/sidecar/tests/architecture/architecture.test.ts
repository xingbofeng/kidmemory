import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");

function listTsFiles(dir: string): string[] {
  const result: string[] = [];
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      result.push(...listTsFiles(fullPath));
    } else if (entry.isFile() && entry.name.endsWith(".ts")) {
      result.push(fullPath);
    }
  }
  return result;
}

test("prisma migrations are present for deploy-time schema management", () => {
  const migrationsDir = path.join(root, "prisma", "migrations");
  const migrationFile = path.join(migrationsDir, "init", "migration.sql");
  const lockFile = path.join(migrationsDir, "migration_lock.toml");
  const migration = fs.readFileSync(migrationFile, "utf8");
  const lock = fs.readFileSync(lockFile, "utf8");

  assert.match(lock, /provider = "postgresql"/);
  assert.match(migration, /CREATE EXTENSION IF NOT EXISTS vector/);
  assert.match(migration, /CREATE TABLE "children"/);
  assert.match(migration, /CREATE TABLE "assets"/);
  assert.match(migration, /CREATE TABLE "agent_configs"/);
});

test("legacy hand-written schema files are not runtime schema sources", () => {
  for (const relativePath of [
    "sql",
    "migrations",
    "src/infrastructure/database/migration.service.ts",
    "src/infrastructure/database/schema.ts",
  ]) {
    assert.equal(fs.existsSync(path.join(root, relativePath)), false, `${relativePath} should not remain as a runtime schema source`);
  }
});

test("unit tests must not keep placeholder scenarios", () => {
  const placeholderPattern = /TODO|assert\.ok\(true\b|should document|暂时跳过|需要实现/i;
  const offenders = listTsFiles(path.join(root, "tests", "unit"))
    .filter((file) => placeholderPattern.test(fs.readFileSync(file, "utf8")))
    .map((file) => path.relative(root, file));

  assert.deepEqual(offenders, [], `placeholder tests found:\n${offenders.join("\n")}`);
});

test("unit tests should not keep historical fix-only files", () => {
  const offenders = listTsFiles(path.join(root, "tests", "unit"))
    .filter((file) => path.basename(file).includes("-fixes.test."))
    .map((file) => path.relative(root, file));

  assert.deepEqual(offenders, [], `historical fix-only tests found:\n${offenders.join("\n")}`);
});

test("unit test filenames should describe behavior instead of duplicate history", () => {
  const offenders = listTsFiles(path.join(root, "tests", "unit"))
    .filter((file) => path.basename(file).includes("-duplicate.test."))
    .map((file) => path.relative(root, file));

  assert.deepEqual(offenders, [], `duplicate-history test names found:\n${offenders.join("\n")}`);
});

test("web companion attribution tests should exercise behavior, not source strings", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "data-attribution.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /readFileSync|fileURLToPath|\bimportAsset\b/);
});

test("session quota tests use typed express doubles without any casts", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "session-quota.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b/);
});

test("session quota middleware does not log routine state changes to stdout", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "security", "session-quota.middleware.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /console\.log\(/);
});

test("web companion services log through Nest logger instead of console", () => {
  const files = [
    "src/modules/web-companion/share-token.service.ts",
    "src/modules/web-companion/direct-upload.service.ts",
    "src/modules/web-companion/web-companion.service.ts",
    "src/modules/web-companion/lan-receiver.service.ts",
    "src/modules/web-companion/web-companion.module.ts",
  ];
  const offenders = files.filter((relativePath) => /console\.(log|warn|error|info)\(/.test(
    fs.readFileSync(path.join(root, relativePath), "utf8"),
  ));

  assert.deepEqual(offenders, [], `web companion console logs found:\n${offenders.join("\n")}`);
});

test("security cleanup middleware does not log routine state changes to stdout", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "security", "rate-limit.middleware.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /console\.log\(/);
});

test("config readiness domain does not require unused prisma dependency", () => {
  const domain = fs.readFileSync(
    path.join(root, "src", "modules", "config", "providers", "config.domain.ts"),
    "utf8",
  );
  const service = fs.readFileSync(
    path.join(root, "src", "modules", "config", "config.service.ts"),
    "utf8",
  );

  assert.doesNotMatch(domain, /prisma:\s*PrismaService/);
  assert.doesNotMatch(service, /prisma:\s*this\.prisma/);
});

test("sidecar cloud sync does not poll legacy cloud jobs endpoints", () => {
  const syncFiles = [
    "src/modules/sync/cloud-api.client.ts",
    "src/modules/sync/sync.service.ts",
    "src/modules/sync/dto/cloud-api.dto.ts",
  ];
  const offenders = syncFiles.filter((relativePath) => {
    const source = fs.readFileSync(path.join(root, relativePath), "utf8");
    return /\/jobs\/pending|\/jobs\/\$\{|getPendingJobs|updateJobStatus|JobResponseDto|UpdateJobStatusDto|startJobSync|syncJobs|syncJob|executeJob/.test(source);
  });

  assert.deepEqual(offenders, [], `legacy cloud jobs sync found:\n${offenders.join("\n")}`);
});

test("security middlewares log through Nest logger instead of console", () => {
  const files = [
    "src/infrastructure/security/input-validation.middleware.ts",
    "src/infrastructure/security/rate-limit.middleware.ts",
    "src/infrastructure/security/session-quota.middleware.ts",
  ];
  const offenders = files.filter((relativePath) => /console\.(warn|error|log)\(/.test(
    fs.readFileSync(path.join(root, relativePath), "utf8"),
  ));

  assert.deepEqual(offenders, [], `security middleware console logs found:\n${offenders.join("\n")}`);
});

test("sidecar bootstrap logs through Nest logger instead of stdout console", () => {
  const source = fs.readFileSync(path.join(root, "src", "main.ts"), "utf8");

  assert.doesNotMatch(source, /console\.log\(/);
  assert.match(source, /new Logger\("SidecarBootstrap"\)/);
});

test("sidecar bootstrap avoids comments that restate setup calls", () => {
  const source = fs.readFileSync(path.join(root, "src", "main.ts"), "utf8");

  assert.doesNotMatch(
    source,
    /Enable shutdown hooks|Configure CORS|Configure security headers|Configure body size limits|Express built-in body parser limits|Configure global exception filter|Configure global response interceptor|Configure security middlewares|输入验证|速率限制|会话配额限制|Configure Swagger\/OpenAPI documentation|Graceful shutdown handling|Helper function to parse size strings/,
  );
});

test("global exception filter logs through Nest logger instead of console", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "http", "global-exception.filter.ts"),
    "utf8",
  );

  assert.match(source, /new Logger\(GlobalExceptionFilter\.name\)/);
  assert.doesNotMatch(source, /console\.(warn|error|log)\(/);
});

test("dataset services log through Nest logger instead of console", () => {
  const files = [
    "src/infrastructure/dataset-state/dataset-state.service.ts",
    "src/modules/dataset/dataset.service.ts",
    "src/modules/dataset/providers/asset-metadata-inference.ts",
  ];
  const offenders = files.filter((relativePath) => /console\.(warn|error|log|info)\(/.test(
    fs.readFileSync(path.join(root, relativePath), "utf8"),
  ));

  assert.deepEqual(offenders, [], `dataset service console logs found:\n${offenders.join("\n")}`);
});

test("sidecar production source logs through framework loggers instead of console", () => {
  const offenders = listTsFiles(path.join(root, "src"))
    .filter((file) => /console\.(log|warn|error|info)\(/.test(fs.readFileSync(file, "utf8")))
    .map((file) => path.relative(root, file));

  assert.deepEqual(offenders, [], `sidecar production console logs found:\n${offenders.join("\n")}`);
});

test("session quota middleware keeps response parsing typed", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "security", "session-quota.middleware.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b/);
});

test("browse service parses tags from unknown data without any casts", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "web-companion", "browse.service.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /parseTags\(tags:\s*any\)|\bas any\b/);
});

test("browse service avoids comments that restate validation branches", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "web-companion", "browse.service.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /Validate session|Validate share token|Check if session|Check if token|Check expiration|Check access count|Generate API-relative|already an array|try to parse as JSON|JSON parsing fails|Clamp limit/);
});

test("share ip limiter avoids comments that restate rate-limit branches", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "web-companion", "share-ip-limiter.service.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /Share IP Rate Limiter|Maximum requests per IP per window|Time window in milliseconds|How long to block an IP|100 requests per window|1 minute window|5 minutes block|Check if an IP is allowed|Returns true if allowed|Get remaining requests for an IP|Get time until IP is unblocked|Returns 0 if not blocked|Reset limits for an IP|Get statistics|Start cleanup interval|If no IP provided|Check if IP|Check if limit|If blocked|Ensure cleanup runs|Remove blocked status|Remove timestamps|Record this access|Count requests|Run cleanup every minute|Cleanup old records|Remove if no recent activity|Stop cleanup interval/);
});

test("agent config application service avoids comments that restate use-case steps", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "agent-config", "application", "agent-config-application.service.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /Validate business rules|Check encryption availability|Check for duplicate names|Create domain entity|Handle default configuration|Save the new configuration|Log audit event|Get current configuration|Handle API key encryption|Update domain entity|Save updated configuration|Check if config can be deleted|Soft delete|Save all updated configurations|Validate request|Get configuration|Get decrypted API key|Prepare test prompt|Perform the test|Update config with test result|Update config with failed test result/);
});

test("agent config domain service avoids comments that restate default transitions", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "agent-config", "domain", "agent-config-domain.service.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /Mark current defaults as non-default|Mark new config as default/);
});

test("agent config entity avoids comments that restate property accessors", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "agent-config", "domain", "agent-config.entity.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /Getters|We have an API key/);
});

test("agent config controller avoids comments that restate DTO parsing and error mapping", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "agent-config", "presentation", "agent-config.http-controller.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /Validate request using Zod|Map common error patterns to appropriate HTTP status codes/);
});

test("agent config dto avoids comments that restate schema and type sections", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "agent-config", "presentation", "agent-config.dto.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /Zod schemas for validation|Type definitions inferred from schemas|Success response DTOs/);
});

test("share token service avoids comments that restate validation branches", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "web-companion", "share-token.service.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /Check IP rate limit first/);
});

test("web companion service avoids restated workflow comments", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "web-companion", "web-companion.service.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /严格按照 PRD|职责：|会话管理|上传项管理|私有辅助方法|数据库操作方法（待实现）|创建上传会话|创建会话的内部实现|验证子账户存在|生成会话 ID 和 Token|计算过期时间|创建会话记录|生成 Web URL|检查是否是数据库唯一性冲突错误|获取会话摘要|检查会话是否过期|获取子账户信息|统计已使用的上传项数量|检查存储提供商可用性|获取会话详情|关闭会话|检查会话是否已经关闭|检查状态转换是否有效|更新会话状态|创建上传项|验证 token 和会话状态|检查会话是否可以创建新的上传项|检查上传项数量限制|验证文件|如果有错误，抛出第一个错误|生成签名上传目标|提交上传项|获取上传项|验证 object key 匹配|检查状态转换|重试上传项|检查是否可以重试|重置状态到 PENDING|实际检查 Supabase 配置|验证 Supabase 配置|动态导入 Supabase SDK|生成 signed upload URL|计算 hash|创建临时文件|写入临时文件|清理临时文件|更新状态为 ready|更新状态为 failed/);
});

test("web companion controller avoids comments that restate share error mapping", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "web-companion", "web-companion.controller.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /Map share service errors to HTTP status codes/);
});

test("web companion controller avoids endpoint section comments that repeat method names", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "web-companion", "web-companion.controller.ts"),
    "utf8",
  );

  assert.doesNotMatch(
    source,
    /\/\/ (?:Browse endpoints|Share token endpoints|Public share access endpoint(?: \(no session required\))?|Public shared assets endpoint(?: \(no session required\))?|Public shared book endpoint(?: \(no session required\))?|Public shared content endpoints)/,
  );
});

test("direct upload service and security tests avoid task-number workflow comments", () => {
  const service = fs.readFileSync(
    path.join(root, "src", "modules", "web-companion", "direct-upload.service.ts"),
    "utf8",
  );
  const securityTest = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "direct-upload-security.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(
    service,
    /\/\/ ----|启动定期清理任务|启动定期清理过期会话|清理过期的会话|停止清理定时器|拒绝在缺失必需配置时签发会话|0\.[12]:|计算过期时间|生成一次性 token|验证 token|\/\/ 幂等：已经 ready|\/\/ pending_remote → downloading/,
  );
  assert.doesNotMatch(
    securityTest,
    /任务 0\.1-0\.4|0\.[12]:|最小化 mock 依赖|没有 childExists|正确 token/,
  );
});

test("lan receiver service avoids restated workflow comments", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "web-companion", "lan-receiver.service.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /负责局域网设备发现|职责：|设备发现|设备配对|文件上传|Token 验证|私有辅助方法|数据库操作|内存中的会话存储|当前上传计数器|合并配置|启动清理任务|获取设备发现信息|发现局域网设备|使用 mDNS 发现设备|处理设备配对请求|验证配对码|生成会话|保存会话|处理局域网直传文件上传|验证会话和token|检查并发上传限制|验证文件|更新上传计数器|处理每个文件|减少上传计数器|更新会话的当前上传数|获取LAN会话状态|验证LAN会话token|先从内存缓存查找|如果内存中没有|检查过期|清理过期会话|验证token|更新最后访问时间|简单的6位数字配对码验证|检查文件大小|检查文件类型|保存文件到临时位置|写入文件|使用 DatasetService 导入文件|清理临时文件|查找第一个非回环的IPv4地址|每5分钟清理过期会话|检查内存中的会话/);
});

test("sync service avoids restated lifecycle and cloud sync comments", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "sync", "sync.service.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /稍后实现|心跳间隔|从环境变量读取同步间隔|启动时注册设备|注册成功后再启动同步循环|获取当前设备 ID|注册设备|启动心跳循环|发送心跳|停止所有定时器|使用指数退避重试|启动上传同步循环|同步上传项目|处理每个项|同步单个上传项目|检查上传项是否已同步|查询 assets 表|从 Supabase 下载文件|保存到临时目录|导入 asset|获取现有 metadata|更新 asset metadata|清理临时文件|启动任务同步循环|同步任务|处理每个任务|同步单个任务|执行任务|根据任务类型执行不同的逻辑|执行资产处理任务|调用 DatasetService\.enqueueSearchIndexing/);
});

test("api response interceptor avoids comments that restate response-shape checks", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "http", "api-response.interceptor.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /Check if data already has the new format structure/);
});

test("global exception filter avoids comments that restate error branches", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "http", "global-exception.filter.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /Handle Zod-like validation errors|Handle specific error types/);
});

test("http runtime config avoids duplicate and restated CORS comments", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "http", "http-runtime-config.service.ts"),
    "utf8",
  );

  assert.equal(source.match(/CORS 配置说明/g)?.length ?? 0, 1);
  assert.doesNotMatch(
    source,
    /^\s*\/\/ (?:如果没有配置自定义 origins|精确匹配白名单|动态匹配局域网 IP|只允许 http\/https|localhost 变体|192\.168\.x\.x|10\.x\.x\.x|172\.16\.x\.x - 172\.31\.x\.x)/m,
  );
});

test("locale middleware tests exercise the real middleware without copied parser code", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "http", "locale.middleware.ts"),
    "utf8",
  );
  const testSource = fs.readFileSync(
    path.join(root, "tests", "unit", "infrastructure", "http", "locale.middleware.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /解析 Accept-Language header|查找第一个支持的语言|精确匹配|语言前缀匹配|导出工厂函数供 NestJS 使用/);
  assert.doesNotMatch(testSource, /function parseLocale|const SUPPORTED_LOCALES|const DEFAULT_LOCALE/);
  assert.match(testSource, /new LocaleMiddleware\(\)/);
});

test("message service tests avoid comments that restate error code groups", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "infrastructure", "http", "message.service.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\/\/ (?:通用错误|认证错误|参数错误|业务错误|分享错误|上传错误|限流错误|服务器错误)/);
});

test("security middleware tests avoid comments that restate rate-limit assertions", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "security", "security-middleware.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\/\/ (?:模拟大量请求|验证 ipRecords 数量合理|清理定时器|不应该抛出错误|重复调用也安全)/);
});

test("rate limit middleware avoids restated comments and unused response labels", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "security", "rate-limit.middleware.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /code:\s*string|IP_BLOCKED|GLOBAL_RATE_LIMIT_EXCEEDED|IP_RATE_LIMIT_EXCEEDED|PATH_RATE_LIMIT_EXCEEDED/);
  assert.doesNotMatch(source, /时间窗口（毫秒）|最大请求数|请求时间戳数组|封禁截止时间|定时清理器|IP 级别的请求记录|全局请求记录|路径级别的请求记录|配置|失败记录（用于自动封禁）|上次清理时间/);
  assert.doesNotMatch(source, /\/\/ (?:[1-6]\. 检查|记录路径级别的请求|记录请求|出错时放行|优先从代理头获取真实 IP|封禁已过期|过滤出时间窗口内的请求|更新时间戳数组|只保留时间窗口内的失败记录|如果失败次数超过阈值|清空失败记录|清理 IP 记录|清理路径记录|清理失败记录|清理全局时间戳)/);
});

test("input validation and session quota middleware avoid restated comments and duplicated quota response updates", () => {
  const inputValidation = fs.readFileSync(
    path.join(root, "src", "infrastructure", "security", "input-validation.middleware.ts"),
    "utf8",
  );
  const sessionQuota = fs.readFileSync(
    path.join(root, "src", "infrastructure", "security", "session-quota.middleware.ts"),
    "utf8",
  );

  assert.doesNotMatch(inputValidation, /可疑请求记录|恶意 User-Agent 模式|最大请求体大小/);
  assert.doesNotMatch(inputValidation, /\/\/ (?:[1-4]\. 验证|出错时放行|检查是否匹配恶意模式|检查是否为明显的顺序 ID|只保留最近 1 小时的记录|如果同一 IP 在 1 小时内有超过 10 次可疑行为，记录警告)/);
  assert.doesNotMatch(inputValidation, /\*\s+(?:获取客户端 IP|验证 User-Agent|验证请求体大小|验证 childId 格式|记录可疑行为|获取可疑行为统计（用于监控）)/);

  assert.doesNotMatch(sessionQuota, /当前活跃会话数|今天创建的会话总数|上次重置日期|活跃会话 ID 集合|childId -> 配额记录|配额配置|每个 childId 最多|会话过期时间（毫秒）|会话创建时间记录|上次清理时间/);
  assert.doesNotMatch(sessionQuota, /\/\/ (?:只拦截创建会话的请求|定期清理过期数据|获取或创建配额记录|检查活跃会话配额|检查每日会话配额|生成临时会话 ID|预先占用配额|标记是否已处理响应|拦截响应以更新实际会话 ID|如果成功创建会话|移除临时 ID|添加实际 ID|如果创建失败|处理 send 方法|解析失败|出错时放行|检查是否需要重置每日计数|只删除非临时 ID|每 5 分钟清理一次|清理过期会话|从配额记录中移除过期会话|清理空的配额记录|删除所有会话时间戳|重置配额记录)/);
  assert.doesNotMatch(sessionQuota, /\*\s+(?:获取或创建配额记录|记录会话关闭（供外部调用）|获取当前日期（YYYY-MM-DD）|清理过期数据|获取配额统计信息（用于监控）|手动清理特定 childId 的所有会话（管理员功能）)/);
  assert.match(sessionQuota, /private commitReservedSession/);
  assert.match(sessionQuota, /private rollbackReservedSession/);
});

test("security monitor controller avoids comments that restate health thresholds", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "security", "security-monitor.controller.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /安全监控端点|提供实时的安全统计信息|计算健康状态/);
  assert.doesNotMatch(source, /\/\/ (?:如果有超过 10 个 IP 被封禁，可能正在遭受攻击|如果活跃会话数超过 100，可能有异常)/);
});

test("app config service does not keep unused Supabase S3 endpoint helpers", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "config", "app-config.service.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /function defaultSupabaseS3Endpoint/);
});

test("file job store uses a named filesystem not-found helper", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "jobs", "file-job-store.service.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\(error as \{ code: string \}\)\.code === "ENOENT"/);
  assert.match(source, /import \{ isNotFoundError \} from "\.\.\/filesystem\/errors\.ts"/);
});

test("filesystem not-found checks are shared instead of copied in infrastructure services", () => {
  const helperPath = path.join(root, "src", "infrastructure", "filesystem", "errors.ts");
  assert.equal(fs.existsSync(helperPath), true);
  const helperSource = fs.readFileSync(helperPath, "utf8");
  const consumers = [
    "src/infrastructure/jobs/file-job-store.service.ts",
    "src/infrastructure/logging/file-logger.service.ts",
  ];

  assert.match(helperSource, /export function isNotFoundError\(error: unknown\)/);
  for (const relativePath of consumers) {
    const source = fs.readFileSync(path.join(root, relativePath), "utf8");
    assert.match(source, /from "\.\.\/filesystem\/errors\.ts"|from "\.\.\/\.\.\/infrastructure\/filesystem\/errors\.ts"/);
    assert.doesNotMatch(source, /^function isNotFoundError\(error: unknown\)/m);
  }
});

test("prisma not-found checks are shared instead of copied across repositories", () => {
  const helperPath = path.join(root, "src", "infrastructure", "database", "prisma-errors.ts");
  assert.equal(fs.existsSync(helperPath), true);
  const helperSource = fs.readFileSync(helperPath, "utf8");
  const consumers = [
    "src/infrastructure/dataset-state/prisma-dataset-db.service.ts",
    "src/modules/web-companion/direct-upload.providers.ts",
    "src/modules/web-companion/prisma-web-companion.repository.ts",
  ];

  assert.match(helperSource, /export function isPrismaNotFoundError\(error: unknown\)/);
  assert.match(helperSource, /P2025/);
  for (const relativePath of consumers) {
    const source = fs.readFileSync(path.join(root, relativePath), "utf8");
    assert.match(source, /isPrismaNotFoundError/);
    assert.doesNotMatch(source, /function isPrismaNotFound(?:Error)?\(error: unknown\)/);
    assert.doesNotMatch(source, /P2025/);
  }
});

test("direct upload URL trimming is shared instead of copied", () => {
  const helperPath = path.join(root, "src", "infrastructure", "url", "trailing-slash.ts");
  assert.equal(fs.existsSync(helperPath), true);
  const helperSource = fs.readFileSync(helperPath, "utf8");
  const consumers = [
    "src/modules/storage/providers/supabase-storage.ts",
    "src/modules/storage/providers/object-storage.ts",
    "src/modules/web-companion/direct-upload.service.ts",
  ];

  assert.match(helperSource, /export function trimTrailingSlash\(value: string\)/);
  assert.equal(fs.existsSync(path.join(root, "src", "modules", "web-companion", "direct-upload-url.ts")), false);
  for (const relativePath of consumers) {
    const source = fs.readFileSync(path.join(root, relativePath), "utf8");
    assert.match(source, /infrastructure\/url\/trailing-slash\.ts/);
    assert.doesNotMatch(source, /^function trimTrailingSlash\(value: string\)/m);
  }
});

test("matching env boolean parsing is shared instead of copied", () => {
  const helperPath = path.join(root, "src", "infrastructure", "config", "env-parsing.ts");
  assert.equal(fs.existsSync(helperPath), true);
  const helperSource = fs.readFileSync(helperPath, "utf8");
  const consumers = [
    "src/infrastructure/config/app-config.service.ts",
    "src/infrastructure/http/http-runtime-config.service.ts",
    "src/modules/media/providers/pollinations-image.provider.ts",
  ];

  assert.match(helperSource, /export function parseEnvBoolean\(value: string \| undefined, fallback: boolean\)/);
  for (const relativePath of consumers) {
    const source = fs.readFileSync(path.join(root, relativePath), "utf8");
    assert.match(source, /parseEnvBoolean/);
    assert.doesNotMatch(source, /^function parseBoolean\(value: string \| undefined, fallback: boolean\)/m);
  }
});

test("generic error-code checks are shared instead of copied", () => {
  const helperPath = path.join(root, "src", "infrastructure", "errors", "error-code.ts");
  assert.equal(fs.existsSync(helperPath), true);
  const helperSource = fs.readFileSync(helperPath, "utf8");
  const consumers = [
    "src/modules/books/providers/pdf.ts",
    "src/modules/dataset/providers/asset-import.ts",
  ];

  assert.match(helperSource, /export function hasErrorCode\(error: unknown, code: string\)/);
  for (const relativePath of consumers) {
    const source = fs.readFileSync(path.join(root, relativePath), "utf8");
    assert.match(source, /hasErrorCode/);
    assert.doesNotMatch(source, /^function hasErrorCode\(error: unknown, code: string\)/m);
  }
});

test("Playwright availability errors are detected by a shared helper", () => {
  const helperPath = path.join(root, "src", "infrastructure", "browser", "playwright-errors.ts");
  const consumers = [
    "src/modules/books/providers/pdf.ts",
    "src/modules/books/providers/long-image.ts",
  ];

  assert.equal(fs.existsSync(helperPath), true);
  assert.match(fs.readFileSync(helperPath, "utf8"), /export function isPlaywrightUnavailable\(error: unknown\)/);
  for (const relativePath of consumers) {
    const source = fs.readFileSync(path.join(root, relativePath), "utf8");
    assert.match(source, /infrastructure\/browser\/playwright-errors\.ts/);
    assert.doesNotMatch(source, /^function isPlaywrightUnavailable\(error: unknown\)/m);
  }
});

test("retry delays use the shared time helper instead of private sleep wrappers", () => {
  const helperPath = path.join(root, "src", "infrastructure", "time", "delay.ts");
  const consumers = [
    "src/modules/agent-runtime/agent-runtime.service.ts",
    "src/modules/sync/sync.service.ts",
    "src/modules/web-companion/web-companion.service.ts",
  ];

  assert.equal(fs.existsSync(helperPath), true);
  assert.match(fs.readFileSync(helperPath, "utf8"), /export function delay\(ms: number\): Promise<void>/);
  for (const relativePath of consumers) {
    const source = fs.readFileSync(path.join(root, relativePath), "utf8");
    assert.match(source, /import \{ delay \} from ["']\.\.\/\.\.\/infrastructure\/time\/delay\.ts["']/);
    assert.doesNotMatch(source, /private sleep\(/);
    assert.doesNotMatch(source, /new Promise\(\(?resolve\)? => setTimeout\(resolve,/);
  }
});

test("browse service tests use typed repository doubles", () => {
  const files = [
    "tests/unit/modules/web-companion/browse-service.test.ts",
    "tests/unit/modules/web-companion/browse-service-repository.test.ts",
  ];
  const offenders = files
    .filter((relativePath) => fs.existsSync(path.join(root, relativePath)))
    .filter((relativePath) => /\bas any\b|:\s*any\b|any\[\]/.test(
      fs.readFileSync(path.join(root, relativePath), "utf8"),
    ));

  assert.deepEqual(offenders, [], `browse service test any still present:\n${offenders.join("\n")}`);
});

test("browse service repository tests avoid fake SQL assertions", () => {
  const sourcePath = path.join(
    root,
    "tests",
    "unit",
    "modules",
    "web-companion",
    "browse-service-repository.test.ts",
  );
  if (!fs.existsSync(sourcePath)) {
    return;
  }

  const source = fs.readFileSync(sourcePath, "utf8");
  assert.doesNotMatch(source, /query\(sql|sql\.includes|Mock database|Mock valid session|Mock recent assets|Mock asset|Mock books|Mock share token/);
});

test("asset preview tests use typed controller doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "infrastructure", "asset-preview.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b/);
});

test("trace propagation http test uses typed express middleware", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "http", "trace-propagation-file-logging.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b/);
});

test("creation contract stores use typed records", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "contracts", "creation-contracts.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b/);
});

test("config service singleton tests use typed dependency doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "config", "config-service-singleton.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b/);
});

test("security middleware tests use typed express doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "security", "security-middleware.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b/);
});

test("config ui tests use typed readiness dependencies", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "config", "config-ui.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b/);
});

test("config service tests use typed dependency doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "config", "config.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b/);
});

test("sample dataset tests use typed memory records", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "dataset", "sample-dataset.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b/);
});

test("search indexing worker tests use typed timer and service doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "dataset", "search-indexing.worker.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("search indexing worker explicitly injects DatasetService for tsx runtime", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "modules", "dataset", "providers", "search-indexing.worker.ts"),
    "utf8",
  );

  assert.match(source, /constructor\(@Inject\(DatasetService\) private readonly datasetService: DatasetService\)/);
});

test("web companion search indexing tests use typed dataset dependencies", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "search-indexing.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("dataset service singleton tests use typed dependencies", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "dataset", "dataset-service-singleton.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("dataset domain tests use typed state and config dependencies", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "dataset", "dataset-domain.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("share token tests use typed repository doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "security", "share-token.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("share token tests avoid fake SQL assertions and mock walkthrough comments", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "security", "share-token.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /query\(sql|sql\.includes|Mock database|Mock valid session|Mock successful|Mock valid share token|Mock expired|Mock share token|Mock no session|Mock book|Test helpers/);
});

test("integration tests use typed rejection and aggregation helpers", () => {
  const files = [
    "tests/integration/web-companion-e2e.test.ts",
    "tests/integration/upload-commit-integration.test.ts",
    "tests/integration/share-access-integration.test.ts",
  ];
  const offenders = files.filter((relativePath) => /\bas any\b|:\s*any\b|any\[\]/.test(
    fs.readFileSync(path.join(root, relativePath), "utf8"),
  ));

  assert.deepEqual(offenders, [], `integration test any still present:\n${offenders.join("\n")}`);
});

test("integration tests skip through node test options instead of setup logs", () => {
  const files = [
    "tests/integration/web-companion-e2e.test.ts",
    "tests/integration/upload-commit-integration.test.ts",
    "tests/integration/share-access-integration.test.ts",
  ];
  const offenders = files.filter((relativePath) => /console\.log\("Skipping|catch \(error\)/.test(
    fs.readFileSync(path.join(root, relativePath), "utf8"),
  ));

  assert.deepEqual(offenders, [], `integration setup skip logs found:\n${offenders.join("\n")}`);
});

test("agent config module tests use runtime input types instead of any casts", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "agent-config", "agent-config-module.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("direct upload controller tests use typed error helpers", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "direct-upload-controller.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("direct upload provider tests use typed prisma doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "direct-upload-providers.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("direct upload security tests use typed service dependencies", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "direct-upload-security.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("signed upload tests use typed private helper access", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "signed-upload.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("web companion route contract tests use typed controller doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "route-contract.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("web companion controller tests use typed service doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "web-companion.controller.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("pullback worker tests keep the private worker smoke test minimal and typed", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "pullback-worker.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
  assert.equal(source.match(/startPullbackProcess method should exist/g)?.length ?? 0, 1);
});

test("cloud api client tests construct clients without unused dependency casts", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "sync", "cloud-api-client.test.ts"),
    "utf8",
  );
  const clientSource = fs.readFileSync(
    path.join(root, "src", "modules", "sync", "cloud-api.client.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /as never|\bas any\b|:\s*any\b|any\[\]/);
  assert.doesNotMatch(clientSource, /constructor\(@Inject\(AppConfigService\)/);
});

test("creation service tests keep test doubles typed without any escapes", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "creation", "creation-service.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|Record<string,\s*any>/);
});

test("browse controller tests use typed request and response doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "browse-controller.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("browse controller tests exercise the real web companion controller", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "browse-controller.test.ts"),
    "utf8",
  );

  assert.match(source, /WebCompanionController/);
  assert.doesNotMatch(source, /MockRequest|MockResponse|Simulate controller logic/);
});

test("web companion controller tests share unused dependency doubles", () => {
  const testDir = path.join(root, "tests", "unit", "modules", "web-companion");
  const helperPath = path.join(testDir, "controller-test-doubles.ts");
  const controllerSources = [
    "browse-controller.test.ts",
    "web-companion.controller.test.ts",
  ].map((file) => fs.readFileSync(path.join(testDir, file), "utf8"));

  assert.equal(fs.existsSync(helperPath), true);
  for (const source of controllerSources) {
    assert.doesNotMatch(source, /function createUnused(?:WebCompanion|Browse|ShareToken)Service/);
    assert.match(source, /controller-test-doubles\.ts/);
  }
});

test("MCP HTTP tests share tool JSON decoding", () => {
  const helperPath = path.join(root, "tests", "http", "mcp-test-helpers.ts");
  const consumers = [
    "tests/http/mcp-asset-tools.test.ts",
    "tests/http/mcp-diagnostic-image-hyperframes-tools.test.ts",
    "tests/http/trace-propagation-file-logging.test.ts",
  ];

  assert.equal(fs.existsSync(helperPath), true);
  assert.match(fs.readFileSync(helperPath, "utf8"), /export function parseToolJson/);
  for (const relativePath of consumers) {
    const source = fs.readFileSync(path.join(root, relativePath), "utf8");
    assert.match(source, /mcp-test-helpers\.ts/);
    assert.doesNotMatch(source, /^function (?:parseToolJson|decodeToolJson|decodeNestedJson)\(/m);
  }
});

test("MCP HTTP tests share environment setup and restore logic", () => {
  const helperPath = path.join(root, "tests", "http", "mcp-test-helpers.ts");
  const consumers = [
    "tests/http/mcp-asset-tools.test.ts",
    "tests/http/mcp-baseline.test.ts",
    "tests/http/mcp-diagnostic-image-hyperframes-tools.test.ts",
    "tests/http/mcp-feature-flag.test.ts",
    "tests/http/mcp-router.smoke.test.ts",
    "tests/http/mcp-sdk-probe.test.ts",
    "tests/http/mcp-sdk.integration.test.ts",
    "tests/http/trace-propagation-file-logging.test.ts",
  ];

  assert.equal(fs.existsSync(helperPath), true);
  assert.match(fs.readFileSync(helperPath, "utf8"), /export function useMcpTestEnv/);
  for (const relativePath of consumers) {
    const source = fs.readFileSync(path.join(root, relativePath), "utf8");
    assert.match(source, /mcp-test-helpers\.ts/);
    assert.doesNotMatch(source, /oldEnabled|oldPath|KIDMEMORY_MCP_ENABLED =|KIDMEMORY_MCP_PATH =/);
  }
});

test("sidecar tests share process env setup and restore logic", () => {
  const helperPath = path.join(root, "tests", "test-env.ts");
  const consumers = [
    "tests/contracts/http-contracts.test.ts",
    "tests/http/mcp-test-helpers.ts",
    "tests/http/trace-propagation-file-logging.test.ts",
    "tests/unit/modules/dataset/search-indexing.worker.test.ts",
    "tests/unit/modules/sync/cloud-api-client.test.ts",
    "tests/unit/modules/sync/cloud-sync.test.ts",
  ];

  assert.equal(fs.existsSync(helperPath), true);
  assert.match(fs.readFileSync(helperPath, "utf8"), /export function useTestEnv/);
  for (const relativePath of consumers) {
    const source = fs.readFileSync(path.join(root, relativePath), "utf8");
    assert.match(source, /test-env\.ts/);
    assert.doesNotMatch(source, /function restoreEnv|restoreEnv:/);
    assert.doesNotMatch(source, /const original\w+\s*=\s*process\.env\./);
    assert.doesNotMatch(source, /const previous\w+\s*=\s*process\.env\./);
  }
});

test("commit idempotency tests use typed service dependencies", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "commit-idempotency.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("web companion service tests use typed query doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "web-companion-service.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
});

test("web companion service tests avoid query-string repository doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "web-companion", "web-companion-service.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /query\(sql|sql\.includes|QueryBacked|INSERT INTO|SELECT .*web_companion|UPDATE web_companion/s);
});

test("cloud sync tests use typed service dependencies", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "sync", "cloud-sync.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]/);
  assert.doesNotMatch(source, /\.sleep\s*=/);
});

test("cloud sync retry tests do not wait for real backoff delays", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "sync", "cloud-sync.test.ts"),
    "utf8",
  );

  assert.match(source, /mock\.timers/);
});

test("storage sync service tests use typed provider doubles", () => {
  const source = fs.readFileSync(
    path.join(root, "tests", "unit", "modules", "storage", "storage-sync-service.test.ts"),
    "utf8",
  );

  assert.doesNotMatch(source, /\bas any\b|:\s*any\b|any\[\]|Promise<any>/);
});

test("simplifiable production boundaries use unknown or explicit types instead of any", () => {
  const files = [
    "src/modules/web-companion/browse.service.ts",
    "src/modules/web-companion/prisma-browse.repository.ts",
    "src/modules/books/providers/book.ts",
    "src/modules/books/providers/pdf.ts",
    "src/modules/books/providers/long-image.ts",
    "src/modules/storage/providers/storage-sync.ts",
    "src/modules/dataset/providers/asset-import.ts",
    "src/modules/agent-config/domain/agent-config.entity.ts",
    "src/modules/agent-config/ports/agent-config.ports.ts",
    "src/modules/agent-config/adapters/in-memory-audit-logger.ts",
    "src/infrastructure/http/api-response.interceptor.ts",
    "src/infrastructure/http/response-format.util.ts",
  ];

  const offenders = files
    .filter((relativePath) => /\bas any\b|:\s*any\b|Record<string,\s*any>|Observable<any>|ApiResponse<any>/.test(
      fs.readFileSync(path.join(root, relativePath), "utf8"),
    ));

  assert.deepEqual(offenders, [], `production any still present:\n${offenders.join("\n")}`);
});

test("sidecar runtime DTOs do not depend on empty generated sidecar schemas", () => {
  const offenders = listTsFiles(path.join(root, "src"))
    .map((file) => path.relative(root, file))
    .filter((relativePath) => relativePath !== "src/modules/sync/dto/cloud-api.dto.ts")
    .filter((relativePath) => {
      const source = fs.readFileSync(path.join(root, relativePath), "utf8");
      return source.includes("@kidmemory/protocol/generated/sidecar/ts");
    });

  assert.deepEqual(
    offenders,
    [],
    `sidecar runtime DTOs should use explicit local types while generated sidecar schemas are empty:\n${offenders.join("\n")}`,
  );
});

test("persistent dataset state uses the Prisma ORM adapter", () => {
  const datasetState = fs.readFileSync(
    path.join(root, "src", "infrastructure", "dataset-state", "dataset-state.service.ts"),
    "utf8",
  );
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "dataset-state", "prisma-dataset-db.service.ts"),
    "utf8",
  );

  assert.match(datasetState, /PrismaDatasetDbService/);
  assert.match(source, /implements SampleDb/);
  assert.match(source, /this\.prisma\.asset\.upsert/);
  assert.match(source, /this\.prisma\.embeddingJob\.create/);
  assert.match(source, /this\.prisma\.storageSyncJob\.create/);
  assert.doesNotMatch(source, /\.\s*(?:query|executeRaw|queryRaw|queryRawUnsafe)\s*\(/);
  assert.doesNotMatch(source, /`[^`]*(?:select|insert|update|delete)\s+/i);
});

test("production repository fallbacks are guarded by the shared in-memory fallback policy", () => {
  const webCompanionModule = fs.readFileSync(
    path.join(root, "src", "modules", "web-companion", "web-companion.module.ts"),
    "utf8",
  );
  const datasetService = fs.readFileSync(
    path.join(root, "src", "modules", "dataset", "dataset.service.ts"),
    "utf8",
  );

  assert.match(webCompanionModule, /allowInMemoryDatasetFallback/);
  assert.match(webCompanionModule, /if \(!allowInMemoryDatasetFallback\(\)\) throw error;/);
  assert.match(datasetService, /if \(!allowInMemoryDatasetFallback\(\)\) throw error;/);
});

test("prisma dataset semantic search stores and scores ORM-managed embeddings", () => {
  const source = fs.readFileSync(
    path.join(root, "src", "infrastructure", "dataset-state", "prisma-dataset-db.service.ts"),
    "utf8",
  );
  const schema = fs.readFileSync(path.join(root, "prisma", "schema.prisma"), "utf8");

  assert.match(schema, /embeddingData\s+Json\?\s+@map\("embedding_data"\)/);
  assert.match(source, /this\.prisma\.\$transaction/);
  assert.match(source, /tx\.assetEmbedding\.upsert/);
  assert.match(source, /embeddingData:\s*jsonArray\(input\.embedding\)/);
  assert.match(source, /cosineSimilarity\(input\.vector,\s*embedding\)/);
  assert.doesNotMatch(source, /semanticScore:\s*0\.5/);
});

test("agent execution is isolated to the agent-runtime adapter", () => {
  for (const relativePath of [
    "src/modules/books/providers/agent.ts",
    "src/modules/books/providers/agent-runner-manager.ts",
    "src/modules/books/providers/agent-runner.interface.ts",
    "src/modules/books/providers/claude-agent-runner.ts",
    "src/modules/books/providers/local-agent-runner.ts",
    "src/modules/books/providers/publication-flow.ts",
    "src/modules/books/providers/openai-sdk-agent-runner.ts",
    "src/modules/skills/skill-runtime.service.ts",
    "src/modules/media/hyperframes-render.service.ts",
  ]) {
    assert.equal(fs.existsSync(path.join(root, relativePath)), false, `${relativePath} should not remain in production source`);
  }

  for (const file of listTsFiles(path.join(root, "src"))) {
    const relative = path.relative(root, file);
    if (relative.startsWith("src/modules/agent-runtime/")) continue;
    const source = fs.readFileSync(file, "utf8");
    assert.doesNotMatch(source, /@openai\/agents|OpenAISDKAgentRunner|SkillRuntimeService|HyperframesRenderService/);
  }
});

test("sidecar uses nestjs as the production http runtime", () => {
  for (const relativePath of ["src/modules/config", "src/modules/dataset", "src/infrastructure/config", "src/infrastructure/database", "src/infrastructure/jobs", "src/infrastructure/dataset-state"]) {
    assert.equal(fs.statSync(path.join(root, relativePath)).isDirectory(), true);
  }

  const packageJson = JSON.parse(fs.readFileSync(path.join(root, "package.json"), "utf8"));
  assert.match(packageJson.scripts.build, /node --run lint/);
  assert.match(packageJson.scripts.build, /node --run check:tests/);
  assert.match(packageJson.scripts["check:tests"], /tsx --test/);
  assert.match(packageJson.scripts["check:tests"], /tests/);

  const main = fs.readFileSync(path.join(root, "src", "main.ts"), "utf8");
  assert.match(main, /NestFactory\.create\(AppModule/);
  assert.doesNotMatch(main, /createServer|createSidecarRequestHandler/);
});

test("sidecar bootstrap middleware uses typed express boundaries and protocol error codes", () => {
  const main = fs.readFileSync(path.join(root, "src", "main.ts"), "utf8");

  assert.doesNotMatch(main, /\bas any\b|:\s*any\b|code:\s*12000/);
  assert.match(main, /ApiCode\.INVALID_PARAMS/);
});

test("dataset asset delete API uses only the canonical DELETE route", () => {
  const datasetController = fs.readFileSync(path.join(root, "src", "modules", "dataset", "dataset.controller.ts"), "utf8");

  assert.match(datasetController, /Delete\("assets\/:id"\)/);
  assert.doesNotMatch(datasetController, /Post\("assets\/:id\/delete"\)/);
  assert.doesNotMatch(datasetController, /deleteAssetPost/);
});

test("nestjs services use @Injectable decorator for standard NestJS DI", () => {
  const expected = new Map([
    ["dataset", /@Injectable\(\)\s+export class DatasetService/],
    ["config", /@Injectable\(\)\s+export class ConfigService/],
  ]);

  for (const [feature, decoratorPattern] of expected) {
    const serviceName = `${feature[0].toUpperCase()}${feature.slice(1)}Service`;
    const service = fs.readFileSync(path.join(root, "src", "modules", feature, `${feature}.service.ts`), "utf8");
    assert.match(service, decoratorPattern);
    assert.doesNotMatch(service, /registerInjectable/);
  }
});

test("sidecar follows standard nestjs package and module layout", () => {
  const packageJson = JSON.parse(fs.readFileSync(path.join(root, "package.json"), "utf8"));
  for (const dependency of ["@nestjs/common", "@nestjs/core", "@nestjs/platform-express", "reflect-metadata", "rxjs"]) {
    assert.ok(packageJson.dependencies[dependency], `${dependency} should be declared`);
  }

  for (const relativePath of [
    "src/main.ts",
    "src/app.module.ts",
    "src/infrastructure/infrastructure.module.ts",
    "src/infrastructure/config/app-config.service.ts",
    "src/infrastructure/dataset-state/prisma-dataset-db.service.ts",
    "src/infrastructure/database/prisma-migration.service.ts",
    "src/infrastructure/jobs/file-job-store.service.ts",
    "src/infrastructure/dataset-state/dataset-state.service.ts",
    "src/infrastructure/dataset-state/memory-dataset-db.ts",
    "src/modules/config/config.module.ts",
    "src/modules/config/config.controller.ts",
    "src/modules/config/config.service.ts",
    "src/modules/config/providers/config.domain.ts",
    "src/modules/dataset/dataset.module.ts",
    "src/modules/dataset/dataset.controller.ts",
    "src/modules/dataset/dataset.service.ts",
    "src/modules/dataset/providers/dataset.domain.ts",
  ]) {
    assert.equal(fs.existsSync(path.join(root, relativePath)), true, `${relativePath} should exist`);
  }

  const forbiddenProductionPaths = [
    "src/server.ts",
    "src/main.nest.ts",
    "src/app/router.ts",
    "src/app/api/route-map.ts",
    "src/infrastructure/context",
    "src/infrastructure/context/sidecar-context.service.ts",
    "src/infrastructure/persistence",
    "src/modules/sidecar",
    "src/modules/sidecar/controllers/route-dispatcher.ts",
    "src/modules/sidecar/controllers/config.route.ts",
    "src/modules/sidecar/controllers/dataset.route.ts",
    "src/modules/sidecar/controllers/books.route.ts",
  ];
  for (const relativePath of forbiddenProductionPaths) {
    assert.equal(fs.existsSync(path.join(root, relativePath)), false, `${relativePath} should not remain in production source`);
  }

  const allowedRootProductionFiles = new Set(["app.module.ts", "main.ts"]);
  const rootProductionFiles = fs.readdirSync(path.join(root, "src"))
    .filter((file) => file.endsWith(".ts") && !file.endsWith(".test.ts"));
  assert.deepEqual(rootProductionFiles.sort(), [...allowedRootProductionFiles].sort());
});

test("nestjs feature modules register their own controllers and providers", () => {
  for (const feature of ["config", "dataset"]) {
    const modulePath = path.join(root, "src", "modules", feature, `${feature}.module.ts`);
    const moduleSource = fs.readFileSync(modulePath, "utf8");
    const classPrefix = feature[0].toUpperCase() + feature.slice(1);
    assert.match(moduleSource, new RegExp(`${classPrefix}Controller`));
    assert.match(moduleSource, new RegExp(`${classPrefix}Service`));
    assert.match(moduleSource, /Module\(\{/);
    assert.match(moduleSource, /imports:\s*\[[^\]]*InfrastructureModule/);
    assert.match(moduleSource, /controllers:/);
    assert.match(moduleSource, /providers:/);
    assert.doesNotMatch(moduleSource, /SidecarContextService/);
  }
});

test("feature module roots keep the standard nestjs shape", () => {
  for (const feature of ["config", "dataset"]) {
    const featureDir = path.join(root, "src", "modules", feature);
    const entries = fs.readdirSync(featureDir).sort();
    const allowedEntries = new Set([
      `${feature}.controller.ts`,
      `${feature}.module.ts`,
      `${feature}.service.ts`,
      "dto",
      "providers",
    ]);
    const expected = [...allowedEntries].filter((entry) => fs.existsSync(path.join(featureDir, entry))).sort();
    assert.deepEqual(entries, expected, `${feature} module root should only contain standard Nest files and subdirectories`);
  }
});

test("infrastructure module owns shared runtime providers once", () => {
  const moduleSource = fs.readFileSync(path.join(root, "src", "infrastructure", "infrastructure.module.ts"), "utf8");
  for (const provider of ["AppConfigService", "PrismaService", "PrismaMigrationService", "PrismaDatasetDbService", "FileJobStoreService", "DatasetStateService"]) {
    assert.match(moduleSource, new RegExp(provider));
  }
  assert.doesNotMatch(moduleSource, /SidecarContextService|createRequestHandler|createRouteDispatcher|createSidecarServices/);
});

test("trace request logging is the only sidecar request logging middleware", () => {
  assert.equal(
    fs.existsSync(path.join(root, "src", "infrastructure", "http", "request-logging.middleware.ts")),
    false,
    "request-logging.middleware.ts should not remain beside trace-request-logging.middleware.ts",
  );
});

test("web companion session quota release uses dependency injection instead of globals", () => {
  const sources = [
    fs.readFileSync(path.join(root, "src", "main.ts"), "utf8"),
    fs.readFileSync(path.join(root, "src", "modules", "web-companion", "web-companion.service.ts"), "utf8"),
  ].join("\n");

  assert.doesNotMatch(sources, /global(?:This)?\s*(?:as|\.|\[)/);
});

test("infrastructure does not depend on feature modules", () => {
  const infrastructureRoot = path.join(root, "src", "infrastructure");
  const offenders: string[] = [];
  const visit = (dir: string) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) visit(fullPath);
      if (entry.isFile() && entry.name.endsWith(".ts")) {
        const source = fs.readFileSync(fullPath, "utf8");
        if (source.includes("../../modules/") || source.includes("../modules/")) {
          offenders.push(path.relative(root, fullPath));
        }
      }
    }
  };
  visit(infrastructureRoot);
  assert.deepEqual(offenders, [], `infrastructure must not import feature modules:\n${offenders.join("\n")}`);
});

test("feature modules do not embed database SQL", () => {
  const modulesRoot = path.join(root, "src", "modules");
  const queryPattern = /\b(?:dbService|database|client|pool)\.query\s*\(|\.\$query(?:Raw|RawUnsafe|runCommandRaw)\s*\(/;
  const allowed = new Set([
    path.join(root, "src", "modules", "config", "providers", "readiness.ts"),
  ]);
  const offenders: string[] = [];

  const visit = (dir: string) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) visit(fullPath);
      if (entry.isFile() && entry.name.endsWith(".ts")) {
        if (allowed.has(fullPath)) continue;
        const source = fs.readFileSync(fullPath, "utf8");
        const sourceWithoutComments = source
          .replace(/\/\*[\s\S]*?\*\//g, "")
          .replace(/^\s*\/\/.*$/gm, "");
        if (queryPattern.test(sourceWithoutComments)) {
          offenders.push(path.relative(root, fullPath));
        }
      }
    }
  };

  visit(modulesRoot);
  assert.deepEqual(offenders, [], `feature modules should use repositories/ORM instead of SQL:\n${offenders.join("\n")}`);
});

test("nestjs services inject explicit infrastructure providers instead of a sidecar context", () => {
  for (const feature of ["config", "dataset"]) {
    const servicePath = path.join(root, "src", "modules", feature, `${feature}.service.ts`);
    const serviceSource = fs.readFileSync(servicePath, "utf8");
    assert.doesNotMatch(serviceSource, /SidecarContextService|SidecarContext\b/);
  }
});

test("nestjs feature modules use dto files for request contracts", () => {
  for (const relativePath of [
    "src/modules/dataset/dto/import-sample.dto.ts",
  ]) {
    assert.equal(fs.existsSync(path.join(root, relativePath)), true, `${relativePath} should exist`);
  }

  const datasetController = fs.readFileSync(path.join(root, "src", "modules", "dataset", "dataset.controller.ts"), "utf8");
  assert.match(datasetController, /ImportSampleDto/);
});

test("nestjs controllers stay thin and delegate business work to feature services", () => {
  const controllerFiles = ["config", "dataset"].map((feature) => path.join(root, "src", "modules", feature, `${feature}.controller.ts`));
  const domainFiles = ["config", "dataset"].map((feature) => path.join(root, "src", "modules", feature, "providers", `${feature}.domain.ts`));
  const controllers = controllerFiles.map((file) => fs.readFileSync(file, "utf8")).join("\n");
  const domain = domainFiles.map((file) => fs.readFileSync(file, "utf8")).join("\n");

  assert.ok(domainFiles.length >= 2, "sidecar should be split across multiple domain services");

  for (const forbidden of ["checkPostgres", "importSampleDataset"]) {
    assert.equal(controllers.includes(forbidden), false, `controller should not orchestrate ${forbidden}`);
    assert.equal(domain.includes(forbidden), true, `domain should own ${forbidden}`);
  }
  assert.match(controllers, /Service/);
});

test("legacy book job module is removed from sidecar runtime", () => {
  for (const relativePath of [
    "src/modules/books/books.module.ts",
    "src/modules/books/books.controller.ts",
    "src/modules/books/books.service.ts",
    "src/modules/books/providers/books.domain.ts",
  ]) {
    assert.equal(fs.existsSync(path.join(root, relativePath)), false, `${relativePath} should not remain in production source`);
  }
});

test("cloud sync removed job errors avoid historical API wording", () => {
  const source = fs.readFileSync(path.join(root, "src", "modules", "sync", "sync.service.ts"), "utf8");

  assert.doesNotMatch(source, /legacy book job API/i);
});

test("sidecar module internals avoid duplicated feature filenames", () => {
  const modulesRoot = path.join(root, "src");
  const collected = new Map<string, string[]>();

  const visit = (dir: string) => {
    for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
      const fullPath = path.join(dir, entry.name);
      if (entry.isDirectory()) visit(fullPath);
      if (entry.isFile() && entry.name.endsWith(".ts")) {
        const list = collected.get(entry.name) || [];
        list.push(path.relative(modulesRoot, fullPath));
        collected.set(entry.name, list);
      }
    }
  };

  visit(modulesRoot);

  const duplicates = [...collected.entries()]
    .filter(([, files]) => files.length > 1)
    .map(([name, files]) => `${name}: ${files.join(", ")}`);

  assert.deepEqual(duplicates, [], `duplicate module filenames found:\n${duplicates.join("\n")}`);
});

test("nestjs services use standard constructor injection with private readonly", () => {
  const roots = [
    path.join(root, "src", "modules", "config"),
    path.join(root, "src", "modules", "dataset"),
  ];

  const servicesWithStandardInjection: string[] = [];
  for (const dir of roots) {
    for (const file of fs.readdirSync(dir)) {
      if (!file.endsWith(".service.ts")) continue;
      const filePath = path.join(dir, file);
      const source = fs.readFileSync(filePath, "utf8");
      if (source.includes("constructor(") && source.includes("@Injectable()")) {
        servicesWithStandardInjection.push(path.relative(root, filePath));
      }
    }
  }

  assert.ok(servicesWithStandardInjection.length >= 2, `services should use standard NestJS constructor injection:\n${servicesWithStandardInjection.join("\n")}`);
});

test("runtime scripts build agent-runtime file dependency before loading sidecar app", () => {
  const packageJson = JSON.parse(fs.readFileSync(path.join(root, "package.json"), "utf8")) as {
    scripts?: Record<string, string>;
  };
  const scripts = packageJson.scripts ?? {};
  const runtimeScripts = [
    "dev",
    "test",
    "test:unit",
    "test:integration",
    "test:contracts",
    "type-check",
    "check:tests",
    "build:prod",
    "gen:openapi",
  ];

  assert.match(
    scripts["prepare:agent-runtime"] ?? "",
    /node scripts\/prepare-agent-runtime\.mjs/,
    "prepare:agent-runtime must prepare @kidmemory/agent-runtime through the dedicated script",
  );
  for (const scriptName of runtimeScripts) {
    assert.match(
      scripts[scriptName] ?? "",
      /npm run prepare:agent-runtime/,
      `${scriptName} must prepare @kidmemory/agent-runtime before sidecar runtime loading`,
    );
  }
});
