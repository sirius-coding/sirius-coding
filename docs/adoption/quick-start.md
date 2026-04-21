# Quick Start

Use this guide when creating a new workspace from the Sirius Evolution Station template.

## 1. Create the Repository

Use the GitHub template repository:

```text
https://github.com/sirius-coding/sirius-evolution-station-template
```

Create a new repository from the template. Keep it public only if all future tracked content can remain public-safe.

## 2. Read the Root Rules

Start with:

- `AGENTS.md`
- `specs/workspace/evolution-handbook.md`
- `specs/workspace/control-layer-os.md`

These files define the operating model and the root/project boundary.

## 3. Create a Private Environment Overlay

```bash
cp docs/ops/environment-registry.private.example.yaml docs/ops/environment-registry.private.yaml
```

Keep the copied file ignored by git. Put real environment values only in that private overlay.

## 4. Run the Audit

```bash
./scripts/root-repo-structure-audit.sh --strict
```

Fix missing files, broken README links, YAML/TOML parse errors, or public/private boundary issues before adding project work.

## 5. Add Your First Project

Create project implementation under `projects/<project-name>` or connect an independent repository. Keep reusable rules, checks, and workflow lessons in the root control layer.

## 6. Record the First Evolution

After the first meaningful task, update one of:

- `docs/`
- `specs/`
- `skills/`
- `scripts/`

If nothing needs to be persisted, write down why in the task result. The template is valuable only when durable learning moves out of chat and into tracked assets.
