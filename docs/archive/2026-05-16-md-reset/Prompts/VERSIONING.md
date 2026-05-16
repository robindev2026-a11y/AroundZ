# Prompt Versioning

Status: historical/reference.

Prompt versioning was used during the earlier prompt-generation phase. Current work is coding and verification, so prompt files are not the active source of truth.

If the user asks to create a new prompt, use semantic versioning:
- `MAJOR` for breaking task/output changes.
- `MINOR` for new backward-compatible requirements.
- `PATCH` for wording fixes and clarifications.

Current source-of-truth files:
- `AGENTS.md`
- `Planning/context.md`
- `Planning/spec.md`
- `Planning/architecture.md`
- `Design/design-tokens.md`
- `Design/design-system.md`
- `Design/screens.md`
- `Design/component-specs.md`
