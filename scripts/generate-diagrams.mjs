#!/usr/bin/env node
import { createHash } from "node:crypto";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const rootDir = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const args = process.argv.slice(2);
const checkMode = args.includes("--check");
const specPaths = args.filter((arg) => arg !== "--check");

if (specPaths.length === 0) {
  console.error("Usage: node scripts/generate-diagrams.mjs [--check] <diagram.diagram.json> [...]");
  process.exit(2);
}

const layerPalette = [
  { fill: "#E0F2FE", stroke: "#0284C7", text: "#0F172A" },
  { fill: "#ECFCCB", stroke: "#65A30D", text: "#1A2E05" },
  { fill: "#FEF3C7", stroke: "#D97706", text: "#451A03" },
  { fill: "#EDE9FE", stroke: "#7C3AED", text: "#2E1065" },
  { fill: "#FFE4E6", stroke: "#E11D48", text: "#4C0519" },
  { fill: "#DCFCE7", stroke: "#16A34A", text: "#052E16" },
];

const kindStyle = {
  input: { mermaid: "stadium" },
  process: { mermaid: "rect" },
  decision: { mermaid: "diamond" },
  asset: { mermaid: "subroutine" },
  output: { mermaid: "stadium" },
};

let failed = false;

for (const specPath of specPaths) {
  const absoluteSpecPath = resolve(specPath);
  const spec = readSpec(absoluteSpecPath);
  const normalized = normalizeSpec(spec);
  const outputs = renderAll(normalized, absoluteSpecPath);
  const mermaid = outputs.find((output) => output.kind === "mermaid");
  for (const output of outputs) {
    if (checkMode) {
      if (!existsSync(output.path)) {
        console.error(`Missing generated diagram file: ${relative(output.path)}`);
        failed = true;
        continue;
      }
      const current = readFileSync(output.path, "utf8");
      if (current !== output.content) {
        console.error(`Generated diagram file is stale: ${relative(output.path)}`);
        failed = true;
      }
    } else {
      writeFileSync(output.path, output.content, "utf8");
      console.log(`Generated ${relative(output.path)}`);
    }
  }
  if (normalized.readmeSync) {
    syncReadme(normalized, mermaid.content);
  }
}

process.exit(failed ? 1 : 0);

function readSpec(specPath) {
  const raw = readFileSync(specPath, "utf8");
  try {
    return JSON.parse(raw);
  } catch (error) {
    throw new Error(`Invalid diagram JSON ${specPath}: ${error.message}`);
  }
}

function normalizeSpec(spec) {
  requireString(spec.id, "id");
  requireString(spec.title, "title");
  if (!Array.isArray(spec.layers) || spec.layers.length === 0) {
    throw new Error("Diagram spec requires at least one layer");
  }
  if (!Array.isArray(spec.nodes) || spec.nodes.length === 0) {
    throw new Error("Diagram spec requires at least one node");
  }
  if (!Array.isArray(spec.edges)) {
    throw new Error("Diagram spec requires an edges array");
  }

  const layers = spec.layers.map((layer, index) => {
    requireString(layer.id, `layers[${index}].id`);
    requireString(layer.title, `layers[${index}].title`);
    return { ...layer, index };
  });
  const layerIds = new Set(layers.map((layer) => layer.id));
  const nodes = spec.nodes.map((node, index) => {
    requireString(node.id, `nodes[${index}].id`);
    requireString(node.label, `nodes[${index}].label`);
    requireString(node.layer, `nodes[${index}].layer`);
    if (!layerIds.has(node.layer)) {
      throw new Error(`Node ${node.id} references unknown layer ${node.layer}`);
    }
    return {
      kind: "process",
      ...node,
      order: Number.isFinite(node.order) ? node.order : index,
    };
  });
  const nodeIds = new Set(nodes.map((node) => node.id));
  if (nodeIds.size !== nodes.length) {
    throw new Error("Node ids must be unique");
  }
  const edges = spec.edges.map((edge, index) => {
    requireString(edge.from, `edges[${index}].from`);
    requireString(edge.to, `edges[${index}].to`);
    if (!nodeIds.has(edge.from)) {
      throw new Error(`Edge ${index} references unknown source ${edge.from}`);
    }
    if (!nodeIds.has(edge.to)) {
      throw new Error(`Edge ${index} references unknown target ${edge.to}`);
    }
    return edge;
  });

  return {
    ...spec,
    direction: spec.direction || "LR",
    modified: spec.modified || "2026-04-21T00:00:00.000Z",
    layers,
    nodes,
    edges,
  };
}

function requireString(value, path) {
  if (typeof value !== "string" || value.trim() === "") {
    throw new Error(`Diagram spec requires non-empty string at ${path}`);
  }
}

function renderAll(spec, specPath) {
  const outputDir = spec.outputDir ? resolve(dirname(specPath), spec.outputDir) : dirname(specPath);
  const baseName = spec.outputBaseName || spec.id;
  return [
    { kind: "mermaid", path: join(outputDir, `${baseName}.mmd`), content: renderMermaid(spec) },
    { kind: "drawio", path: join(outputDir, `${baseName}.drawio`), content: renderDrawio(spec) },
    { kind: "excalidraw", path: join(outputDir, `${baseName}.excalidraw`), content: renderExcalidraw(spec) },
    { kind: "ai-drawio", path: join(outputDir, `${baseName}.ai-drawio.md`), content: renderAiDrawioPrompt(spec) },
  ];
}

function syncReadme(spec, mermaidContent) {
  const sync = spec.readmeSync;
  requireString(sync.path, "readmeSync.path");
  requireString(sync.marker, "readmeSync.marker");

  const readmePath = resolve(rootDir, sync.path);
  const startMarker = `<!-- diagram:${sync.marker}:start -->`;
  const endMarker = `<!-- diagram:${sync.marker}:end -->`;
  const block = `${startMarker}\n\`\`\`mermaid\n${mermaidContent}\`\`\`\n${endMarker}`;

  if (!existsSync(readmePath)) {
    throw new Error(`README sync target does not exist: ${relative(readmePath)}`);
  }

  const current = readFileSync(readmePath, "utf8");
  const pattern = new RegExp(`${escapeRegExp(startMarker)}[\\s\\S]*?${escapeRegExp(endMarker)}`);
  if (!pattern.test(current)) {
    throw new Error(`README sync markers not found in ${relative(readmePath)} for ${sync.marker}`);
  }

  const expected = current.replace(pattern, block);
  if (checkMode) {
    if (current !== expected) {
      console.error(`README diagram block is stale: ${relative(readmePath)}#${sync.marker}`);
      failed = true;
    }
  } else if (current !== expected) {
    writeFileSync(readmePath, expected, "utf8");
    console.log(`Synced ${relative(readmePath)}#${sync.marker}`);
  }
}

function renderMermaid(spec) {
  const layerNodes = nodesByLayer(spec);
  const lines = [
    `flowchart ${spec.direction}`,
    `  %% ${spec.title}`,
  ];

  for (const layer of spec.layers) {
    lines.push(`  subgraph ${mermaidId(layer.id)}["${escapeMermaid(layer.title)}"]`);
    for (const node of layerNodes.get(layer.id) || []) {
      lines.push(`    ${mermaidNode(node)}`);
    }
    lines.push("  end");
  }

  for (const edge of spec.edges) {
    const label = edge.label ? `|"${escapeMermaid(edge.label)}"|` : "";
    lines.push(`  ${mermaidId(edge.from)} -->${label} ${mermaidId(edge.to)}`);
  }

  return `${lines.join("\n")}\n`;
}

function mermaidNode(node) {
  const id = mermaidId(node.id);
  const label = escapeMermaid(node.label).replaceAll("\\n", "<br/>");
  const shape = kindStyle[node.kind]?.mermaid || "rect";

  if (shape === "stadium") {
    return `${id}(["${label}"])`;
  }
  if (shape === "diamond") {
    return `${id}{"${label}"}`;
  }
  if (shape === "subroutine") {
    return `${id}[["${label}"]]`;
  }
  return `${id}["${label}"]`;
}

function renderDrawio(spec) {
  const positions = layout(spec);
  const cells = [
    '    <mxCell id="0" />',
    '    <mxCell id="1" parent="0" />',
  ];

  for (const node of spec.nodes) {
    const position = positions.get(node.id);
    const colors = colorsFor(spec, node);
    const style = [
      "rounded=1",
      "whiteSpace=wrap",
      "html=1",
      "arcSize=8",
      `fillColor=${colors.fill}`,
      `strokeColor=${colors.stroke}`,
      `fontColor=${colors.text}`,
      "fontSize=13",
      "spacing=10",
    ].join(";");
    cells.push(
      `    <mxCell id="${xmlAttr(node.id)}" value="${xmlAttr(labelToHtml(node.label))}" style="${xmlAttr(style)}" vertex="1" parent="1">`,
      `      <mxGeometry x="${position.x}" y="${position.y}" width="${position.width}" height="${position.height}" as="geometry" />`,
      "    </mxCell>",
    );
  }

  spec.edges.forEach((edge, index) => {
    const style = "endArrow=block;html=1;rounded=0;strokeWidth=2;strokeColor=#64748B;fontColor=#334155;";
    cells.push(
      `    <mxCell id="${xmlAttr(`edge-${index + 1}`)}" value="${xmlAttr(edge.label || "")}" style="${xmlAttr(style)}" edge="1" parent="1" source="${xmlAttr(edge.from)}" target="${xmlAttr(edge.to)}">`,
      '      <mxGeometry relative="1" as="geometry" />',
      "    </mxCell>",
    );
  });

  return [
    `<mxfile host="app.diagrams.net" modified="${xmlAttr(spec.modified)}" agent="Sirius diagram generator" version="24.7.17">`,
    `  <diagram id="${xmlAttr(spec.id)}" name="${xmlAttr(spec.title)}">`,
    '    <mxGraphModel dx="1422" dy="794" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="1800" pageHeight="1200" math="0" shadow="0">',
    "  <root>",
    ...cells,
    "  </root>",
    "    </mxGraphModel>",
    "  </diagram>",
    "</mxfile>",
    "",
  ].join("\n");
}

function renderExcalidraw(spec) {
  const positions = layout(spec);
  const elements = [];

  for (const node of spec.nodes) {
    const position = positions.get(node.id);
    const colors = colorsFor(spec, node);
    const rectangleId = excalidrawId(`rect-${node.id}`);
    elements.push(baseElement(rectangleId, "rectangle", {
      x: position.x,
      y: position.y,
      width: position.width,
      height: position.height,
      strokeColor: colors.stroke,
      backgroundColor: colors.fill,
      roundness: { type: 3 },
    }));
    elements.push(baseElement(excalidrawId(`text-${node.id}`), "text", {
      x: position.x + 14,
      y: position.y + 22,
      width: position.width - 28,
      height: position.height - 28,
      strokeColor: colors.text,
      backgroundColor: "transparent",
      text: labelToText(node.label),
      fontSize: 17,
      fontFamily: 1,
      textAlign: "center",
      verticalAlign: "middle",
      containerId: rectangleId,
      originalText: labelToText(node.label),
      lineHeight: 1.25,
    }));
  }

  spec.edges.forEach((edge, index) => {
    const from = positions.get(edge.from);
    const to = positions.get(edge.to);
    const startX = from.x + from.width;
    const startY = from.y + from.height / 2;
    const endX = to.x;
    const endY = to.y + to.height / 2;
    const arrowId = excalidrawId(`arrow-${index + 1}-${edge.from}-${edge.to}`);
    elements.push(baseElement(arrowId, "arrow", {
      x: startX,
      y: startY,
      width: endX - startX,
      height: endY - startY,
      strokeColor: "#64748B",
      backgroundColor: "transparent",
      points: [[0, 0], [endX - startX, endY - startY]],
      startBinding: {
        elementId: excalidrawId(`rect-${edge.from}`),
        focus: 0,
        gap: 4,
      },
      endBinding: {
        elementId: excalidrawId(`rect-${edge.to}`),
        focus: 0,
        gap: 4,
      },
      endArrowhead: "arrow",
    }));
    if (edge.label) {
      elements.push(baseElement(excalidrawId(`edge-label-${index + 1}`), "text", {
        x: startX + (endX - startX) / 2 - 48,
        y: startY + (endY - startY) / 2 - 24,
        width: 96,
        height: 28,
        strokeColor: "#334155",
        backgroundColor: "transparent",
        text: edge.label,
        fontSize: 13,
        fontFamily: 1,
        textAlign: "center",
        verticalAlign: "middle",
        originalText: edge.label,
        lineHeight: 1.25,
      }));
    }
  });

  return `${JSON.stringify({
    type: "excalidraw",
    version: 2,
    source: "https://github.com/sirius-coding/sirius-coding",
    elements,
    appState: {
      gridSize: 20,
      viewBackgroundColor: "#F8FAFC",
    },
    files: {},
  }, null, 2)}\n`;
}

function renderAiDrawioPrompt(spec) {
  const nodes = spec.nodes.map((node) => `- ${node.id}: ${labelToPrompt(node.label)} [${node.kind}; ${node.layer}]`).join("\n");
  const edges = spec.edges.map((edge) => `- ${edge.from} -> ${edge.to}${edge.label ? `: ${edge.label}` : ""}`).join("\n");
  return `# AI Drawio Prompt: ${spec.title}

Use this prompt in draw.io AI or another diagram assistant to regenerate an editable workflow diagram.

## Goal

${spec.description || spec.title}

## Layout

- Direction: ${spec.direction}
- Use grouped horizontal phases matching the layers below.
- Keep root governance assets, project execution assets, and generated automation visibly distinct.
- Use a clean technical style with light backgrounds, clear arrows, and short labels.

## Layers

${spec.layers.map((layer) => `- ${layer.id}: ${layer.title}`).join("\n")}

## Nodes

${nodes}

## Edges

${edges}
`;
}

function nodesByLayer(spec) {
  const map = new Map(spec.layers.map((layer) => [layer.id, []]));
  for (const node of [...spec.nodes].sort((a, b) => a.order - b.order)) {
    map.get(node.layer).push(node);
  }
  return map;
}

function layout(spec) {
  const layerNodes = nodesByLayer(spec);
  const positions = new Map();
  const width = 210;
  const height = 78;
  const xGap = 295;
  const yGap = 128;
  const top = 80;
  const left = 70;

  spec.layers.forEach((layer, layerIndex) => {
    const nodes = layerNodes.get(layer.id) || [];
    const columnHeight = nodes.length * height + Math.max(0, nodes.length - 1) * (yGap - height);
    const yOffset = Math.max(0, (520 - columnHeight) / 2);
    nodes.forEach((node, rowIndex) => {
      positions.set(node.id, {
        x: left + layerIndex * xGap,
        y: Math.round(top + yOffset + rowIndex * yGap),
        width,
        height,
      });
    });
  });

  return positions;
}

function colorsFor(spec, node) {
  const layer = spec.layers.find((item) => item.id === node.layer);
  return layerPalette[layer.index % layerPalette.length];
}

function baseElement(id, type, overrides) {
  return {
    id,
    type,
    x: 0,
    y: 0,
    width: 0,
    height: 0,
    angle: 0,
    strokeColor: "#1E293B",
    backgroundColor: "transparent",
    fillStyle: "solid",
    strokeWidth: 2,
    strokeStyle: "solid",
    roughness: 1,
    opacity: 100,
    groupIds: [],
    frameId: null,
    roundness: null,
    seed: seedFrom(id),
    version: 1,
    versionNonce: seedFrom(`${id}-nonce`),
    isDeleted: false,
    boundElements: null,
    updated: 1,
    link: null,
    locked: false,
    ...overrides,
  };
}

function mermaidId(value) {
  return value.replace(/[^A-Za-z0-9_]/g, "_");
}

function excalidrawId(value) {
  return createHash("sha1").update(value).digest("hex").slice(0, 16);
}

function seedFrom(value) {
  return Number.parseInt(createHash("sha1").update(value).digest("hex").slice(0, 8), 16);
}

function escapeMermaid(value) {
  return value.replaceAll('"', '\\"');
}

function labelToText(value) {
  return value.replaceAll("\\n", "\n");
}

function labelToHtml(value) {
  return labelToText(value).replaceAll("\n", "<br/>");
}

function labelToPrompt(value) {
  return labelToText(value).replaceAll("\n", " / ");
}

function escapeRegExp(value) {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

function xmlAttr(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll('"', "&quot;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;");
}

function relative(path) {
  return path.startsWith(rootDir) ? path.slice(rootDir.length + 1) : path;
}
