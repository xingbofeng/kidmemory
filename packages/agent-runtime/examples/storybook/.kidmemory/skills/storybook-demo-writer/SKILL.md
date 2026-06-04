---
name: kidmemory-storybook-demo-writer
description: Generate a warm Chinese storybook draft from KidMemory workspace input files.
---

# KidMemory Storybook Demo Writer

Use this skill when the user asks to generate a KidMemory storybook draft inside an agent workspace.

## Workspace Contract

- Read `.kidmemory/runtime.md` first.
- Treat `input/` as read-only context.
- Use `work/` for intermediate notes if needed.
- Write final artifacts only to `output/`.
- Use the available file tools or sandbox filesystem/shell capability, depending on the current executor.

## Required Output

You must write both files before finishing:

- `output/book.json`
- `output/book.html`

`book.json` should contain a four-page Chinese storybook draft:

```json
{
  "title": "string",
  "pages": [
    {
      "page": 1,
      "text": "string",
      "visualPrompt": "string"
    }
  ]
}
```

`book.json` must be strict valid JSON:

- Exactly 4 items in `pages`.
- Escape any quote characters inside strings.
- Do not wrap the JSON in Markdown fences.
- Do not add comments or trailing commas.

`book.html` should be a readable preview of the same story.

## Completion Checklist

- Create `output/book.json`.
- Create `output/book.html`.
- Verify both files exist and are non-empty.
- Verify `output/book.json` is parseable JSON before claiming success.
- Do not claim success until both files are present.

## Style

- Warm, childlike, and suitable for parent-child reading.
- Use the child artwork and notes from `input/notes.md` and `input/assets/`.
- Do not invent private family facts that are not present in the input files.
