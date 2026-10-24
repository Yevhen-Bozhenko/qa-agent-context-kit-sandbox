# AGENTS.md — instructions for AI coding agents

This repository contains automated tests. Before you write or change anything,
load the project context below. Treat it as binding unless a task file says otherwise.

## Read first (every session)

1. `.ai/qa-context.md` — what this project is, stack, commands, conventions, forbidden things.
2. `.ai/framework-guide.md` — how the test framework is built and how to extend it.
3. The task file you were pointed at in `.ai/tasks/` (if any).

If any of these files contradict each other, the more specific one wins:
task file > framework guide > QA context > this file.

## Before you start: check the context you need

Identify which parts of the context *this task* depends on (for example: how to run tests,
where API clients live, the reference test for this kind of test). If any of those parts is
missing or still says `TODO`, stop and report exactly what is missing before writing code.

`TODO`s in sections this task does not use are not a reason to stop — mention them at most
as a suggestion at the end.

## Working rules

- **Reuse before you create.** Search for an existing page object, API client, fixture,
  helper or test-data builder before writing a new one. Say which ones you reused.
- **Follow the reference tests.** `.ai/framework-guide.md` lists golden examples.
  New tests should look like they were written by the same team.
- **Never weaken a test to make it pass.** Do not delete assertions, widen matchers,
  add retries, increase timeouts or add `skip`/`only` unless the task explicitly asks.
- **No hard waits.** No `sleep`, `Thread.sleep`, `waitForTimeout` or equivalents.
- **Do not change production code** unless the task explicitly asks for it.
  If a test fails because of a suspected product bug, stop and report it.
- **Do not invent APIs.** If a selector, endpoint, field or helper is not visible in the
  code or the task, ask or mark it as an assumption — do not guess silently.
- **Do not guess expected behaviour.** What a test asserts must come from an authoritative
  source: a specification, acceptance criteria, or a business rule confirmed in the task.
  Existing tests and the application's current behaviour are clues, not requirements —
  they may encode a bug. If the expected behaviour is not specified, ask for it or report
  the task as blocked; never turn an assumption into an assertion.
- **Run what you wrote.** Run the narrowest command that covers your change
  (see "How to run" in `.ai/qa-context.md`). Run lint/type checks too.

## When you finish, report

1. What you changed (files, one line each).
2. What you reused vs. created new.
3. Commands you ran and their result (pass/fail counts).
4. Assumptions you made and anything you could not verify.
5. Suggested additions to `.ai/qa-context.md` if you hit something it should have told you.
