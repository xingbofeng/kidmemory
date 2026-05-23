import { Module } from "@nestjs/common";

import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { InfrastructureModule } from "../../infrastructure/infrastructure.module.ts";
import { DatasetModule } from "../dataset/dataset.module.ts";
import { DatasetService } from "../dataset/dataset.service.ts";

import { DirectUploadController } from "./direct-upload.controller.ts";
import { DirectUploadService } from "./direct-upload.service.ts";
import {
  DatasetServiceDirectUploadAssetGateway,
  PrismaDirectUploadPullbackStore,
  SupabaseDirectUploadStorageGateway,
} from "./direct-upload.providers.ts";
import { WebCompanionController } from "./web-companion.controller.ts";
import { WebCompanionService } from "./web-companion.service.ts";
import { PrismaWebCompanionRepository } from "./prisma-web-companion.repository.ts";
import { InMemoryWebCompanionRepository } from "./in-memory-web-companion.repository.ts";
import { BrowseService } from "./browse.service.ts";
import { PrismaBrowseRepository } from "./prisma-browse.repository.ts";
import { PrismaShareTokenRepository } from "./prisma-share-token.repository.ts";
import { ShareTokenService } from "./share-token.service.ts";
import { LanReceiverController } from "./lan-receiver.controller.ts";
import { LanReceiverService } from "./lan-receiver.service.ts";
import { PrismaLanReceiverRepository } from "./prisma-lan-receiver.repository.ts";
import { PrismaService } from "../../infrastructure/database/prisma.service.ts";

@Module({
  imports: [InfrastructureModule, DatasetModule],
  controllers: [WebCompanionController, DirectUploadController, LanReceiverController],
  providers: [
    AppConfigService,
    {
      provide: LanReceiverService,
      useFactory: (appConfig: AppConfigService, prisma: PrismaService, dataset: DatasetService) => {
        const repository = new PrismaLanReceiverRepository(prisma);
        return new LanReceiverService(appConfig, repository, dataset);
      },
      inject: [AppConfigService, PrismaService, DatasetService],
    },
    {
      provide: WebCompanionService,
      useFactory: async (appConfig: AppConfigService, prisma: PrismaService, dataset: DatasetService) => {
        let repository: PrismaWebCompanionRepository | InMemoryWebCompanionRepository;
        if (process.env.KIDMEMORY_OPENAPI_GENERATION === "1") {
          repository = new InMemoryWebCompanionRepository();
        } else try {
          await prisma.$queryRaw`SELECT 1`;
          repository = new PrismaWebCompanionRepository(prisma);
        } catch (error) {
          console.warn(
            "WebCompanionService falling back to in-memory repository:",
            error instanceof Error ? error.message : error,
          );
          repository = new InMemoryWebCompanionRepository();
        }
        return new WebCompanionService(appConfig, repository, dataset);
      },
      inject: [AppConfigService, PrismaService, DatasetService],
    },
    {
      provide: BrowseService,
      useFactory: (prisma: PrismaService) => {
        return new BrowseService(new PrismaBrowseRepository(prisma));
      },
      inject: [PrismaService],
    },
    {
      provide: ShareTokenService,
      useFactory: (prisma: PrismaService, appConfig: AppConfigService) => {
        const baseUrl = appConfig.config.sidecar.webCompanionBaseUrl || 'http://localhost:5173';
        return new ShareTokenService(new PrismaShareTokenRepository(prisma), baseUrl);
      },
      inject: [PrismaService, AppConfigService],
    },
    {
      provide: DirectUploadService,
      useFactory: (
        appConfig: AppConfigService,
        dataset: DatasetService,
        prisma: PrismaService,
      ) => {
        return new DirectUploadService({
          appConfig,
          storage: new SupabaseDirectUploadStorageGateway(appConfig),
          assets: new DatasetServiceDirectUploadAssetGateway(dataset),
          pullback: new PrismaDirectUploadPullbackStore(prisma),
          idFactory: {
            nextSessionId: () =>
              `wcs_direct_${Date.now().toString(36)}_${Math.random().toString(36).slice(2, 8)}`,
          },
        });
      },
      inject: [AppConfigService, DatasetService, PrismaService],
    },
  ],
})
export class WebCompanionModule {}
