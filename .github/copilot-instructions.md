# Copilot instructions

The single source of truth for AI agent instructions in this repository is `AGENTS.md`
at the repository root, plus `.ai/qa-context.md` and `.ai/framework-guide.md`.
Read and follow them before generating or changing tests.

Short version of the non-negotiables:

- Reuse existing page objects, API clients, fixtures and helpers before creating new ones.
- Match the style of the reference tests listed in `.ai/framework-guide.md`.
- Never weaken assertions, add retries, raise timeouts or skip tests to make them pass.
- No hard waits (`sleep`, `waitForTimeout`, `Thread.sleep`).
- Do not modify production code unless explicitly asked.
- Do not invent selectors, endpoints or helpers — ask, or label the assumption.
- Do not guess expected behaviour: take it from a spec, acceptance criteria or a confirmed
  business rule. Existing tests and current behaviour are clues, not requirements. If it's
  not specified, ask or report the task as blocked.
- If context this task depends on is missing or still `TODO`, stop and say what is missing.
