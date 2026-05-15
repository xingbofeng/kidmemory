import fs from "node:fs/promises";
import path from "node:path";
import { pathToFileURL } from "node:url";

const root = path.resolve(process.cwd(), process.argv[2] ?? "src");
const files = await collectTypescriptFiles(root);

for (const file of files) {
  if (path.basename(file) === "main.ts") continue;
  if (path.basename(file) === "global-exception.filter.ts") continue;
  if (path.basename(file) === "request-logging.middleware.ts") continue;
  await import(pathToFileURL(file).href);
}

async function collectTypescriptFiles(dir) {
  const files = [];
  for (const entry of await fs.readdir(dir, { withFileTypes: true })) {
    const fullPath = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      files.push(...await collectTypescriptFiles(fullPath));
    } else if (entry.isFile() && entry.name.endsWith(".ts")) {
      files.push(fullPath);
    }
  }
  return files.sort();
}
