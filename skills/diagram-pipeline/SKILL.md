---
name: diagram-pipeline
description: Build high-quality process diagrams by modeling intent, planning layout, then rendering SVG and image prompts.
---

# Diagram Pipeline

Use this skill whenever a task asks for a process diagram, architecture flow, UML-like flow, ER-style relationship diagram, or a visual explanation of a workflow.

## Required Flow

1. Build intent first.
   - Source: `*.diagram.json`
   - Output: `*.intent.json`
   - Must include `main_chain`, `parallel_groups`, `merge_nodes`, `feedback_loops`, and node `role`.

2. Build layout second.
   - Source: `*.intent.json`
   - Output: `*.layout.plan.json`
   - Must define the main axis, centered nodes, branch columns, merge placement, and route rules.

3. Apply style.
   - Read `specs/diagram-style.md`.
   - Keep ProcessOn-like clean cards, low-saturation colors, orthogonal arrows, and clear Chinese text.

4. Render final assets.
   - Engineering/editable output: SVG.
   - High-quality display guidance: image prompt.
   - Mermaid can be kept as compatibility/debug output, but it is not the primary result for flowcharts.

## CLI

```bash
node scripts/diagram/build-all.mjs docs/diagrams/evolution-workflow.diagram.json
```

Or run stages separately:

```bash
node scripts/diagram/build-intent.mjs docs/diagrams/evolution-workflow.diagram.json docs/diagrams/evolution-workflow.intent.json
node scripts/diagram/build-layout.mjs docs/diagrams/evolution-workflow.intent.json docs/diagrams/evolution-workflow.layout.plan.json
node scripts/diagram/render-svg.mjs docs/diagrams/evolution-workflow.layout.plan.json docs/diagrams/evolution-workflow.svg
node scripts/diagram/render-prompt.mjs docs/diagrams/evolution-workflow.intent.json docs/diagrams/evolution-workflow.layout.plan.json docs/diagrams/evolution-workflow.image-prompt.md
```

## Quality Gate

Before calling a diagram complete, verify:

- Main chain is immediately readable.
- Branches are aligned and grouped.
- Merge node returns to the main axis.
- Arrows do not cross.
- Feedback route stays outside the main body.
- SVG and prompt are regenerated from the same intent/layout files.
