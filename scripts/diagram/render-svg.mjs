#!/usr/bin/env node
import { readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const [layoutPath, outputPath] = process.argv.slice(2);

if (!layoutPath || !outputPath) {
  console.error("Usage: node scripts/diagram/render-svg.mjs <input.layout.plan.json> <output.svg>");
  process.exit(2);
}

const palette = {
  A: { fill: "#EFF6FF", stroke: "#60A5FA", icon: "#3B82F6" },
  B: { fill: "#F0FDF4", stroke: "#86EFAC", icon: "#22C55E" },
  C: { fill: "#FFFBEB", stroke: "#FBBF24", icon: "#F59E0B" },
  D: { fill: "#F5F3FF", stroke: "#A78BFA", icon: "#8B5CF6" },
  E: { fill: "#FFF7ED", stroke: "#FDBA74", icon: "#F97316" },
  F: { fill: "#EFF6FF", stroke: "#93C5FD", icon: "#3B82F6" },
  G: { fill: "#EFF6FF", stroke: "#93C5FD", icon: "#3B82F6" },
  H: { fill: "#F0FDFA", stroke: "#5EEAD4", icon: "#14B8A6" },
  I: { fill: "#F0FDF4", stroke: "#86EFAC", icon: "#22C55E" },
  J: { fill: "#FFFBEB", stroke: "#FCD34D", icon: "#F59E0B" },
  K: { fill: "#FFF7ED", stroke: "#FDBA74", icon: "#F97316" },
  L: { fill: "#FEF2F2", stroke: "#FCA5A5", icon: "#EF4444" },
  M: { fill: "#EFF6FF", stroke: "#93C5FD", icon: "#3B82F6" },
  N: { fill: "#F0FDF4", stroke: "#86EFAC", icon: "#22C55E" },
  default: { fill: "#F8FAFC", stroke: "#CBD5E1", icon: "#64748B" },
};

const layout = JSON.parse(readFileSync(resolve(layoutPath), "utf8"));
writeFileSync(resolve(outputPath), renderSvg(layout), "utf8");

function renderSvg(layout) {
  const width = layout.canvas.width;
  const height = layout.canvas.height;
  const nodes = new Map(layout.nodes.map((node) => [node.id, node]));

  return `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0 0 ${width} ${height}" role="img" aria-labelledby="title desc">
  <title id="title">${xml(layout.title)}</title>
  <desc id="desc">${xml(layout.description)}</desc>
  <defs>
    <marker id="arrow-main" markerWidth="12" markerHeight="12" refX="9" refY="6" orient="auto" markerUnits="strokeWidth">
      <path d="M2,2 L10,6 L2,10 Z" fill="#64748B" />
    </marker>
    <filter id="card-shadow" x="-10%" y="-10%" width="120%" height="130%">
      <feDropShadow dx="0" dy="3" stdDeviation="4" flood-color="#0F172A" flood-opacity="0.10" />
    </filter>
    <style>
      .canvas { fill: #FFFFFF; }
      .route { fill: none; stroke: #64748B; stroke-width: 2.6; stroke-linecap: round; stroke-linejoin: round; marker-end: url(#arrow-main); }
      .route-branch { stroke-width: 2.2; stroke: #94A3B8; }
      .route-bus { marker-end: none; stroke: #94A3B8; }
      .route-feedback { stroke-width: 2.6; stroke: #475569; }
      .group-box { fill: #FFFFFF; stroke: #CBD5E1; stroke-width: 1.8; stroke-dasharray: 6 6; rx: 10; }
      .node-card { filter: url(#card-shadow); }
      .node-title { font: 600 19px "PingFang SC", "Microsoft YaHei", "Noto Sans CJK SC", Arial, sans-serif; fill: #0F172A; }
      .node-subtitle { font: 400 15px "PingFang SC", "Microsoft YaHei", "Noto Sans CJK SC", Arial, sans-serif; fill: #475569; }
      .branch-title { font-size: 16px; }
      .branch-subtitle { font-size: 13px; }
      .edge-label { font: 500 13px "PingFang SC", "Microsoft YaHei", Arial, sans-serif; fill: #334155; }
      .group-title { font: 600 15px "PingFang SC", "Microsoft YaHei", Arial, sans-serif; fill: #64748B; }
      .icon-line { fill: none; stroke-linecap: round; stroke-linejoin: round; stroke-width: 2.8; }
    </style>
  </defs>
  <rect class="canvas" width="${width}" height="${height}" />
${layout.parallel_groups.map(renderParallelGroup).join("\n")}
${layout.routes.map((route) => renderRoute(route, nodes)).join("\n")}
${layout.nodes.map(renderNode).join("\n")}
</svg>
`;
}

function renderParallelGroup(group) {
  return `  <g data-diagram-stage="parallel-group" data-group-id="${xml(group.id)}">
    <rect class="group-box" x="${group.x}" y="${group.y}" width="${group.width}" height="${group.height}" />
    <text class="group-title" x="${group.x + 18}" y="${group.y + 26}">${xml(group.title)}</text>
  </g>`;
}

function renderRoute(route, nodes) {
  const classes = ["route"];
  if (route.role.includes("branch")) classes.push("route-branch");
  if (route.role.endsWith("-bus")) classes.push("route-bus");
  if (route.role === "feedback") classes.push("route-feedback");
  const attrs = [
    `data-route-role="${xml(route.role)}"`,
  ];
  if (route.route) attrs.push(`data-route="${xml(route.route)}"`);
  const label = renderRouteLabel(route, nodes);
  return `  <g ${attrs.join(" ")}>
    <path class="${classes.join(" ")}" d="${pointsToPath(route.points)}" />
${label}
  </g>`;
}

function renderRouteLabel(route, nodes) {
  if (!route.label || route.role === "branch" || route.role === "branch-merge" || route.role === "split-main" || route.role === "merge-down") {
    return "";
  }
  const points = route.points;
  const point = points[Math.floor(points.length / 2)];
  const x = route.role === "feedback" ? point.x + 14 : point.x + 8;
  const y = route.role === "feedback" ? point.y - 10 : point.y - 8;
  return `    <text class="edge-label" x="${x}" y="${y}">${xml(route.label)}</text>`;
}

function renderNode(node) {
  const theme = palette[node.id] || palette.default;
  const stage = node.role === "branch" ? "branch-node" : "main-chain";
  const iconX = node.x + (node.role === "branch" ? 18 : 26);
  const iconY = node.y + (node.role === "branch" ? 32 : 31);
  const textX = node.x + (node.role === "branch" ? 54 : 86);
  const titleY = node.y + (node.role === "branch" ? 38 : 35);
  const titleParts = splitTitle(`${node.id}. ${node.title}`, node.role === "branch" ? 14 : 28);
  const subtitleY = node.y + (node.role === "branch" ? 63 + Math.max(0, titleParts.length - 1) * 18 : 61);
  const titleClass = node.role === "branch" ? "node-title branch-title" : "node-title";
  const subtitleClass = node.role === "branch" ? "node-subtitle branch-subtitle" : "node-subtitle";

  return `  <g data-diagram-stage="${stage}" data-node-id="${xml(node.id)}" class="node-card">
    <rect x="${node.x}" y="${node.y}" width="${node.width}" height="${node.height}" rx="7" fill="${theme.fill}" stroke="${theme.stroke}" stroke-width="2" />
${renderIcon(node.icon, iconX, iconY, theme.icon)}
${renderTitle(titleParts, textX, titleY, titleClass)}
${renderSubtitle(node.subtitle, textX, subtitleY, subtitleClass, node.role)}
  </g>`;
}

function renderTitle(parts, x, y, className) {
  return `    <text class="${className}" x="${x}" y="${y}">
${parts.map((part, index) => `      <tspan x="${x}" dy="${index === 0 ? 0 : 18}">${xml(part)}</tspan>`).join("\n")}
    </text>`;
}

function renderSubtitle(subtitle, x, y, className, role) {
  const parts = splitSubtitle(subtitle, role === "branch" ? 10 : 18);
  return `    <text class="${className}" x="${x}" y="${y}">
${parts.map((part, index) => `      <tspan x="${x}" dy="${index === 0 ? 0 : 18}">${xml(part)}</tspan>`).join("\n")}
    </text>`;
}

function splitTitle(text, maxLength) {
  if (text.length <= maxLength) return [text];
  const breakpoints = [" + ", " / ", " "];
  for (const breakpoint of breakpoints) {
    const index = text.lastIndexOf(breakpoint, maxLength);
    if (index > 0) {
      return [text.slice(0, index + breakpoint.trimEnd().length).trim(), text.slice(index + breakpoint.length).trim()];
    }
  }
  return [text.slice(0, maxLength), text.slice(maxLength)];
}

function splitSubtitle(text, maxLength) {
  if (text.length <= maxLength) return [text];
  const parts = text.split(/[,，]\s*/);
  const lines = [];
  let current = "";
  for (const part of parts) {
    const next = current ? `${current}, ${part}` : part;
    if (next.length > maxLength && current) {
      lines.push(current);
      current = part;
    } else {
      current = next;
    }
  }
  if (current) lines.push(current);
  return lines.slice(0, 2);
}

function renderIcon(icon, x, y, color) {
  const stroke = `stroke="${color}"`;
  const fill = `fill="${color}"`;
  const common = `class="icon-line" ${stroke}`;
  const shape = {
    chat: `<path ${common} d="M4 6h28v18H16l-8 7v-7H4z" />`,
    folder: `<path ${common} d="M3 9h11l3 5h22v22H3z" /><path ${common} d="M3 14h36" />`,
    code: `<path ${common} d="M15 9L7 20l8 11" /><path ${common} d="M25 9l8 11-8 11" />`,
    check: `<path ${common} d="M10 8h20v28H10z" /><path ${common} d="M15 21l5 5 10-12" />`,
    trend: `<path ${common} d="M6 31l9-10 7 6 13-16" /><path ${common} d="M28 11h7v7" />`,
    database: `<ellipse ${common} cx="20" cy="10" rx="13" ry="6" /><path ${common} d="M7 10v18c0 3 6 6 13 6s13-3 13-6V10" /><path ${common} d="M7 19c0 3 6 6 13 6s13-3 13-6" />`,
    shield: `<path ${common} d="M20 5l13 5v9c0 9-5 15-13 18C12 34 7 28 7 19v-9z" />`,
    flow: `<rect ${common} x="5" y="6" width="10" height="10" /><rect ${common} x="25" y="6" width="10" height="10" /><rect ${common} x="15" y="25" width="10" height="10" /><path ${common} d="M15 11h10M30 16v7H20v2" />`,
    terminal: `<rect ${common} x="4" y="8" width="32" height="24" /><path ${common} d="M10 16l6 5-6 5M20 27h10" />`,
    book: `<path ${common} d="M8 7h18c4 0 7 3 7 7v22H15c-4 0-7-3-7-7z" /><path ${common} d="M15 7v29" />`,
    cube: `<path ${common} d="M20 5l15 8v16l-15 8-15-8V13z" /><path ${common} d="M5 13l15 8 15-8M20 21v16" />`,
    home: `<path ${common} d="M5 20L20 7l15 13" /><path ${common} d="M10 18v18h20V18" />`,
    brain: `<path ${common} d="M14 9c-5 1-8 5-7 10-4 3-3 10 2 12 1 5 8 7 12 3 4 4 11 2 12-3 5-2 6-9 2-12 1-5-2-9-7-10-3-5-11-5-14 0z" /><path ${common} d="M20 11v24M13 19h14M12 27h16" />`,
  }[icon] || `<circle ${common} cx="20" cy="20" r="12" /><circle ${fill} cx="20" cy="20" r="3" />`;

  return `    <g transform="translate(${x} ${y}) scale(0.86)">${shape}</g>`;
}

function pointsToPath(points) {
  return points.map((point, index) => `${index === 0 ? "M" : "L"} ${round(point.x)} ${round(point.y)}`).join(" ");
}

function round(value) {
  return Math.round(value * 10) / 10;
}

function xml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}
