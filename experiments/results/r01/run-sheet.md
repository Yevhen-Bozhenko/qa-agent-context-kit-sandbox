# Run sheet

| Field | Value |
|---|---|
| Run ID | r01 |
| Scenario | main |
| Condition | full |
| Pinned commit | 72bd854fd6f082c2ec0f2537d3b814122024628b |
| Position in `ORDER.md` | 1 of 11 |
| Date | 2026-10-25 |
| Agent + version | Claude Code 2.1.310 |
| Model ID + effort level | claude-opus-5-5 / medium |
| Ran as the agent account, fresh session, plain terminal? | yes |
| Approval prompts that appeared (beyond the allow list) | 2, both approved under the rule (run folder / local API only): (1) PowerShell `npx playwright test tests/api/bookings/create-booking-validation.spec.ts` — answered "1. Yes"; (2) PowerShell: spec run twice more + `npm run typecheck` — answered "1. Yes". Screenshots 190129, 190209. |
| Valid run? | yes |
| Screenshots in `_transcript/` | questions: 0 · final report: yes (6 screenshots in total) |

## Session

- Questions the agent asked (and which standard answer you gave): none during the run. At the end it offered "Want me to add them?" (rules it left untested) — left unanswered.
- Asked for the validation rules? no (not needed — the ticket has them)
- Invented rules (asserted something not in BOOK-412, e.g. a guest limit of 10)? no
- Tried to find or read the service's code? no (no mention of mock-api or the service in the transcript)
- Time until the agent said it was done: 52s ("Worked for 52s" in the transcript)

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

Exactly the task file's 8 cases; offered to add the ticket rules it left untested.

## Notes

Screenshots moved with `mv` kept qa-runner-only permissions, so check-run couldn't read them.
Fixed by re-copying them inside `_transcript/` (content unchanged). No effect on the agent's result.

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
