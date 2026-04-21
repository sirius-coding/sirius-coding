#!/usr/bin/env node
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const [inputPath, outputPath] = process.argv.slice(2);

if (!inputPath || !outputPath) {
  console.error("Usage: node scripts/template/sync-template-readme.mjs <source-readme> <output-readme>");
  process.exit(2);
}

const source = readFileSync(resolve(inputPath), "utf8");
const template = source
  .replace("# Sirius Coding Evolution Station", "# Sirius Evolution Station Template")
  .replace(/\n  <img src="https:\/\/img\.shields\.io\/badge\/Java-21-[^"]+" alt="Java 21" \/>/, "")
  .replace(/\n  <img src="https:\/\/img\.shields\.io\/badge\/Spring%20AI-RAG%20%7C%20Agent-[^"]+" alt="Spring AI RAG Agent" \/>/, "")
  .replace('<a href="#项目执行层">项目执行层</a>', '<a href="#使用方式">使用方式</a>')
  .replace(
    /这个仓库不只是 GitHub 主页，也不只是项目合集。它是 `sirius-coding` 的公开工作站根仓库，负责把长期有效的协作方式显式化、资产化、可检查化。\n\nThis repository is not only a GitHub profile README and not only a project collection. It is the public workspace root for `sirius-coding`, designed to make durable collaboration patterns explicit, reusable, and auditable\./,
    "这个模板库用于创建新的进化式开发工作站。它只包含可复用的根工作站规则、文档、skills、脚本、审计和图形能力，不包含当前主仓库的业务项目实现。\n\nThis template repository creates a reusable evolution station. It contains root workstation rules, docs, skills, scripts, audits, and diagram capabilities, but excludes the current main workspace's business project implementations.",
  )
  .replace(/\| \[Cloud Deploy Checklist\]\(\.\/docs\/sirius-xz-agent-cloud-deploy-checklist\.md\) \| .* \|\n/, "")
  .replace(/## 项目执行层[\s\S]*?## 安全边界/, "## 使用方式\n\n从这个模板创建新仓库后，先按实际项目补充 `projects/` 或连接独立业务仓库。模板只提供工作站控制层，不预置业务实现。\n\n1. 阅读 `AGENTS.md` 和 `specs/workspace/evolution-handbook.md`。\n2. 复制 `docs/ops/environment-registry.private.example.yaml` 为本地私有覆盖文件。\n3. 运行 `./scripts/root-repo-structure-audit.sh`。\n4. 按需要新增项目执行层，并把可复用经验沉淀回根层。\n\n## 安全边界")
  .replace(
    "4. 逐步把重复检查升级为脚本、workflow，再考虑插件化。",
    "4. 逐步把重复检查升级为脚本、workflow，再考虑插件化。\n5. 按 SemVer 大版本从主工作站同步可复用模板能力。",
  );

writeFileSync(resolve(outputPath), template, "utf8");
