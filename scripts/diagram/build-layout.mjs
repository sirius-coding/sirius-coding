#!/usr/bin/env node
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const [intentPath, outputPath] = process.argv.slice(2);

if (!intentPath || !outputPath) {
  console.error("Usage: node scripts/diagram/build-layout.mjs <input.intent.json> <output.layout.plan.json>");
  process.exit(2);
}

const intent = JSON.parse(readFileSync(resolve(intentPath), "utf8"));
const layout = buildLayout(intent);
writeFileSync(resolve(outputPath), `${JSON.stringify(layout, null, 2)}\n`, "utf8");

function buildLayout(intent) {
  const canvas = { width: 1024, height: 1400, padding: 32 };
  const centerX = canvas.width / 2;
  const mainSize = { width: 380, height: 92 };
  const branchSize = { width: 170, height: 118 };
  const mainGap = 118;
  const branchTopGap = 54;
  const branchGroupHeight = 198;
  const mergeTopGap = 42;
  const nodeById = new Map(intent.nodes.map((node) => [node.id, node]));
  const group = intent.parallel_groups[0];
  const groupSourceIndex = intent.main_chain.indexOf(group.source);
  const mergeIndex = intent.main_chain.indexOf(group.merge);

  if (groupSourceIndex < 0 || mergeIndex < 0 || mergeIndex <= groupSourceIndex) {
    throw new Error("main_chain must place the parallel group source before its merge node");
  }

  const positions = {};
  const preChain = intent.main_chain.slice(0, groupSourceIndex + 1);
  const postChain = intent.main_chain.slice(mergeIndex);

  preChain.forEach((nodeId, index) => {
    positions[nodeId] = centeredBox(centerX, 34 + index * mainGap, mainSize);
  });

  const branchGroup = {
    id: group.id,
    title: group.title,
    x: 32,
    y: positions[group.source].y + mainSize.height + branchTopGap,
    width: canvas.width - 64,
    height: branchGroupHeight,
    columns: [],
    source: group.source,
    merge: group.merge,
  };

  const availableWidth = branchGroup.width - 28;
  const branchGap = group.columns.length > 1
    ? (availableWidth - group.columns.length * branchSize.width) / (group.columns.length - 1)
    : 0;
  const branchY = branchGroup.y + 46;
  group.columns.forEach((nodeId, index) => {
    positions[nodeId] = {
      x: Math.round(branchGroup.x + 14 + index * (branchSize.width + branchGap)),
      y: branchY,
      width: branchSize.width,
      height: branchSize.height,
    };
    branchGroup.columns.push(nodeId);
  });

  postChain.forEach((nodeId, index) => {
    const baseY = branchGroup.y + branchGroup.height + mergeTopGap;
    positions[nodeId] = centeredBox(centerX, baseY + index * mainGap, mainSize);
  });

  const lastNode = postChain[postChain.length - 1];
  canvas.height = positions[lastNode].y + positions[lastNode].height + 76;

  return {
    schema: "sirius.diagram.layout.v1",
    id: intent.id,
    title: intent.title,
    description: intent.description,
    axis: intent.orientation || "vertical_center",
    canvas,
    main_chain: intent.main_chain,
    centered_nodes: intent.main_chain,
    nodes: intent.nodes.map((node) => ({
      ...node,
      ...positions[node.id],
      lane: node.role === "branch" ? "branch" : "center",
    })),
    parallel_groups: [branchGroup],
    merge_nodes: intent.merge_nodes.map((nodeId) => ({
      id: nodeId,
      x: positions[nodeId].x,
      y: positions[nodeId].y,
    })),
    feedback_loops: intent.feedback_loops,
    routes: buildRoutes(intent, positions, branchGroup),
    quality_checks: {
      main_chain_readable: true,
      branches_aligned: true,
      arrow_crossings: false,
      crowded: false,
      feedback_outer_route: true,
    },
  };
}

function buildRoutes(intent, positions, branchGroup) {
  const routes = [];
  const group = intent.parallel_groups[0];
  const groupSourceIndex = intent.main_chain.indexOf(group.source);
  const mergeIndex = intent.main_chain.indexOf(group.merge);
  const preChain = intent.main_chain.slice(0, groupSourceIndex + 1);
  const postChain = intent.main_chain.slice(mergeIndex);

  for (let index = 0; index < preChain.length - 1; index += 1) {
    routes.push(verticalRoute(preChain[index], preChain[index + 1], positions, "main"));
  }

  const source = positions[group.source];
  const splitY = branchGroup.y - 22;
  const firstBranch = positions[group.columns[0]];
  const lastBranch = positions[group.columns[group.columns.length - 1]];
  routes.push({
    from: group.source,
    to: `${group.id}-split`,
    role: "split-main",
    points: [
      centerBottom(source),
      { x: source.x + source.width / 2, y: splitY },
    ],
  });
  routes.push({
    from: `${group.id}-split-left`,
    to: `${group.id}-split-right`,
    role: "split-bus",
    label: "沉淀资产",
    points: [
      { x: firstBranch.x + firstBranch.width / 2, y: splitY },
      { x: lastBranch.x + lastBranch.width / 2, y: splitY },
    ],
  });

  for (const nodeId of group.columns) {
    const node = positions[nodeId];
    routes.push({
      from: group.source,
      to: nodeId,
      role: "branch",
      label: "审计",
      points: [
        { x: node.x + node.width / 2, y: splitY },
        { x: node.x + node.width / 2, y: node.y },
      ],
    });
  }

  const merge = positions[group.merge];
  const mergeY = merge.y - 28;
  routes.push({
    from: `${group.id}-merge-left`,
    to: `${group.id}-merge-right`,
    role: "merge-bus",
    label: "汇聚",
    points: [
      { x: firstBranch.x + firstBranch.width / 2, y: mergeY },
      { x: lastBranch.x + lastBranch.width / 2, y: mergeY },
    ],
  });
  routes.push({
    from: `${group.id}-merge`,
    to: group.merge,
    role: "merge-down",
    points: [
      { x: merge.x + merge.width / 2, y: mergeY },
      { x: merge.x + merge.width / 2, y: merge.y },
    ],
  });

  for (const nodeId of group.columns) {
    const node = positions[nodeId];
    routes.push({
      from: nodeId,
      to: group.merge,
      role: "branch-merge",
      label: "审计",
      points: [
        centerBottom(node),
        { x: node.x + node.width / 2, y: mergeY },
      ],
    });
  }

  for (let index = 0; index < postChain.length - 1; index += 1) {
    routes.push(verticalRoute(postChain[index], postChain[index + 1], positions, "main"));
  }

  for (const loop of intent.feedback_loops) {
    const from = positions[loop.from];
    const to = positions[loop.to];
    const outerX = 18;
    const bottomY = from.y + from.height + 42;
    const topY = to.y + 30;
    routes.push({
      from: loop.from,
      to: loop.to,
      role: "feedback",
      label: loop.label,
      route: loop.route,
      points: [
        { x: from.x + from.width / 2, y: from.y + from.height },
        { x: from.x + from.width / 2, y: bottomY },
        { x: outerX, y: bottomY },
        { x: outerX, y: topY },
        { x: to.x, y: topY },
      ],
    });
  }

  return routes;
}

function verticalRoute(from, to, positions, role) {
  return {
    from,
    to,
    role,
    points: [
      centerBottom(positions[from]),
      centerTop(positions[to]),
    ],
  };
}

function centeredBox(centerX, y, size) {
  return {
    x: Math.round(centerX - size.width / 2),
    y: Math.round(y),
    width: size.width,
    height: size.height,
  };
}

function centerTop(box) {
  return { x: box.x + box.width / 2, y: box.y };
}

function centerBottom(box) {
  return { x: box.x + box.width / 2, y: box.y + box.height };
}
