import { describe, it, beforeEach } from 'node:test';
import assert from 'node:assert/strict';
import { OpenAISDKAgentRunner } from '../../../src/modules/books/providers/openai-sdk-agent-runner.ts';

// Mock run function
const mockRun = async (agent: any, input: any, options?: any) => {
  // Add a small delay to ensure duration > 0
  await new Promise(resolve => setTimeout(resolve, 1));

  // Mock successful response
  return {
    messages: [
      {
        role: 'user',
        content: typeof input === 'string' ? input : input.messages[0].content
      },
      {
        role: 'assistant',
        content: `\`\`\`json
{
  "title": "小明的快乐时光",
  "content": "这是一本记录小明成长过程中快乐时光的书籍",
  "pages": [
    {
      "title": "阳光下的笑容",
      "content": "小明在阳光下开心地玩耍，脸上洋溢着纯真的笑容。",
      "assets": ["asset_1"]
    },
    {
      "title": "和朋友一起",
      "content": "小明和好朋友们一起分享快乐的时光。",
      "assets": ["asset_2"]
    }
  ],
  "metadata": {
    "theme": "快乐成长",
    "ageGroup": "3-6岁",
    "pageCount": 2
  }
}
\`\`\``
      }
    ],
    usage: {
      totalTokens: 150,
      promptTokens: 100,
      completionTokens: 50
    }
  };
};

// Mock run function that can be customized per test
let mockRunBehavior = mockRun;

// Mock Agent class
class MockAgent {
  name: string;
  instructions: string;
  handoffs: any[];
  tools: any[];

  constructor(config: any) {
    this.name = config.name;
    this.instructions = config.instructions;
    this.handoffs = config.handoffs || [];
    this.tools = config.tools || [];
  }
}

// Mock dependencies
const mockDependencies = {
  Agent: MockAgent,
  run: (...args: any[]) => mockRunBehavior(...args)
};

describe('OpenAISDKAgentRunner', () => {
  let runner: OpenAISDKAgentRunner;

  beforeEach(() => {
    // Reset mock behavior to default
    mockRunBehavior = mockRun;

    // Create runner with mock dependencies
    runner = new OpenAISDKAgentRunner({
      apiKey: 'test-api-key',
      model: 'gpt-4',
      temperature: 0.7,
      maxTokens: 4000,
      systemPrompt: '你是一个专业的儿童书籍创作助手。'
    }, mockDependencies);
  });

  describe('constructor', () => {
    it('should create runner with config', () => {
      const config = {
        apiKey: 'test-key',
        model: 'gpt-4',
        temperature: 0.8,
        maxTokens: 2000
      };

      const testRunner = new OpenAISDKAgentRunner(config, mockDependencies);

      assert.equal(testRunner.getStatus(), 'idle');
    });
  });

  describe('fromAgentConfig', () => {
    it('should create runner from agent config', () => {
      const agentConfig = {
        id: 'config_1',
        name: 'Test Config',
        provider: 'openai' as const,
        model: 'gpt-4',
        baseUrl: 'https://api.openai.com/v1',
        temperature: 0.7,
        maxTokens: 4000,
        systemPrompt: 'Test prompt',
        toolsEnabled: ['image_analysis'],
        workspaceConfig: {},
        isActive: true,
        isDefault: false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        metadata: {}
      };

      const testRunner = OpenAISDKAgentRunner.fromAgentConfig(agentConfig, 'test-api-key', mockDependencies);

      assert.equal(testRunner.getStatus(), 'idle');
    });
  });

  describe('run', () => {
    it('should successfully run agent with assets', async () => {
      const input = {
        childId: 'child_123',
        bookId: 'book_456',
        assets: [
          {
            id: 'asset_1',
            title: '阳光下的笑容',
            type: 'image',
            filePath: '/path/to/image1.jpg',
            description: '孩子在阳光下开心地笑着'
          },
          {
            id: 'asset_2',
            title: '和朋友玩耍',
            type: 'image',
            filePath: '/path/to/image2.jpg',
            description: '孩子和朋友们一起玩耍'
          }
        ],
        instructions: '请创作一本温馨的成长记录书',
        outputFormat: 'json' as const
      };

      const result = await runner.run(input);

      assert.equal(result.success, true);
      assert.ok(result.bookData);
      assert.equal(result.bookData.title, '小明的快乐时光');
      assert.equal(result.bookData.pages.length, 2);
      assert.equal(result.bookData.pages[0].title, '阳光下的笑容');
      assert.deepEqual(result.bookData.pages[0].assets, ['asset_1']);
      assert.ok(result.executionLog);
      assert.ok(result.executionLog.length > 0);
      assert.equal(result.tokensUsed, 150);
      assert.ok(result.duration);
    });

    it('should handle empty assets', async () => {
      const input = {
        childId: 'child_123',
        assets: [],
        outputFormat: 'json' as const
      };

      const result = await runner.run(input);

      assert.equal(result.success, true);
      assert.ok(result.bookData);
      assert.equal(result.bookData.title, '小明的快乐时光');
    });

    it('should handle API errors', async () => {
      // Mock API error
      mockRunBehavior = async () => {
        await new Promise(resolve => setTimeout(resolve, 1));
        throw new Error('API rate limit exceeded');
      };

      const input = {
        childId: 'child_123',
        assets: [],
        outputFormat: 'json' as const
      };

      const result = await runner.run(input);

      assert.equal(result.success, false);
      assert.equal(result.error, 'API rate limit exceeded');
      assert.ok(result.executionLog);
      assert.ok(result.duration !== undefined);
    });

    it('should handle invalid JSON response', async () => {
      // Mock invalid JSON response
      mockRunBehavior = async () => {
        await new Promise(resolve => setTimeout(resolve, 1));
        return {
          messages: [
            {
              role: 'user',
              content: 'test'
            },
            {
              role: 'assistant',
              content: 'This is not valid JSON content'
            }
          ],
          usage: {
            totalTokens: 50,
            promptTokens: 30,
            completionTokens: 20
          }
        };
      };

      const input = {
        childId: 'child_123',
        assets: [],
        outputFormat: 'json' as const
      };

      const result = await runner.run(input);

      assert.equal(result.success, true);
      assert.ok(result.bookData);
      assert.equal(result.bookData.title, 'child_123的成长记录');
      assert.equal(result.bookData.metadata.fallbackGeneration, true);
    });

    it('should handle malformed JSON in response', async () => {
      // Mock malformed JSON response
      mockRunBehavior = async () => {
        await new Promise(resolve => setTimeout(resolve, 1));
        return {
          messages: [
            {
              role: 'user',
              content: 'test'
            },
            {
              role: 'assistant',
              content: '```json\n{ "title": "Test", "invalid": json }\n```'
            }
          ],
          usage: {
            totalTokens: 50,
            promptTokens: 30,
            completionTokens: 20
          }
        };
      };

      const input = {
        childId: 'child_123',
        assets: [],
        outputFormat: 'json' as const
      };

      const result = await runner.run(input);

      assert.equal(result.success, false);
      assert.ok(result.error.includes('Failed to parse JSON response'));
    });

    it('should handle empty response', async () => {
      // Mock empty response
      mockRunBehavior = async () => {
        await new Promise(resolve => setTimeout(resolve, 1));
        return {
          messages: [
            {
              role: 'user',
              content: 'test'
            }
            // No assistant message - this should trigger "No assistant response found"
          ],
          usage: {
            totalTokens: 10,
            promptTokens: 10,
            completionTokens: 0
          }
        };
      };

      const input = {
        childId: 'child_123',
        assets: [],
        outputFormat: 'json' as const
      };

      const result = await runner.run(input);

      assert.equal(result.success, false);
      assert.equal(result.error, 'No assistant response found in agent result');
    });

    it('should handle tool calls in response', async () => {
      // Mock response with tool calls
      mockRunBehavior = async () => {
        await new Promise(resolve => setTimeout(resolve, 1));
        return {
          messages: [
            {
              role: 'user',
              content: 'test'
            },
            {
              role: 'assistant',
              content: `\`\`\`json
{
  "title": "工具辅助创作",
  "content": "使用工具分析后的创作内容",
  "pages": [
    {
      "title": "分析结果",
      "content": "基于图片分析的故事内容",
      "assets": ["asset_1"]
    }
  ],
  "metadata": {
    "theme": "工具辅助",
    "pageCount": 1
  }
}
\`\`\``,
              tool_calls: [{
                id: 'call_123',
                type: 'function',
                function: {
                  name: 'analyze_image',
                  arguments: '{"image_path": "/path/to/image.jpg"}'
                }
              }]
            }
          ],
          usage: {
            totalTokens: 200,
            promptTokens: 120,
            completionTokens: 80
          }
        };
      };

      const input = {
        childId: 'child_123',
        assets: [{
          id: 'asset_1',
          title: 'Test Image',
          type: 'image',
          filePath: '/path/to/image.jpg'
        }],
        outputFormat: 'json' as const
      };

      const result = await runner.run(input);

      assert.equal(result.success, true);
      assert.ok(result.bookData);
      assert.equal(result.bookData.title, '工具辅助创作');
    });
  });

  describe('cancel', () => {
    it('should cancel running agent', async () => {
      // Mock long-running agent run
      mockRunBehavior = async (agent: any, input: any, options?: any) => {
        return new Promise((resolve, reject) => {
          const timeout = setTimeout(() => {
            resolve({
              messages: [
                { role: 'user', content: typeof input === 'string' ? input : input.messages[0].content },
                { role: 'assistant', content: 'Response' }
              ],
              usage: { totalTokens: 10 }
            });
          }, 1000);

          options?.signal?.addEventListener('abort', () => {
            clearTimeout(timeout);
            const error = new Error('Request aborted');
            error.name = 'AbortError';
            reject(error);
          });
        });
      };

      const input = {
        childId: 'child_123',
        assets: [],
        outputFormat: 'json' as const
      };

      // Start the run
      const runPromise = runner.run(input);

      // Cancel after a short delay
      setTimeout(() => {
        runner.cancel();
      }, 100);

      const result = await runPromise;

      assert.equal(result.success, false);
      assert.equal(result.error, 'Agent run was cancelled');
      assert.equal(runner.getStatus(), 'cancelled');
    });
  });

  describe('getStatus', () => {
    it('should return current status', () => {
      assert.equal(runner.getStatus(), 'idle');
    });

    it('should update status during run', async () => {
      const input = {
        childId: 'child_123',
        assets: [],
        outputFormat: 'json' as const
      };

      const runPromise = runner.run(input);

      // Status should be running during execution
      assert.equal(runner.getStatus(), 'running');

      await runPromise;

      // Status should be completed after successful run
      assert.equal(runner.getStatus(), 'completed');
    });
  });
});
