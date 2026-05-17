import { Inject, Injectable } from "@nestjs/common";

import { AppConfigService } from "../../infrastructure/config/app-config.service.ts";
import { DatasetStateService } from "../../infrastructure/dataset-state/dataset-state.service.ts";
import { FileJobStoreService } from "../../infrastructure/jobs/file-job-store.service.ts";
import { AgentConfigApplicationService } from "../agent-config/application/agent-config-application.service.ts";
import { createBooksService } from "./providers/books.domain.ts";
import { OpenAISDKAgentRunner } from "./providers/openai-sdk-agent-runner.ts";

@Injectable()
export class BooksService {
  private readonly config: AppConfigService;
  private readonly datasetState: DatasetStateService;
  private readonly jobStore: FileJobStoreService;
  private readonly agentConfigService: AgentConfigApplicationService;
  private readonly agentRunner: OpenAISDKAgentRunner;

  constructor(
    @Inject(AppConfigService) config: AppConfigService,
    @Inject(DatasetStateService) datasetState: DatasetStateService,
    @Inject(FileJobStoreService) jobStore: FileJobStoreService,
    @Inject(AgentConfigApplicationService) agentConfigService: AgentConfigApplicationService,
  ) {
    this.config = config;
    this.datasetState = datasetState;
    this.jobStore = jobStore;
    this.agentConfigService = agentConfigService;
    this.agentRunner = new OpenAISDKAgentRunner({
      model: 'gpt-4',
      temperature: 0.7,
      maxTokens: 4000
    });
  }

  private get delegate() {
    return createBooksService({
      config: this.config.config,
      datasetState: this.datasetState,
      jobStore: this.jobStore,
      agentConfigService: this.agentConfigService,
      agentRunner: this.agentRunner,
    });
  }

  // 原有方法
  createJob(body: Record<string, unknown>) { return this.delegate.createJob(body); }
  listJobs() { return this.delegate.listJobs(); }
  getJob(id: string) { return this.delegate.getJob(id); }
  cancelJob(id: string) { return this.delegate.cancelJob(id); }
  retryJob(id: string) { return this.delegate.retryJob(id); }
  getPreviewHtml(id: string) { return this.delegate.getPreviewHtml(id); }
  exportPdf(id: string, body: Record<string, unknown> = {}) { return this.delegate.exportPdf(id, body); }
  exportLongImage(id: string, body: Record<string, unknown> = {}) { return this.delegate.exportLongImage(id, body); }
}
