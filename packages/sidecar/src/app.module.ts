import { MiddlewareConsumer, Module, NestModule } from "@nestjs/common";

import { InfrastructureModule } from "./infrastructure/infrastructure.module.ts";
import { TraceRequestLoggingMiddleware } from "./infrastructure/http/trace-request-logging.middleware.ts";
import { AgentConfigModule } from "./modules/agent-config/agent-config.module.ts";
import { ConfigModule } from "./modules/config/config.module.ts";
import { CreationModule } from "./modules/creation/creation.module.ts";
import { DatasetModule } from "./modules/dataset/dataset.module.ts";
import { SidecarMcpModule } from "./modules/mcp/mcp.module.ts";
import { SyncModule } from "./modules/sync/sync.module.ts";
import { WebCompanionModule } from "./modules/web-companion/web-companion.module.ts";

export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(TraceRequestLoggingMiddleware).forRoutes("*");
  }
}

Module({
  imports: [
    InfrastructureModule,
    ConfigModule,
    AgentConfigModule,
    DatasetModule,
    CreationModule,
    WebCompanionModule,
    SyncModule,
    SidecarMcpModule.registerFromEnv(),
  ],
})(AppModule);
