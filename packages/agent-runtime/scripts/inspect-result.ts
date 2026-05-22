import { collectWorkspaceInspection, parseArgs, requireStringArg, resolveWorkspace } from "./lib.ts";

const args = parseArgs();
const workspaceDir = resolveWorkspace(requireStringArg(args, "workspace"));
const inspection = await collectWorkspaceInspection(workspaceDir);

console.log("Artifacts");
for (const filePath of inspection.artifacts) {
  console.log(`- ${filePath}`);
}

console.log("\nEvents");
console.log(`- events: ${inspection.events.count}`);
if (inspection.events.logPath) {
  console.log(`- log: ${inspection.events.logPath}`);
}

console.log("\nSessions");
for (const session of inspection.sessions) {
  console.log(`- ${session.filePath}: ${session.eventCount} events`);
  console.log(`  status: ${session.summary.status}`);
  console.log(`  latestRunId: ${session.summary.latestRunId ?? "n/a"}`);
  console.log(`  artifactCount: ${session.summary.artifactCount}`);
  if (session.loopControl) {
    console.log(`  loopControl: ${session.loopControl.decision} (${session.loopControl.reason})`);
  }
}

console.log("\nTraces");
for (const trace of inspection.traces) {
  console.log(`- ${trace.provider}: traceId=${trace.traceId ?? "n/a"} groupId=${trace.groupId ?? "n/a"}`);
}
