import { hostedMcpTool, type Tool } from "@openai/agents";

export type McpServerDefinition = {
  id: string;
  name: string;
  transport: McpServerTransport;
  enabled?: boolean;
  toolAllowlist?: string[];
  metadata?: Record<string, unknown>;
};

export type McpServerTransport =
  | {
      type: "stdio";
      command: string;
      args?: string[];
      env?: Record<string, string>;
      cwd?: string;
    }
  | {
      type: "http";
      url: string;
      headers?: Record<string, string>;
    };

export function toOpenAIAgentsMcpTools(servers: McpServerDefinition[]): Tool[] {
  return servers
	    .filter((server) => server.enabled !== false)
	    .flatMap((server) => {
	      if (server.transport.type !== "http") {
	        throw new Error(`stdio MCP servers are not supported by the OpenAI hosted MCP adapter: ${server.id}`);
	      }
	      return [
        hostedMcpTool({
          serverLabel: server.id,
          serverUrl: server.transport.url,
          headers: server.transport.headers,
          serverDescription: server.name,
          allowedTools: server.toolAllowlist,
          requireApproval: "never",
        }),
      ];
    });
}
