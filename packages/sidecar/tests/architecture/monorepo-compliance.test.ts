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

test("acceptance gate is folded into the main CI workflow", () => {
  const acceptanceWorkflowPath = path.join(repoRoot, ".github", "workflows", "acceptance.yml");
  assert.equal(fs.existsSync(acceptanceWorkflowPath), false);

  const ciWorkflow = fs.readFileSync(path.join(repoRoot, ".github", "workflows", "ci.yml"), "utf8");
  assert.match(ciWorkflow, /name:\s+acceptance contract\/integration\/smoke/);
  assert.match(ciWorkflow, /needs:[\s\S]*agent_runtime[\s\S]*protocol[\s\S]*sidecar[\s\S]*cloud_api[\s\S]*web_companion[\s\S]*desktop_flutter/);
  assert.match(ciWorkflow, /run:\s+npx tsx --test tests\/http\/router\.smoke\.test\.ts/);
});

test("production pm2 ecosystem targets cloud-api runtime after service split", () => {
  const ecosystemConfig = fs.readFileSync(path.join(repoRoot, "ecosystem.config.js"), "utf8");
  assert.match(ecosystemConfig, /packages\/cloud-api\/dist\/main\.js/);
  assert.doesNotMatch(ecosystemConfig, /packages\/sidecar\/dist\/main\.js/);
  assert.doesNotMatch(ecosystemConfig, /name:\s*['"]kidmemory-web['"]/);
});

test("deploy workflow uses Docker Compose instead of PM2 for cloud-api", () => {
  const deployWorkflow = fs.readFileSync(path.join(repoRoot, ".github", "workflows", "deploy-tencent.yml"), "utf8");
  assert.match(deployWorkflow, /docker compose/);
  assert.match(deployWorkflow, /deploy\/tencent\/cloud-api\.compose\.yml/);
  assert.match(deployWorkflow, /docker compose[\s\S]*run --rm cloud-api npx prisma migrate deploy/);
  assert.match(deployWorkflow, /docker compose[\s\S]*up -d --remove-orphans cloud-api/);
  assert.match(deployWorkflow, /command -v docker/);
  assert.match(deployWorkflow, /install_docker_engine\(\)/);
  assert.match(deployWorkflow, /docker-ce docker-ce-cli containerd\.io docker-buildx-plugin docker-compose-plugin/);
  assert.match(deployWorkflow, /systemctl enable --now docker/);
  assert.doesNotMatch(deployWorkflow, /pm2/);
  assert.match(deployWorkflow, /source "\$PROJECT_PATH\/\.env"/);
  assert.match(deployWorkflow, /source "\$PROJECT_PATH\/packages\/cloud-api\/\.env"/);
  assert.match(deployWorkflow, /TENCENT_PUBLIC_PORT="\$\{\{ secrets\.TENCENT_PUBLIC_PORT \|\| 3000 \}\}"/);
  assert.match(deployWorkflow, /open_public_port\(\)/);
  assert.match(deployWorkflow, /ufw allow "\$TENCENT_PUBLIC_PORT\/tcp"/);
  assert.match(deployWorkflow, /firewall-cmd --permanent --add-port="\$TENCENT_PUBLIC_PORT\/tcp"/);
  assert.match(deployWorkflow, /verify_local_health\(\)/);
  assert.match(deployWorkflow, /curl --retry 30 --retry-all-errors --retry-delay 2[\s\S]*"http:\/\/127\.0\.0\.1:\$TENCENT_PUBLIC_PORT\/health"/);
  assert.match(deployWorkflow, /docker compose -f "\$COMPOSE_FILE" ps/);
  assert.match(deployWorkflow, /docker compose -f "\$COMPOSE_FILE" logs --tail=200 cloud-api/);
  assert.match(deployWorkflow, /name:\s+Public smoke from GitHub runner/);
  assert.match(deployWorkflow, /public_smoke_base_url="http:\/\/\$\{TENCENT_HOST\}:\$\{TENCENT_PUBLIC_PORT\}"/);
  assert.match(deployWorkflow, /curl[\s\S]*"\$public_smoke_base_url\/health"/);
  assert.match(deployWorkflow, /curl[\s\S]*"\$public_smoke_base_url\/docs\/openapi\.json"/);
  assert.doesNotMatch(deployWorkflow, /packages\/web|VERCEL|landing/i);
});

test("landing page deploy stays on Vercel and waits for CI success", () => {
  const vercelWorkflow = fs.readFileSync(path.join(repoRoot, ".github", "workflows", "deploy-vercel.yml"), "utf8");
  assert.match(vercelWorkflow, /workflow_run:[\s\S]*workflows:\s+\["CI"\][\s\S]*branches:[\s\S]*main/);
  assert.match(vercelWorkflow, /github\.event\.workflow_run\.conclusion == 'success'/);
  assert.match(vercelWorkflow, /VERCEL_DEPLOY_HOOK_URL/);
});

test("cloud-api Docker deployment assets build from the monorepo context", () => {
  const dockerfile = fs.readFileSync(path.join(repoRoot, "packages", "cloud-api", "Dockerfile"), "utf8");
  assert.match(dockerfile, /FROM node:22/);
  assert.match(dockerfile, /COPY tsconfig\.nest\.json \.\//);
  assert.match(dockerfile, /COPY tsconfig\.node\.json \.\//);
  assert.match(dockerfile, /COPY tsconfig\.base\.json \.\//);
  assert.match(dockerfile, /apt-get install -y --no-install-recommends[\s\S]*openssl/);
  assert.match(dockerfile, /packages\/protocol/);
  assert.match(dockerfile, /packages\/cloud-api/);
  assert.match(dockerfile, /npm run build:prod/);
  assert.match(dockerfile, /npm ci --include=dev/);
  assert.match(dockerfile, /npm ci --include=dev[\s\S]*npm run prisma:generate[\s\S]*npm cache clean --force/);
  assert.match(dockerfile, /COPY --from=builder \/app\/packages\/cloud-api\/prisma\.config\.ts \.\/prisma\.config\.ts/);
  assert.match(dockerfile, /CMD \["node", "dist\/main\.js"\]/);

  const compose = fs.readFileSync(path.join(repoRoot, "deploy", "tencent", "cloud-api.compose.yml"), "utf8");
  assert.match(compose, /cloud-api:/);
  assert.match(compose, /dockerfile: packages\/cloud-api\/Dockerfile/);
  assert.match(compose, /env_file:[\s\S]*\.deploy\/cloud-api\.env/);
  assert.match(compose, /network_mode:\s+"host"/);
  assert.doesNotMatch(compose, /ports:/);
});

test("desktop release builds a CI-gated macOS artifact for landing downloads", () => {
  const releaseWorkflow = fs.readFileSync(path.join(repoRoot, ".github", "workflows", "desktop-release.yml"), "utf8");
  assert.match(releaseWorkflow, /workflow_run:[\s\S]*workflows:\s+\["CI"\][\s\S]*branches:[\s\S]*main/);
  assert.match(releaseWorkflow, /github\.event\.workflow_run\.conclusion == 'success'/);
  assert.match(releaseWorkflow, /Prepare bundled PostgreSQL runtime/);
  assert.match(releaseWorkflow, /brew install postgresql@16 pgvector/);
  assert.match(releaseWorkflow, /third_party\/postgres\/macos/);
  assert.match(releaseWorkflow, /vector\.control/);
  assert.match(releaseWorkflow, /find -L "\$PGVECTOR_PREFIX" "\$PG_PREFIX"/);
  assert.match(releaseWorkflow, /flutter config --no-enable-swift-package-manager/);
  assert.match(releaseWorkflow, /KidMemory-macos-arm64-unsigned\.tar\.gz/);
  assert.match(releaseWorkflow, /softprops\/action-gh-release@v2/);
  assert.match(releaseWorkflow, /tag_name:\s+desktop-alpha-latest/);
});
