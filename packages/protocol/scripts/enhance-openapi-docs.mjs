import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const openapiDir = path.resolve(__dirname, "../openapi");

const INPUTS = [
  "cloud-api.openapi.json",
  "sidecar.openapi.json",
];

const TAG_ZH_MAP = {
  config: "系统配置",
  dataset: "数据集",
  books: "书稿生成",
  "web-companion": "移动端",
  DirectUpload: "直传上传",
  LanReceiver: "局域网上传",
  StreamableHttp: "流式通信",
  SecurityMonitor: "安全监控",
  AgentConfig: "Agent 配置",
  Dataset: "数据集",
  Books: "书稿",
  WebCompanion: "移动端",
};

const ROUTE_KEYWORD_ZH = [
  ["health", "健康检查"],
  ["ready", "就绪检查"],
  ["config", "配置管理"],
  ["children", "孩子档案"],
  ["assets", "素材库"],
  ["search", "智能搜索"],
  ["books", "书稿生成"],
  ["sessions", "上传会话"],
  ["upload-items", "上传项"],
  ["direct-upload", "直传上传"],
  ["lan", "局域网传输"],
  ["share", "分享访问"],
  ["agent", "Agent 配置"],
  ["mcp", "MCP 工具"],
];

function resolveRef(root, ref) {
  if (!ref || typeof ref !== "string" || !ref.startsWith("#/")) return null;
  const parts = ref.slice(2).split("/");
  let cursor = root;
  for (const p of parts) {
    cursor = cursor?.[p];
    if (cursor == null) return null;
  }
  return cursor;
}

function inferPrimitiveExample(schema) {
  if (!schema || typeof schema !== "object") return null;
  if (schema.example !== undefined) return schema.example;
  if (Array.isArray(schema.enum) && schema.enum.length > 0) return schema.enum[0];
  switch (schema.type) {
    case "string":
      if (schema.format === "date-time") return "2026-05-17T12:00:00.000Z";
      if (schema.format === "date") return "2026-05-17";
      if (schema.format === "email") return "kidmemory@example.com";
      if (schema.format === "uri") return "https://example.com/resource";
      if (/id$/i.test(schema.title || "")) return "id_001";
      return "示例文本";
    case "integer":
      return 1;
    case "number":
      return 1.0;
    case "boolean":
      return true;
    default:
      return null;
  }
}

function inferExampleByKey(key, schema) {
  const lower = String(key || "").toLowerCase();
  if (lower === "childid") return "孩子档案ID";
  if (lower === "sessionid") return "会话ID";
  if (lower === "uploaditemid") return "上传项ID";
  if (lower === "assetid") return "素材ID";
  if (lower === "bookid") return "书稿ID";
  if (lower === "token") return "示例Token";
  if (lower === "name") return "示例名称";
  if (lower === "title") return "示例标题";
  if (lower === "description") return "示例说明";
  if (lower === "filename") return "photo.jpg";
  if (lower === "contenttype") return "image/jpeg";
  if (lower === "objectkey") return "uploads/2026/05/photo.jpg";
  if (lower.endsWith("url")) return "https://example.com/path";
  if (schema?.type === "boolean") return true;
  if (schema?.type === "integer") return 1;
  if (schema?.type === "number") return 1;
  return null;
}

function zhFieldDescription(key, schema) {
  const lower = String(key || "").toLowerCase();
  if (lower === "childid") return "孩子档案唯一标识";
  if (lower === "sessionid") return "上传会话唯一标识";
  if (lower === "uploaditemid") return "上传项唯一标识";
  if (lower === "assetid") return "素材唯一标识";
  if (lower === "bookid") return "书稿唯一标识";
  if (lower === "token") return "鉴权令牌";
  if (lower === "name") return "名称";
  if (lower === "title") return "标题";
  if (lower === "description") return "描述";
  if (lower === "filename") return "文件名";
  if (lower === "contenttype") return "MIME 类型";
  if (lower === "sizebytes") return "文件大小（字节）";
  if (lower.endsWith("url")) return "可访问链接";
  if (schema?.type === "string") return "字符串字段";
  if (schema?.type === "integer") return "整数字段";
  if (schema?.type === "number") return "数值字段";
  if (schema?.type === "boolean") return "布尔字段";
  if (schema?.type === "array") return "数组字段";
  return "业务字段";
}

function buildExample(root, schema, depth = 0) {
  if (!schema || depth > 6) return null;
  if (schema.$ref) return buildExample(root, resolveRef(root, schema.$ref), depth + 1);
  if (schema.example !== undefined) return schema.example;
  if (schema.allOf) {
    const merged = {};
    for (const s of schema.allOf) {
      const part = buildExample(root, s, depth + 1);
      if (part && typeof part === "object" && !Array.isArray(part)) Object.assign(merged, part);
    }
    return Object.keys(merged).length > 0 ? merged : null;
  }
  if (schema.oneOf || schema.anyOf) {
    const first = (schema.oneOf || schema.anyOf)[0];
    return buildExample(root, first, depth + 1);
  }
  if (schema.type === "array") {
    const item = buildExample(root, schema.items, depth + 1);
    return item == null ? [] : [item];
  }
  if (schema.type === "object" || schema.properties) {
    const result = {};
    const properties = schema.properties || {};
    for (const [key, value] of Object.entries(properties)) {
      const sample = inferExampleByKey(key, value) ?? buildExample(root, value, depth + 1);
      if (sample !== null) result[key] = sample;
    }
    if (schema.additionalProperties && Object.keys(result).length === 0) {
      const v = buildExample(root, schema.additionalProperties, depth + 1);
      result.key = v ?? "value";
    }
    return result;
  }
  return inferPrimitiveExample(schema);
}

function zhDescription(method, route, summary) {
  const scene = guessScene(route);
  const action = guessAction(method, route);
  return [
    "中文说明：",
    `- 接口：${method.toUpperCase()} ${route}`,
    `- 功能：${summaryZh(summary, method, route)}`,
    `- 场景：用于${scene}的${action}。`,
    "- 入参：下方 Request 示例给出可直接调试的参数结构。",
    "- 出参：下方 Response 示例展示成功响应的核心字段。",
  ].join("\n");
}

function guessScene(route) {
  const lower = route.toLowerCase();
  for (const [key, zh] of ROUTE_KEYWORD_ZH) {
    if (lower.includes(key)) return zh;
  }
  return "业务流程";
}

function guessAction(method, route) {
  const lower = route.toLowerCase();
  if (method === "get") return "查询";
  if (method === "post" && lower.includes("share")) return "创建与验证";
  if (method === "post") return "创建";
  if (method === "put" || method === "patch") return "更新";
  if (method === "delete") return "删除";
  return "处理";
}

function summaryZh(summary, method, route) {
  const raw = String(summary || "").trim();
  if (!raw) return `${guessScene(route)}${guessAction(method, route)}接口`;
  if (/Controller_/i.test(raw)) return `${guessScene(route)}${guessAction(method, route)}接口`;
  return raw;
}

function enhanceOperation(root, route, method, op) {
  if (!op) return;
  const cleanSummary = summaryZh(op.summary, method, route);
  op.summary = cleanSummary;
  op.operationId = op.operationId || `${method}_${route.replaceAll("/", "_").replaceAll("{", "").replaceAll("}", "")}`;
  if (!op.description || !String(op.description).includes("中文说明：")) {
    const base = op.description ? `${op.description}\n\n` : "";
    op.description = `${base}${zhDescription(method, route, cleanSummary)}`;
  }

  const reqJson = op.requestBody?.content?.["application/json"];
  if (reqJson && reqJson.schema && reqJson.example === undefined && reqJson.examples === undefined) {
    const ex = buildExample(root, reqJson.schema);
    if (ex !== null) reqJson.example = ex;
  }

  for (const code of ["200", "201", "202", "204"]) {
    const resp = op.responses?.[code]?.content?.["application/json"];
    if (!resp || !resp.schema) continue;
    if (resp.example === undefined && resp.examples === undefined) {
      const ex = buildExample(root, resp.schema);
      if (ex !== null) resp.example = ex;
    }
  }
}

function ensureJsonSchema(op, statusCode, schema) {
  if (!op.responses) op.responses = {};
  if (!op.responses[statusCode]) op.responses[statusCode] = { description: "" };
  if (!op.responses[statusCode].content) op.responses[statusCode].content = {};
  if (!op.responses[statusCode].content["application/json"]) {
    op.responses[statusCode].content["application/json"] = {};
  }
  op.responses[statusCode].content["application/json"].schema = schema;
}

function ensureRequestSchema(op, schema) {
  if (!op.requestBody) op.requestBody = { required: true, content: {} };
  if (!op.requestBody.content) op.requestBody.content = {};
  if (!op.requestBody.content["application/json"]) op.requestBody.content["application/json"] = {};
  op.requestBody.content["application/json"].schema = schema;
}

function patchCloudMobileSchemas(root) {
  if (!root?.paths) return;
  const p = root.paths;
  const sessionSummary = {
    type: "object",
    properties: {
      sessionId: { type: "string", description: "（中文）上传会话ID", example: "session_abc123" },
      status: { type: "string", description: "（中文）会话状态", example: "active" },
      child: {
        type: "object",
        properties: {
          id: { type: "string", example: "child_001" },
          displayName: { type: "string", example: "小明" },
        },
      },
      expiresAt: { type: "string", format: "date-time", example: "2026-05-17T12:00:00.000Z" },
      maxItems: { type: "integer", example: 50 },
      usedItems: { type: "integer", example: 3 },
    },
  };
  const createItemsReq = {
    type: "object",
    required: ["token", "files"],
    properties: {
      token: { type: "string", example: "示例Token" },
      provider: { type: "string", example: "supabase" },
      files: {
        type: "array",
        items: {
          type: "object",
          required: ["clientFileId", "filename", "contentType", "sizeBytes"],
          properties: {
            clientFileId: { type: "string", example: "file_001" },
            filename: { type: "string", example: "photo.jpg" },
            contentType: { type: "string", example: "image/jpeg" },
            sizeBytes: { type: "integer", example: 123456 },
          },
        },
      },
    },
  };
  const createItemsResp = {
    type: "object",
    properties: {
      items: {
        type: "array",
        items: {
          type: "object",
          properties: {
            clientFileId: { type: "string", example: "file_001" },
            uploadItemId: { type: "string", example: "upload_item_001" },
            assetId: { type: "string", example: "asset_001" },
            objectKey: { type: "string", example: "uploads/2026/05/photo.jpg" },
            status: { type: "string", example: "uploading" },
          },
        },
      },
    },
  };
  const commitReq = {
    type: "object",
    required: ["token", "objectKey"],
    properties: {
      token: { type: "string", example: "示例Token" },
      objectKey: { type: "string", example: "uploads/2026/05/photo.jpg" },
      remoteEtag: { type: "string", example: "etag-123" },
      contentType: { type: "string", example: "image/jpeg" },
      sizeBytes: { type: "integer", example: 123456 },
    },
  };
  const commitResp = {
    type: "object",
    properties: {
      uploadItemId: { type: "string", example: "upload_item_001" },
      status: { type: "string", example: "uploaded_remote" },
      idempotent: { type: "boolean", example: false },
    },
  };
  const tokenValidation = {
    type: "object",
    properties: {
      isValid: { type: "boolean", example: true },
      error: { type: "string", example: "Share token not found" },
      shareToken: {
        type: "object",
        properties: {
          id: { type: "string", example: "share_001" },
          childId: { type: "string", example: "child_001" },
          resourceType: { type: "string", example: "child_assets" },
          resourceId: { type: "string", example: "book_001" },
          accessType: { type: "string", example: "read_only" },
        },
      },
    },
  };

  const sessionPath = "/api/web-companion/sessions/{sessionId}";
  const itemsPath = "/api/web-companion/sessions/{sessionId}/items";
  const commitPath = "/api/web-companion/sessions/{sessionId}/items/{uploadItemId}/commit";
  const shareAccessPath = "/api/web-companion/share/{shareToken}/access";
  const shareAssetsPath = "/api/web-companion/share/{shareToken}/assets";
  const shareBookPath = "/api/web-companion/share/{shareToken}/book";

  if (p[sessionPath]?.get) ensureJsonSchema(p[sessionPath].get, "200", sessionSummary);
  if (p[itemsPath]?.post) {
    ensureRequestSchema(p[itemsPath].post, createItemsReq);
    ensureJsonSchema(p[itemsPath].post, "200", createItemsResp);
  }
  if (p[commitPath]?.put) {
    ensureRequestSchema(p[commitPath].put, commitReq);
    ensureJsonSchema(p[commitPath].put, "200", commitResp);
  }
  if (p[shareAccessPath]?.get) ensureJsonSchema(p[shareAccessPath].get, "200", tokenValidation);
  if (p[shareAssetsPath]?.get) {
    ensureJsonSchema(p[shareAssetsPath].get, "200", { type: "array", items: { type: "object" } });
  }
  if (p[shareBookPath]?.get) ensureJsonSchema(p[shareBookPath].get, "200", { type: "object" });
}

function enhanceSchemas(root) {
  const schemas = root?.components?.schemas || {};
  for (const schema of Object.values(schemas)) {
    if (!schema || typeof schema !== "object" || !schema.properties) continue;
    for (const [key, prop] of Object.entries(schema.properties)) {
      if (prop && typeof prop === "object") {
        if (!prop.description || !String(prop.description).includes("（中文）")) {
          const base = prop.description ? `${prop.description} ` : "";
          prop.description = `${base}（中文）${zhFieldDescription(key, prop)}`;
        }
        if (prop.example === undefined) {
          const byKey = inferExampleByKey(key, prop);
          if (byKey !== null) prop.example = byKey;
        }
      }
    }
  }
}

function enhanceTags(root) {
  const seen = new Set();
  const tags = [];
  for (const pathItem of Object.values(root.paths || {})) {
    for (const method of ["get", "post", "put", "patch", "delete"]) {
      const op = pathItem?.[method];
      if (!op?.tags) continue;
      op.tags = op.tags.map((tag) => TAG_ZH_MAP[tag] || tag);
      for (const tag of op.tags) {
        if (!seen.has(tag)) {
          seen.add(tag);
          tags.push({ name: tag, description: `${tag}相关接口` });
        }
      }
    }
  }
  if (tags.length > 0) root.tags = tags;
}

async function runOne(file) {
  const inputPath = path.join(openapiDir, file);
  const raw = await readFile(inputPath, "utf8");
  const doc = JSON.parse(raw);

  for (const [route, pathItem] of Object.entries(doc.paths || {})) {
    for (const method of ["get", "post", "put", "patch", "delete"]) {
      if (pathItem[method]) enhanceOperation(doc, route, method, pathItem[method]);
    }
  }
  patchCloudMobileSchemas(doc);
  enhanceSchemas(doc);
  enhanceTags(doc);

  const enhancedPath = inputPath.replace(".openapi.json", ".openapi.enhanced.json");
  await writeFile(enhancedPath, `${JSON.stringify(doc, null, 2)}\n`, "utf8");
  return enhancedPath;
}

async function main() {
  const outputs = [];
  for (const file of INPUTS) {
    outputs.push(await runOne(file));
  }
  for (const o of outputs) console.log(`Enhanced OpenAPI: ${o}`);
}

await main();
