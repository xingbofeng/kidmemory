import { Module } from "@nestjs/common";

import { InfrastructureModule } from "./infrastructure/infrastructure.module.ts";
import { BooksModule } from "./modules/books/books.module.ts";
import { AgentConfigModule } from "./modules/agent-config/agent-config.module.ts";
import { ConfigModule } from "./modules/config/config.module.ts";
import { DatasetModule } from "./modules/dataset/dataset.module.ts";
import { WebCompanionModule } from "./modules/web-companion/web-companion.module.ts";

export class AppModule {}

Module({
  imports: [InfrastructureModule, ConfigModule, AgentConfigModule, DatasetModule, BooksModule, WebCompanionModule],
})(AppModule);
