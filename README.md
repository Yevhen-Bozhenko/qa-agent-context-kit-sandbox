# QA Agent Context Kit — Sandbox

A small, controlled Playwright + TypeScript project for a **recorded comparison** of the
[QA Agent Context Kit](https://github.com/Yevhen-Bozhenko/qa-agent-context-kit): the same QA task,
given to an AI coding agent with different amounts of project context.

The task: **add negative API tests for `POST /api/v2/bookings` validation** (ticket BOOK-412).

| Question | Compared |
|---|---|
| Does persistent context improve adherence to the existing framework? | no context vs. persistent context |
| Do structured task instructions improve requirement coverage? | persistent context vs. full pattern |
| Does validation guidance produce tests that catch real defects? | all three, against injected bugs |
| With requirements missing, does the agent ask instead of invent? | separate scenario |

In the main comparison **every condition gets the same requirements** (`docs/tickets/BOOK-412.md`);
only the context files and the task-instruction structure change. Missing requirements are tested
in a separate scenario.

This repo is deliberately small. It is not a benchmark framework — it exists so the kit's
comparison can show real agent output instead of illustrations. The repo root is also a
**worked example of the kit**: `AGENTS.md` and `.ai/` show the template filled in for a real project.

## What's inside

```
AGENTS.md, CLAUDE.md       the kit's agent instructions (unchanged from the template)
.github/copilot-instructions.md
.ai/qa-context.md          the kit's QA context, filled in for this project
.ai/framework-guide.md     the kit's framework guide, filled in for this project
.ai/tasks/                 the BOOK-412 task file (full condition only)
docs/tickets/              tickets with acceptance criteria — the requirements
docs/openapi.yaml          request/response shapes, without the business rules
src/                       the "existing framework": clients, builders, fixtures, models, utils
tests/api/                 reference tests the agent should imitate
mock-api/server.mjs        zero-dependency mock of the Bookings API with switchable bugs (MOCK_BUG);
                           runs as a separate service — never inside a run folder
experiments/
  PROTOCOL.md              questions, conditions, controls, scoring
  clarification.md         fixed answers to the agent's questions
  scripts/                 prepare-run, start-service, check-run, archive-run, selftest-checker
  checker-selftest/        synthetic fixtures that validate the checker (not results)
  results/TEMPLATE.md      run sheet + summary tables
  results/ORDER.md         the fixed, blocked-random run order (r01–r11)
  results/PILOT.md         the pilot run that verified isolation and the evidence workflow
```

## Quick start

Requires Node.js 18+, git and curl. No browsers needed (API tests only).

```bash
npm ci
node mock-api/server.mjs &          # the Bookings service on :4010
npx playwright test                 # reference tests
npm run typecheck
```

One run of the experiment, pinned to the `experiment-v1` tag:

```bash
experiments/scripts/selftest-checker.sh experiment-v1                 # verify the checker
experiments/scripts/prepare-run.sh main persistent experiment-v1 r01  # creates C:\runs\r01
experiments/scripts/start-service.sh experiment-v1                    # separate terminal
#   → as the agent's own OS account: new session in C:\runs\r01, send the printed prompt,
#     then copy the transcripts into C:\runs\r01\_transcript\
experiments/scripts/check-run.sh r01      # evidence → runs/r01/
experiments/scripts/archive-run.sh r01    # run folder → runs/r01/workspace/, C:\runs emptied
```

The experiment scripts were verified on Windows (Git Bash). On macOS/Linux they fall back to
`chmod` for the archive's permissions, and that path hasn't been tested.

Run IDs are neutral on purpose: nothing in a run folder reveals its condition. The mapping lives
in `runs/<id>/run.meta`, outside the agent's reach. Full instructions, including the agent-account
setup and the pilot: [experiments/PROTOCOL.md](experiments/PROTOCOL.md).

## Why the injected bugs matter

"The tests pass" proves little. `check-run.sh` re-runs the agent's tests against three
deliberately broken versions of the service:

| `MOCK_BUG` | Defect | Caught only if the tests… |
|---|---|---|
| `equal-dates` | same-day check-out accepted | cover the checkOut = checkIn case |
| `wrong-field` | error reported on the wrong field | assert `errors[].field`, not only the status |
| `guests-upper` | 9 guests accepted | test the upper boundary exactly |

A good test suite fails on all three. That is the difference between tests that pass and tests
that prove the requirement.

## Results

Recorded runs go in [`experiments/results/`](experiments/results/) and are summarised in the
kit's [comparison](https://github.com/Yevhen-Bozhenko/qa-agent-context-kit/blob/main/docs/comparison.md#recorded-results).

## License

[MIT](LICENSE) © 2026 Yevhen Bozhenko
