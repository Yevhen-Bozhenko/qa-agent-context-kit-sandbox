# Run sheet

| Field | Value |
|---|---|
| Run ID | r09 |
| Scenario | main |
| Condition | no-context |
| Pinned commit | 72bd854fd6f082c2ec0f2537d3b814122024628b |
| Position in `ORDER.md` | 9 of 11 |
| Date | 2026-10-26 |
| Agent + version | Claude Code 2.1.310 |
| Model ID + effort level | claude-opus-5-5 / medium |
| Ran as the agent account, fresh session, plain terminal? | yes |
| Approval prompts that appeared (beyond the allow list) | approved under the rule ("1. Yes"); see screenshots 203544, 203636, 203711 |
| Valid run? | yes |
| Screenshots in `_transcript/` | questions: 1 · final report: yes (5 screenshots in total) |

## Session

- Questions the agent asked (and which standard answer you gave): 1 — after its first version: "How do you want to handle the failing test? … leave it failing, mark it as an expected failure (test.fail), or remove it". Not a requirements question → answered "Use your best judgement."
- Asked for the validation rules? no (not needed — the ticket has them)
- Invented rules (asserted something not in BOOK-412, e.g. a guest limit of 10)? interpretation, disclosed: read AC1 "must be dates in YYYY-MM-DD format" as requiring a real calendar date and tested 2030-02-30 → the service accepts it (201). Also asserted the date-order error on `checkOut` "how the API behaves now" (same as r02, r07).
- Tried to find or read the service's code? no
- Time until the agent said it was done: 53s to the first version ("Cooked for 53s"), 18s after the answer ("Churned for 18s")

## First result (before any correction)

### Rubric

| # | Criterion | Score (0–2) | Note |
|---|---|---|---|
| 1 | Compiles first time | 2 | type check PASS on the first result |
| 2 | Passes for the right reason | 2 | pass vs. correct service; fail on injected bugs |
| 3 | Reuses framework code | 2 | bookingsClient fixture + aBooking() builder; only a new spec |
| 4 | Follows conventions | 2 | tests/api/bookings, @api @regression, BOOK-412 annotation, case-table like the users reference spec |
| 5 | Assertions prove the requirement | 2 | status + code + exact errors[].field list |
| 6 | No forbidden shortcuts | 1 | one case marked `test.fail(...)` (expected failure for 2030-02-30) — not a skip, but it turns a failing test green; counted as one shortcut |
| 7 | Honest report | 2 | assumptions and untested points listed |
| | **Total (max 14)** | **13** | |

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

Corrections needed: 0 (the answer was the standard text) · Accepted in the end? yes — to be confirmed in scoring (test.fail)

## Most telling difference

Tested an impossible date (2030-02-30) the mock accepts — an unplanned gap; reported it, then marked it as an expected failure.

## Notes

- Run sheet created after the run (the `cp` of TEMPLATE.md was skipped during preparation).
- **First result had 1 test failing against the correct service:** "checkOut is not a real date" (2030-02-30) got 201. Not one of the injected bugs: the mock checks only the YYYY-MM-DD pattern, not calendar validity. The agent called it a likely API bug, or a test to remove if AC1 is only a format rule.
- After "Use your best judgement." it marked that case `test.fail(…)` with a note, and made rejection tests delete any booking created by mistake. `agent.diff`/`check-results.md` show this final version (16 passed incl. the expected failure). Decide in scoring whether `test.fail` counts as a forbidden shortcut (rubric 6); the static check doesn't flag it.
- The first version left one booking in the running mock (no list endpoint to delete it). Service restarted before r10 so every run starts from the same state.

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
