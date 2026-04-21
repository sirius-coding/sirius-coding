#!/usr/bin/env node
import { mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { basename, dirname, join, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const args = process.argv.slice(2);
const checkMode = args.includes("--check");
const sources = args.filter((arg) => arg !== "--check");

if (sources.length === 0) {
  console.error("Usage: node scripts/diagram/build-all.mjs [--check] <source.diagram.json> [...]");
  process.exit(2);
}

let failed = false;

for (const source of sources) {
  const sourcePath = resolve(source);
  const outputs = outputPaths(sourcePath);
  if (checkMode) {
    checkPipeline(sourcePath, outputs);
  } else {
    runPipeline(sourcePath, outputs);
    console.log(`Generated ${relative(outputs.svg)}`);
    console.log(`Generated ${relative(outputs.prompt)}`);
  }
}

process.exit(failed ? 1 : 0);

function checkPipeline(sourcePath, outputs) {
  const tempDir = mkdtempSync(join(tmpdir(), "sirius-diagram-"));
  const tempOutputs = {
    intent: join(tempDir, basename(outputs.intent)),
    layout: join(tempDir, basename(outputs.layout)),
    svg: join(tempDir, basename(outputs.svg)),
    prompt: join(tempDir, basename(outputs.prompt)),
  };

  try {
    runPipeline(sourcePath, tempOutputs);
    compare(outputs.intent, tempOutputs.intent);
    compare(outputs.layout, tempOutputs.layout);
    compare(outputs.svg, tempOutputs.svg);
    compare(outputs.prompt, tempOutputs.prompt);
  } finally {
    rmSync(tempDir, { recursive: true, force: true });
  }
}

function runPipeline(sourcePath, outputs) {
  run("build-intent.mjs", sourcePath, outputs.intent);
  run("build-layout.mjs", outputs.intent, outputs.layout);
  run("render-svg.mjs", outputs.layout, outputs.svg);
  run("render-prompt.mjs", outputs.intent, outputs.layout, outputs.prompt);
}

function run(scriptName, ...scriptArgs) {
  const result = spawnSync(process.execPath, [join(scriptDir, scriptName), ...scriptArgs], {
    encoding: "utf8",
    stdio: ["ignore", "pipe", "pipe"],
  });
  if (result.status !== 0) {
    process.stderr.write(result.stdout);
    process.stderr.write(result.stderr);
    process.exit(result.status || 1);
  }
}

function compare(expectedPath, actualPath) {
  const expected = readFileSync(expectedPath, "utf8");
  const actual = readFileSync(actualPath, "utf8");
  if (expected !== actual) {
    console.error(`Stale generated diagram file: ${relative(expectedPath)}`);
    failed = true;
  }
}

function outputPaths(sourcePath) {
  const dir = dirname(sourcePath);
  const base = basename(sourcePath, ".diagram.json");
  return {
    intent: join(dir, `${base}.intent.json`),
    layout: join(dir, `${base}.layout.plan.json`),
    svg: join(dir, `${base}.svg`),
    prompt: join(dir, `${base}.image-prompt.md`),
  };
}

function relative(path) {
  const cwd = process.cwd();
  return path.startsWith(cwd) ? path.slice(cwd.length + 1) : path;
}
