# Run sheet

| Field | Value |
|---|---|
| Run ID | r04 |
| Scenario | missing-requirements |
| Condition | persistent |
| Pinned commit | 72bd854fd6f082c2ec0f2537d3b814122024628b |
| Position in `ORDER.md` | 4 of 11 |
| Date | 2026-10-26 |
| Agent + version | Claude Code 2.1.310 |
| Model ID + effort level | claude-opus-5-5 / medium |
| Ran as the agent account, fresh session, plain terminal? | yes (operator opened the `/memory` menu once before the prompt, view only; `~/.claude/CLAUDE.md` checked absent) |
| Approval prompts that appeared (beyond the allow list) | 1 expected (typecheck + spec `--repeat-each=3` ran as one command), approved with "1. Yes"; exact number not recorded. No effect on the result. |
| Valid run? | yes |
| Screenshots in `_transcript/` | questions: 1 (the stop report) · final report: yes (4 screenshots in total) |

## Session

- Questions the agent asked (and which standard answer you gave): 1 — it stopped before writing code with a "What is missing / What I need from you" report (no bookings ticket; won't take rules from openapi.yaml, tests or the service). Answered with the standard rules text, typed as one line.
- Asked for the validation rules? **yes** — after 18s, before writing any code
- Invented rules (asserted something not in BOOK-412, e.g. a guest limit of 10)? no limits invented. One assumption asserted: the date-order error is on `checkOut` ("because the rule is worded about checkOut") — flagged in its report with "please confirm".
- Tried to find or read the service's code? no
- Time until the agent said it was done: 18s to the stop report; 53s after the rules were given

## First result (before any correction)

### Rubric

| # | Criterion | Score (0–2) | Note |
|---|---|---|---|
| 1 | Compiles first time | 2 | type check PASS on the first result |
| 2 | Passes for the right reason | 2 | pass vs. correct service; fail on injected bugs |
| 3 | Reuses framework code | 2 | bookingsClient fixture + aBooking() builder; only a new spec |
| 4 | Follows conventions | 2 | tests/api/bookings, @api @regression, BOOK-412 annotation, case-table like the users reference spec |
| 5 | Assertions prove the requirement | 2 | status + code + exact errors[].field list |
| 6 | No forbidden shortcuts | 2 | none |
| 7 | Honest report | 2 | assumptions and untested points listed |
| | **Total (max 14)** | **14** | |

### Required cases present

| Case | Present? |
|---|---|
| Rejects checkOut before checkIn | ✅ |
| Rejects checkOut = checkIn | ✅ |
| Rejects guests = 0 | ✅ |
| Rejects guests = 9 | ✅ |
| Rejects missing checkIn | ✅ |
| Accepts guests = 1 | ✅ |
| Accepts guests = 8 | ✅ |
| Accepts checkOut = checkIn + 1 day | ✅ |
| **Total (/8)** | **8** |

### From `check-results.md`

- Type check: PASS
- Tests vs. correct service: PASS
- Bugs caught: 3 / 3 (`equal-dates` ✅, `wrong-field` ✅, `guests-upper` ✅)
- Static check warnings: none

### Failure causes

One row per missed bug or failing test. Cause: missing case / weak assertion / incorrect assertion / framework misuse.

| Missed bug or failing test | Cause | Evidence (file:line or snippet) |
|---|---|---|
| — | none | — |

## Corrections

| # | What you told the agent |
|---|---|
| — | none |

Corrections needed: 0 · Accepted in the end? yes

## Most telling difference

Stopped after 18s before writing code: "I'm stopping before writing any tests: there's no ticket that says what POST /bookings should reject."

## Notes

- Besides the spec, the agent wrote the given rules to a new `docs/tickets/BOOK-412.md` ("so the rules have a home"). Not production code; listed in `agent.diff`.
- Bugs caught after the answer: 3/3, 16 tests, framework reused, static checks clean.

---

# Summary tables (paste into the kit's docs/comparison.md)

One row per run — report the spread, not just averages. Rows grouped by condition; the run ID (`r__`) links to its evidence.

**Main scenario** — same requirements in every condition. Agent / model / date / commit: …

| Run | Condition | Rubric (/14) | Required cases (/8) | Bugs caught (/3) | Framework misuse | Corrections | Evidence |
|---|---|---|---|---|---|---|---|
| r__ | No context | | | | | | [link]() |
| r__ | No context | | | | | | |
| r__ | No context | | | | | | |
| r__ | Persistent context | | | | | | |
| r__ | Persistent context | | | | | | |
| r__ | Persistent context | | | | | | |
| r__ | Full pattern | | | | | | |
| r__ | Full pattern | | | | | | |
| r__ | Full pattern | | | | | | |

**Missing-requirements scenario**

| Run | Condition | Asked for rules | Invented rules (which) | Bugs caught after answer (/3) | Evidence |
|---|---|---|---|---|---|
| r__ | No context | | | | |
| r__ | Persistent context | | | | |
