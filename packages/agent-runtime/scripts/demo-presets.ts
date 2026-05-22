export type DemoPreset = "storybook" | "video";

export type PreparePresetConfig = {
  notes: string;
  assets: Record<string, string>;
};

export type RunPresetConfig = {
  requiredOutputFiles: string[];
  validateOutput?: "storybook";
  prompt: string;
};

export const PREPARE_PRESETS: Record<DemoPreset, PreparePresetConfig> = {
  storybook: {
    notes: `# Demo Input

这里有一些 KidMemory 绘本生成阶段会看到的上下文材料。

- 目标：生成一本 4 页中文儿童绘本草稿。
- 输出：写入 output/book.json 和 output/book.html。
- 风格：温暖、童趣、适合亲子阅读。
`,
    assets: {
      "asset-001.txt": "标题：彩色火箭\n描述：孩子画了一艘飞向星星的彩色火箭。\n",
      "asset-002.txt": "标题：春天的花园\n描述：孩子用蜡笔画了太阳、花朵和一只小狗。\n",
    },
  },
  video: {
    notes: `# Memoir Video Demo Input

这里有一些 KidMemory 视频生成阶段会看到的上下文材料。

- 目标：生成一段温暖的纪念视频。
- 输出：写入或注册 output/video.mp4。
- 风格：watercolor、soft light、family memory。
`,
    assets: {
      "scene-001.txt": "场景：孩子作品组成的温暖回忆墙\n镜头：缓慢推进，最后停在彩色火箭画上\n",
    },
  },
};

export const RUN_PRESETS: Record<DemoPreset, RunPresetConfig> = {
  storybook: {
    requiredOutputFiles: ["output/book.json", "output/book.html"],
    validateOutput: "storybook",
    prompt:
      "阅读 input/notes.md 和 input/assets，生成一本 4 页中文儿童绘本草稿，并写入 output/book.json 和 output/book.html。output/book.json 必须是严格合法 JSON，字符串内引号必须转义，pages 必须正好 4 页。",
  },
  video: {
    requiredOutputFiles: ["output/video.mp4"],
    prompt: "阅读 input/notes.md 和 input/assets，生成一段温暖纪念视频，并写入或注册 output/video.mp4",
  },
};
