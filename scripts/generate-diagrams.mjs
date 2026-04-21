#!/usr/bin/env node
import { spawnSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDir = dirname(fileURLToPath(import.meta.url));
const buildAll = join(scriptDir, "diagram", "build-all.mjs");
const result = spawnSync(process.execPath, [buildAll, ...process.argv.slice(2)], {
  stdio: "inherit",
});

process.exit(result.status || 0);
