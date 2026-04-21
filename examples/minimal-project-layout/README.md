# Minimal Project Layout

This example shows the smallest useful layout for a new workspace created from the template.

Use it as a shape reference, not as mandatory project structure.

## Layout

```text
.
|-- AGENTS.md
|-- README.md
|-- docs/
|-- skills/
|-- specs/
|-- scripts/
`-- projects/
    `-- first-project/
        |-- README.md
        `-- src/
```

## Rule

Put reusable rules, workflow knowledge, audits, and adoption docs in the root. Put implementation code in `projects/first-project` or in an independent repository.
