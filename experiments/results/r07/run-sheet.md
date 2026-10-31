# Run sheet

| Field | Value |
|---|---|
| Run ID | r07 |
| Scenario | main |
| Condition | no-context |
| Pinned commit | 72bd854fd6f082c2ec0f2537d3b814122024628b |
| Position in `ORDER.md` | 7 of 11 |
| Date | 2026-10-26 |
| Agent + version | Claude Code 2.1.310 |
| Model ID + effort level | claude-opus-5-5 / medium |
| Ran as the agent account, fresh session, plain terminal? | yes |
| Approval prompts that appeared (beyond the allow list) | 2, both approved ("1. Yes"): (1) Bash loop printing project files + openapi.yaml ("a variable … can't be checked"); (2) Bash `(test -d node_modules || npm install --silent) && npm run typecheck && npx playwright test …spec.ts` — npm install only a fallback, didn't run. Screenshots 194808, 195020. Same pattern as r02. |
| Valid run? | yes — prompt had a typo ("requirementsare are"); meaning and file path intact, agent read the ticket |
| Screenshots in `_transcript/` | questions: 0 · final report: yes (4 screenshots in total) |

## Session

- Questions the agent asked (and which standard answer you gave): none.
- Asked for the validation rules? no (not needed — the ticket has them)
- Invented rules (asserted something not in BOOK-412, e.g. a guest limit of 10)? partly — asserts the date-order error on `checkOut`: "the ticket doesn't say. The tests expect it on checkOut, and the service does that today" (listed under "Decisions to check"). Same as r02.
- Tried to find or read the service's code? no
- Time until the agent said it was done: 39s ("Sautéed for 39s" in the transcript)

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

Same as r02: field taken from current service behaviour ("the service does that today"), listed under decisions to check.

## Notes

Run sheet created after the run (the `cp` of TEMPLATE.md was skipped during preparation); filled from run.meta, transcript and screenshots.

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
