import type { AgentExecutor, ExecutorRunRequest, ExecutorRunResult } from "./types.js";

export class FakeExecutor implements AgentExecutor {
  readonly id = "fake";
  private readonly handler: (request: ExecutorRunRequest) => Promise<ExecutorRunResult>;

  constructor(handler: (request: ExecutorRunRequest) => Promise<ExecutorRunResult>) {
    this.handler = handler;
  }

  async run(request: ExecutorRunRequest): Promise<ExecutorRunResult> {
    return this.handler(request);
  }
}
