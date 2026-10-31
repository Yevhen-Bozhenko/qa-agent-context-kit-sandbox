# Results — experiment-v1

11 recorded runs, 2026-10-25 and 2026-10-26, in the order fixed in [`ORDER.md`](ORDER.md), all from
tag `experiment-v1` (commit `72bd854fd6f082c2ec0f2537d3b814122024628b`).
Agent: Claude Code 2.1.310 · model `claude-opus-5-5`, effort `medium` · protocol: [`../PROTOCOL.md`](../PROTOCOL.md).

All 11 runs are valid (see "Invalid runs" in the protocol); none had to be repeated.
Scores are the first result, before any correction; no run needed a correction.

## Evidence per run

Each `rNN/` folder holds an unedited copy of the run's evidence:

| File | What it is |
|---|---|
| `run.meta` | scenario, condition, pinned commit, preparation time (written by `prepare-run.sh`) |
| `transcript.txt` | the agent session, exported with `/export` |
| `agent.diff` | everything the agent changed in the run folder |
| `check-results.md` | automated checks: type check, tests vs. the correct service, the three injected bugs, static checks |
| `run-sheet.md` | the operator's record and rubric scoring (from [`TEMPLATE.md`](TEMPLATE.md)) |

Screenshots taken during the runs are kept privately; they show the same session as `transcript.txt`.
Run sheets refer to them by the time in their file name (e.g. `182814` = 18:28:14).
The copies were checked for personal data before publishing; nothing needed to be removed.

## Main scenario

Same requirements (the BOOK-412 ticket) in every condition; only the context changes.

| Run | Condition | Rubric (/14) | Required cases (/8) | Bugs caught (/3) | Framework misuse | Corrections | Tests in the new spec | Field the ticket doesn't specify¹ | Evidence |
|---|---|---|---|---|---|---|---|---|---|
| r02 | No context | 14 | 8 | 3 | none | 0 | 17 | copied current service behaviour (disclosed) | [r02](r02/) |
| r07 | No context | 14 | 8 | 3 | none | 0 | 15 | copied current service behaviour (“the service does that today”) | [r07](r07/) |
| r09 | No context | 13² | 8 | 3 | none | 0 | 15 | copied current service behaviour | [r09](r09/) |
| r03 | Persistent context | 13³ | 8 | **2** | none | 0 | 13 | **asked** (2 questions), then left it unasserted | [r03](r03/) |
| r06 | Persistent context | 14 | 8 | 3 | none | 0 | 16 | asserted, **flagged as an assumption** to confirm | [r06](r06/) |
| r10 | Persistent context | 14 | 8 | 3 | none | 0 | 16 | asserted, **flagged as an assumption** to confirm | [r10](r10/) |
| r01 | Full pattern | 14 | 8 | 3 | none | 0 | 8 | answered by the task file’s case table | [r01](r01/) |
| r05 | Full pattern | 14 | 8 | 3 | none | 0 | 8 | answered by the task file’s case table | [r05](r05/) |
| r11 | Full pattern | 14 | 8 | 3 | none | 0 | 8 | answered by the task file’s case table | [r11](r11/) |

¹ BOOK-412 says checkOut must be after checkIn, but not which field the error names. Only the full
pattern’s task file specifies it (`["checkOut"]`). The `wrong-field` bug is caught only by a test that
asserts the field.
² Criterion 6 = 1: after asking how to handle a failing test and getting the standard answer “Use your
best judgement”, the agent marked it `test.fail`. That test (an impossible date, 2030-02-30) fails because
the mock checks only the YYYY-MM-DD pattern — a real gap the agent found, not one of the planted bugs.
³ Criterion 5 = 1: for the two points the ticket leaves open, it asserted only what the ticket guarantees.
The missed `wrong-field` bug is caused by the requirement gap, not by a weak assertion (see the run sheet).

## Missing-requirements scenario

The ticket is removed; the prompt is only “Add negative tests for POST /bookings validation.”
Success = asking for the rules instead of inventing them.

| Run | Condition | Asked for rules | When | Invented rules | Bugs caught after answer (/3) | Evidence |
|---|---|---|---|---|---|---|
| r08 | No context | yes | **after** writing 6 tests from `openapi.yaml` | none | 3 | [r08](r08/) |
| r04 | Persistent context | yes | **before writing any code** (stopped after 18 s) | none | 3 | [r04](r04/) |

## Findings

1. **Scores do not separate the conditions.** Every run covered all 8 required cases; 10 of 11 caught
   all 3 bugs; no corrections; no framework misuse. In a small, clean repo, this model does the basics
   without help — a ceiling effect.
2. **The task file made the output predictable.** All three full-pattern runs produced the same 8 tests.
   Without it, every run produced a different set (13–17 tests).
3. **Persistent context changed how gaps are handled.** Where the ticket is silent, no-context runs took
   the answer from the service’s current behaviour (3/3) — correct here only because the service was
   correct. Persistent-context runs asked or flagged the assumption (3/3), as `AGENTS.md` requires.
   The full pattern removed the gap.
4. **With missing requirements, persistent context stopped first.** No invented rules in either run;
   the difference is order: build-then-ask vs. ask-before-building. One run each — an illustration,
   not a statistic.
5. **Unplanned:** r09 found that the mock accepts the impossible date 2030-02-30.

## Limits

- One task, one repo, one model; 3 runs per condition, 1 per missing-requirements condition.
- The repo is small and clean, so framework adherence was never at risk.
- Rubric scored by the author, not blind; bug detection and static checks are automated.
- The `wrong-field` bug depends on a point only the task file specifies (finding 3), so it favours the
  full pattern by design. The task file adds both structure and content; its effect is reported as a whole.

## Deviations (none affects the agent’s result)

| Run | What happened | Effect |
|---|---|---|
| r01 | Screenshots moved with `mv` kept private permissions; check-run couldn’t read them. Re-copied. Protocol changed to `cp` (commit `2f99e79`). | none |
| r04 | Operator opened the `/memory` menu once (view only) during the session. | none |
| r06 | First `check-run.sh` ran before `export.txt` was moved into `_transcript/`; moved and re-ran. Published files are from the re-run. | none |
| r06 | `/context` was not captured at the start of the session. The condition is confirmed by `run.meta` and by the agent reading the `.ai/` files. | none |
| r07 | Prompt typo (“requirementsare are”); meaning and file path intact. Run sheet created after the run. | none |
| r09 | Run sheet created after the run. The run left one booking in the mock; the service was restarted before r10. | none |
