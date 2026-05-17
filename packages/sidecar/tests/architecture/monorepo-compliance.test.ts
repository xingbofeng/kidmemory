import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import test from "node:test";

const sidecarRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..", "..");
const repoRoot = path.resolve(sidecarRoot, "..", "..");

test("deploy and desktop paths target the correct services after backend rename", () => {
  const deployWorkflow = fs.readFileSync(path.join(repoRoot, ".github", "workflows", "deploy-tencent.yml"), "utf8");
  assert.match(deployWorkflow, /packages\/cloud-api/);
  assert.doesNotMatch(deployWorkflow, /packages\/backend/);

  const bundleScript = fs.readFileSync(
    path.join(repoRoot, "packages", "desktop", "macos", "Scripts", "bundle-sidecar-for-release.sh"),
    "utf8",
  );
  assert.match(bundleScript, /packages\/sidecar/);
  assert.doesNotMatch(bundleScript, /packages\/backend/);

  const pbxproj = fs.readFileSync(
    path.join(repoRoot, "packages", "desktop", "macos", "Runner.xcodeproj", "project.pbxproj"),
    "utf8",
  );
  assert.doesNotMatch(pbxproj, /\/backend\//);
  assert.match(pbxproj, /\/sidecar\//);

  const launcher = fs.readFileSync(
    path.join(repoRoot, "packages", "desktop", "lib", "core", "sidecar", "sidecar_launcher.dart"),
    "utf8",
  );
  assert.doesNotMatch(launcher, /packages\/backend/);
  assert.match(launcher, /packages\/sidecar/);
});

test("core CI jobs explicitly run lint, test, and type-check for sidecar and cloud-api", () => {
  const ciWorkflow = fs.readFileSync(path.join(repoRoot, ".github", "workflows", "ci.yml"), "utf8");
  assert.match(ciWorkflow, /working-directory:\s+packages\/sidecar/);
  assert.match(ciWorkflow, /working-directory:\s+packages\/cloud-api/);
  assert.match(ciWorkflow, /npm run lint/);
  assert.match(ciWorkflow, /npm (?:run test|test)/);
  assert.match(ciWorkflow, /npm run type-check/);
});

test("sidecar integration script covers contracts, http and integration directories", () => {
  const packageJson = JSON.parse(fs.readFileSync(path.join(sidecarRoot, "package.json"), "utf8")) as {
    scripts?: Record<string, string>;
  };
  const integrationScript = packageJson.scripts?.["test:integration"] ?? "";
  assert.match(integrationScript, /tests\/contracts\//);
  assert.match(integrationScript, /tests\/http\//);
  assert.match(integrationScript, /tests\/integration\//);
});

test("acceptance workflow runs smoke tests via npx tsx", () => {
  const acceptanceWorkflow = fs.readFileSync(path.join(repoRoot, ".github", "workflows", "acceptance.yml"), "utf8");
  assert.match(acceptanceWorkflow, /run:\s+npx tsx --test tests\/http\/router\.smoke\.test\.ts/);
});

test("production pm2 ecosystem targets cloud-api runtime after service split", () => {
  const ecosystemConfig = fs.readFileSync(path.join(repoRoot, "ecosystem.config.js"), "utf8");
  assert.match(ecosystemConfig, /packages\/cloud-api\/dist\/main\.js/);
  assert.doesNotMatch(ecosystemConfig, /packages\/sidecar\/dist\/main\.js/);
  assert.doesNotMatch(ecosystemConfig, /name:\s*['"]kidmemory-web['"]/);
});

test("deploy workflow bootstraps node runtime before cloud-api npm commands", () => {
  const deployWorkflow = fs.readFileSync(path.join(repoRoot, ".github", "workflows", "deploy-tencent.yml"), "utf8");
  assert.match(deployWorkflow, /command -v npm/);
  assert.match(deployWorkflow, /command -v node/);
  assert.match(
    deployWorkflow,
    /apt-get install -y nodejs|yum install -y nodejs|dnf install -y nodejs|apk add --no-cache nodejs npm/,
  );
});
