#!/usr/bin/env node
import { access, readFile } from "node:fs/promises";
import path from "node:path";

function isNonEmptyString(value) {
  return typeof value === "string" && value.trim().length > 0;
}

export async function validateSkillsRegistry(options = {}) {
  const rootDir = options.rootDir ? path.resolve(options.rootDir) : path.resolve(process.cwd());
  const registryPath = path.join(rootDir, "skill-registry.json");
  const errors = [];

  let registry;
  try {
    const raw = await readFile(registryPath, "utf8");
    registry = JSON.parse(raw);
  } catch (error) {
    return {
      ok: false,
      errors: [`Failed to read registry: ${registryPath} (${error instanceof Error ? error.message : String(error)})`],
      skills: [],
    };
  }

  const skills = Array.isArray(registry?.skills) ? registry.skills : [];
  if (!Array.isArray(registry?.skills)) {
    errors.push("skills must be an array");
  }

  for (const [index, skill] of skills.entries()) {
    const prefix = `skills[${index}]`;

    if (!isNonEmptyString(skill?.id)) {
      errors.push(`${prefix}.id is required`);
    }
    if (!isNonEmptyString(skill?.source)) {
      errors.push(`${prefix}.source is required`);
    }
    if (!isNonEmptyString(skill?.version)) {
      errors.push(`${prefix}.version is required`);
    }
    if (!isNonEmptyString(skill?.path)) {
      errors.push(`${prefix}.path is required`);
    }
    if (!isNonEmptyString(skill?.entry)) {
      errors.push(`${prefix}.entry is required`);
    }

    if (isNonEmptyString(skill?.path) && isNonEmptyString(skill?.entry)) {
      const fullEntry = path.join(rootDir, skill.path, skill.entry);
      try {
        await access(fullEntry);
      } catch {
        errors.push(`${prefix} entry file does not exist: ${fullEntry}`);
      }
    }
  }

  return {
    ok: errors.length === 0,
    errors,
    skills,
  };
}

async function main() {
  const result = await validateSkillsRegistry();
  if (!result.ok) {
    for (const error of result.errors) {
      console.error(`- ${error}`);
    }
    process.exitCode = 1;
    return;
  }
  console.log(`Validated ${result.skills.length} skills.`);
}

if (import.meta.url === `file://${process.argv[1]}`) {
  await main();
}
