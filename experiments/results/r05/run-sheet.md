# Run sheet

| Field | Value |
|---|---|
| Run ID | r05 |
| Scenario | main |
| Condition | full |
| Pinned commit | 72bd854fd6f082c2ec0f2537d3b814122024628b |
| Position in `ORDER.md` | 5 of 11 |
| Date | 2026-10-26 |
| Agent + version | Claude Code 2.1.310 |
| Model ID + effort level | claude-opus-5-5 / medium |
| Ran as the agent account, fresh session, plain terminal? | yes |
| Approval prompts that appeared (beyond the allow list) | 2, both approved ("1. Yes"): (1) PowerShell `npx playwright test tests/api/bookings/create-booking-validation.spec.ts`; (2) PowerShell: spec run twice more + `npm run typecheck`. Screenshots 182814, 182918. Same two as r01. |
| Valid run? | yes |
| Screenshots in `_transcript/` | questions: 0 · final report: yes (4 screenshots in total) |

## Session

- Questions the agent asked (and which standard answer you gave): none. At the end it offered to switch cleanup to try/finally — left unanswered.
- Asked for the validation rules? no (not needed — ticket and task file have them)
- Invented rules (asserted something not in BOOK-412, e.g. a guest limit of 10)? no — field per case taken from the task file's case table; flagged that "checkIn missing → only checkIn" comes from the task table, not spelled out in AC4
- Tried to find or read the service's code? no
- Time until the agent said it was done: 55s ("Brewed for 55s" in the transcript)

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

Same 8 cases as r01 — the full pattern gives the same test set every time.

## Notes

Same 8 cases and structure as r01 (only naming differs: `fields: string[]` instead of `field`). Consistent with r01.

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
