#!/usr/bin/env node
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const [sourcePath, outputPath] = process.argv.slice(2);

if (!sourcePath || !outputPath) {
  console.error("Usage: node scripts/diagram/build-intent.mjs <source.diagram.json> <output.intent.json>");
  process.exit(2);
}

const source = readJson(sourcePath);
const intent = buildIntent(source);
writeFileSync(resolve(outputPath), `${JSON.stringify(intent, null, 2)}\n`, "utf8");

function readJson(path) {
  return JSON.parse(readFileSync(resolve(path), "utf8"));
}

function buildIntent(source) {
  requireString(source.id, "id");
  requireString(source.title, "title");
  requireArray(source.nodes, "nodes");
  requireArray(source.main_chain, "main_chain");
  requireArray(source.parallel_groups, "parallel_groups");
  requireArray(source.merge_nodes, "merge_nodes");
  requireArray(source.feedback_loops, "feedback_loops");

  const nodes = source.nodes.map((node, index) => normalizeNode(node, index));
  const nodeIds = new Set(nodes.map((node) => node.id));
  if (nodeIds.size !== nodes.length) {
    throw new Error("nodes must have unique ids");
  }

  for (const nodeId of source.main_chain) {
    assertKnownNode(nodeIds, nodeId, "main_chain");
  }

  const parallelGroups = source.parallel_groups.map((group, index) => {
    requireString(group.id, `parallel_groups[${index}].id`);
    requireString(group.title, `parallel_groups[${index}].title`);
    requireString(group.source, `parallel_groups[${index}].source`);
    requireString(group.merge, `parallel_groups[${index}].merge`);
    requireArray(group.columns, `parallel_groups[${index}].columns`);
    assertKnownNode(nodeIds, group.source, `parallel_groups[${index}].source`);
    assertKnownNode(nodeIds, group.merge, `parallel_groups[${index}].merge`);
    for (const column of group.columns) {
      assertKnownNode(nodeIds, column, `parallel_groups[${index}].columns`);
    }
    return {
      id: group.id,
      title: group.title,
      source: group.source,
      merge: group.merge,
      columns: group.columns,
    };
  });

  for (const mergeNode of source.merge_nodes) {
    assertKnownNode(nodeIds, mergeNode, "merge_nodes");
  }

  const feedbackLoops = source.feedback_loops.map((loop, index) => {
    requireString(loop.from, `feedback_loops[${index}].from`);
    requireString(loop.to, `feedback_loops[${index}].to`);
    assertKnownNode(nodeIds, loop.from, `feedback_loops[${index}].from`);
    assertKnownNode(nodeIds, loop.to, `feedback_loops[${index}].to`);
    return {
      from: loop.from,
      to: loop.to,
      label: loop.label || "反馈循环",
      route: loop.route || "outer-left",
    };
  });

  return {
    schema: "sirius.diagram.intent.v1",
    id: source.id,
    title: source.title,
    description: source.description || source.title,
    orientation: source.orientation || "vertical_center",
    readmeSync: source.readmeSync || null,
    nodes,
    main_chain: source.main_chain,
    parallel_groups: parallelGroups,
    merge_nodes: source.merge_nodes,
    feedback_loops: feedbackLoops,
  };
}

function normalizeNode(node, index) {
  requireString(node.id, `nodes[${index}].id`);
  requireString(node.title, `nodes[${index}].title`);
  requireString(node.subtitle, `nodes[${index}].subtitle`);
  requireString(node.role, `nodes[${index}].role`);

  const validRoles = new Set(["main", "hub", "branch", "merge", "end"]);
  if (!validRoles.has(node.role)) {
    throw new Error(`nodes[${index}].role must be one of main, hub, branch, merge, end`);
  }

  return {
    id: node.id,
    title: node.title,
    subtitle: node.subtitle,
    role: node.role,
    icon: node.icon || "dot",
  };
}

function requireString(value, path) {
  if (typeof value !== "string" || value.trim() === "") {
    throw new Error(`Expected non-empty string at ${path}`);
  }
}

function requireArray(value, path) {
  if (!Array.isArray(value) || value.length === 0) {
    throw new Error(`Expected non-empty array at ${path}`);
  }
}

function assertKnownNode(nodeIds, nodeId, path) {
  if (!nodeIds.has(nodeId)) {
    throw new Error(`${path} references unknown node: ${nodeId}`);
  }
}
