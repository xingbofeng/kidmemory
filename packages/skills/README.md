# @kidmemory/skills

Skill source package for KidMemory.

## Layout

- `skill-registry.json`: Skill metadata and entry points.
- `skills/<id>/`: Skill files.
- `scripts/validate-skills.mjs`: Registry and filesystem validation.
- `scripts/package-skills.mjs`: Build distributable manifest.

## Validate

```bash
cd packages/skills
node scripts/validate-skills.mjs
```

## Package

```bash
cd packages/skills
node scripts/package-skills.mjs
```
