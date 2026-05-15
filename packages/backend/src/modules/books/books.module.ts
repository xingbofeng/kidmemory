import { Module } from "@nestjs/common";

import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { AgentConfigModule } from "../agent-config/agent-config.module.ts";
import { BooksController } from "./books.controller.ts";
import { BooksService } from "./books.service.ts";

export class BooksModule {}

Module({
  imports: [InfrastructureModule, AgentConfigModule],
  controllers: [BooksController],
  providers: [BooksService],
  exports: [BooksService],
})(BooksModule);
