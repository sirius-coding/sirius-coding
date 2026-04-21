#!/usr/bin/env node
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const [intentPath, layoutPath, outputPath] = process.argv.slice(2);

if (!intentPath || !layoutPath || !outputPath) {
  console.error("Usage: node scripts/diagram/render-prompt.mjs <input.intent.json> <input.layout.plan.json> <output.image-prompt.md>");
  process.exit(2);
}

const intent = JSON.parse(readFileSync(resolve(intentPath), "utf8"));
const layout = JSON.parse(readFileSync(resolve(layoutPath), "utf8"));
writeFileSync(resolve(outputPath), renderPrompt(intent, layout), "utf8");

function renderPrompt(intent, layout) {
  const branchGroup = intent.parallel_groups[0];
  const nodes = intent.nodes.map((node) => `- ${node.id}. ${node.title}: ${node.subtitle} (${node.role})`).join("\n");
  return `# Image Prompt: ${intent.title}

生成一张高质量流程图：

- 风格：ProcessOn / 企业流程图 / 干净信息图
- 主题：${intent.description}
- 布局：主链垂直居中，节点顺序为 ${intent.main_chain.join(" -> ")}
- 分支：从 ${branchGroup.source} 横向展开为 ${branchGroup.columns.join(" / ")}，所有分支等宽、顶部对齐、位于虚线分组框内
- 汇聚：所有分支向 ${branchGroup.merge} 汇聚，汇聚节点居中
- 反馈：${intent.feedback_loops.map((loop) => `${loop.from} -> ${loop.to} 反馈回路走外围`).join("；")}
- 视觉：白底，低饱和配色，圆角卡片，正交箭头，清晰阴影，中文文本清晰，无截断
- 版式约束：主链一眼可读，分支横向排列，箭头不交叉，反馈回路不干扰主体
- 输出比例：竖向长图，适合 README 首页展示

## 节点文本

${nodes}

## 质量自检

- 主链是否一眼可读：${layout.quality_checks.main_chain_readable ? "是" : "否"}
- 分支是否对齐：${layout.quality_checks.branches_aligned ? "是" : "否"}
- 是否有箭头交叉：${layout.quality_checks.arrow_crossings ? "是" : "否"}
- 是否存在布局拥挤：${layout.quality_checks.crowded ? "是" : "否"}
- 反馈回路是否干扰主体：${layout.quality_checks.feedback_outer_route ? "否，走外围" : "是"}
`;
}
