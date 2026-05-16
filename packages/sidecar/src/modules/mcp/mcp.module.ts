import { DynamicModule, Module } from "@nestjs/common";
import { McpModule, McpTransportType } from "@rekog/mcp-nest";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { BooksModule } from "../books/books.module.ts";
import { ConfigModule } from "../config/config.module.ts";
import { DatasetModule } from "../dataset/dataset.module.ts";
import { MediaModule } from "../media/media.module.ts";
import { SkillsModule } from "../skills/skills.module.ts";
import { AssetMcpTools } from "./tools/asset.mcp-tools.ts";
import { BookMcpTools } from "./tools/book.mcp-tools.ts";
import { DiagnosticMcpTools } from "./tools/diagnostic.mcp-tools.ts";
import { SkillRuntimeMcpTools } from "./tools/skill-runtime.mcp-tools.ts";

const MCP_SERVER_NAME = "kidmemory-sidecar";

export class SidecarMcpModule {
  static registerFromEnv(): DynamicModule {
    const enabled = parseBoolean(process.env.KIDMEMORY_MCP_ENABLED, true);
    const endpointPath = normalizeEndpointPath(process.env.KIDMEMORY_MCP_PATH);
    if (!enabled) {
      return {
        module: SidecarMcpModule,
        imports: [],
        providers: [],
        exports: [],
      } satisfies DynamicModule;
    }

    return {
      module: SidecarMcpModule,
      imports: [
        InfrastructureModule,
        ConfigModule,
        DatasetModule,
        BooksModule,
        MediaModule,
        SkillsModule,
        McpModule.forRoot({
          name: MCP_SERVER_NAME,
          version: "0.1.0",
          transport: [McpTransportType.STREAMABLE_HTTP],
          mcpEndpoint: endpointPath,
          streamableHttp: {
            enableJsonResponse: true,
            statelessMode: true,
          },
        }),
        McpModule.forFeature(
          [DiagnosticMcpTools, AssetMcpTools, BookMcpTools, SkillRuntimeMcpTools],
          MCP_SERVER_NAME,
        ),
      ],
      providers: [DiagnosticMcpTools, AssetMcpTools, BookMcpTools, SkillRuntimeMcpTools],
      exports: [DiagnosticMcpTools, AssetMcpTools, BookMcpTools, SkillRuntimeMcpTools],
    } satisfies DynamicModule;
  }
}

Module({})(SidecarMcpModule);

function parseBoolean(value: string | undefined, defaultValue: boolean) {
  if (value == null || value.trim() === "") return defaultValue;
  return ["1", "true", "yes", "on"].includes(value.trim().toLowerCase());
}

function normalizeEndpointPath(value: string | undefined) {
  const raw = value?.trim() || "/mcp";
  const clean = raw.startsWith("/") ? raw.slice(1) : raw;
  return clean.length > 0 ? clean : "mcp";
}
