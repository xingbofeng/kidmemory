---
name: kidmemory-video-demo-director
description: Generate a KidMemory memoir video artifact from workspace input files using available video tools or MCP capabilities.
---

# KidMemory Video Demo Director

Use this skill when the user asks to generate a KidMemory memoir video inside an agent workspace.

## Workspace Contract

- Read `.kidmemory/runtime.md` first.
- Treat `input/` as read-only context.
- Use `work/` for scripts, scene plans, prompts, manifests, and temporary files.
- Write final artifacts only to `output/`.

## Required Output

Create a real non-empty MP4 file:

- `output/video.mp4`

Use HyperFrames for the first demo smoke test. Do not hand-write a fake MP4.

## Minimal Smoke Render Steps

Use these exact steps unless the user asks for a richer video:

1. Read `input/notes.md` and `input/assets/scene-001.txt`.
2. Run `npx --yes hyperframes init work/kidmemory-video --example blank --non-interactive`.
3. Replace `work/kidmemory-video/index.html` with a warm 3-second HyperFrames composition:
   - `data-composition-id="main"`
   - `data-duration="3"`
   - text based on the input scene
   - soft gradient background
   - paused GSAP timeline registered as `window.__timelines["main"]`
4. Run `cd work/kidmemory-video && npm run render -- --output ../../output/video.mp4 --quality draft`.
5. Verify `output/video.mp4` exists and is non-empty before finishing.

When using `run_command`, pass shell commands like this:

```json
{
  "command": "bash",
  "args": ["-lc", "cd work/kidmemory-video && npm run render -- --output ../../output/video.mp4 --quality draft"]
}
```

If HyperFrames render fails, write the error summary to `work/render-notes.md` and fail clearly instead of writing a placeholder.

## Suggested Intermediate Files

- `work/video-plan.json`
- `work/kidmemory-video/index.html`
- `work/render-notes.md`

## Style

- Warm family memory tone.
- Soft light, watercolor texture, gentle camera movement.
- Base scenes on `input/notes.md` and `input/assets/`.
