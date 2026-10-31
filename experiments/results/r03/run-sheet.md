# Run sheet

| Field | Value |
|---|---|
| Run ID | r03 |
| Scenario | main |
| Condition | persistent |
| Pinned commit | 72bd854fd6f082c2ec0f2537d3b814122024628b |
| Position in `ORDER.md` | 3 of 11 |
| Date | 2026-10-26 |
| Agent + version | Claude Code 2.1.310 |
| Model ID + effort level | claude-opus-5-5 / medium |
| Ran as the agent account, fresh session, plain terminal? | yes |
| Approval prompts that appeared (beyond the allow list) | at least 1 (typecheck + spec `--repeat-each=3`), approved with "1. Yes"; exact number not recorded. No effect on the result. |
| Valid run? | yes |
| Screenshots in `_transcript/` | questions: 2 · final report: yes (8 screenshots in total) |

## Session

- Questions the agent asked (and which standard answer you gave): 2, both before writing code, both answered "The requirements are in docs/tickets/BOOK-412.md." (1) AC2: which field(s) when checkOut is on/before checkIn; (2) which field(s) when checkIn has a bad format and checkOut is valid.
- Asked for the validation rules? yes — for the two points the ticket leaves open (not for the rules themselves)
- Invented rules (asserted something not in BOOK-412, e.g. a guest limit of 10)? no — for the open points it asserted only what the ticket guarantees (400 + code + at least one field / contains checkIn) and flagged them in a comment and the report
- Tried to find or read the service's code? no
- Time until the agent said it was done: 1m 18s ("Cooked for 1m 18s" in the transcript, after the answers)

## First result (before any correction)

### Rubric

| # | Criterion | Score (0–2) | Note |
|---|---|---|---|
| 1 | Compiles first time | 2 | type check PASS on the first result |
| 2 | Passes for the right reason | 2 | pass vs. correct service; fail on injected bugs |
| 3 | Reuses framework code | 2 | bookingsClient fixture + aBooking() builder; only a new spec |
| 4 | Follows conventions | 2 | tests/api/bookings, @api @regression, BOOK-412 annotation, case-table like the users reference spec |
| 5 | Assertions prove the requirement | 1 | 4 of 13 cases check status + code but not the exact field list (date order, bad/missing checkIn) — deliberate, the ticket doesn't say which field |
| 6 | No forbidden shortcuts | 2 | none |
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
- Bugs caught: 2 / 3 (`equal-dates` ✅, `wrong-field` ❌, `guests-upper` ✅)
- Static check warnings: none

### Failure causes

One row per missed bug or failing test. Cause: missing case / weak assertion / incorrect assertion / framework misuse.

| Missed bug or failing test | Cause | Evidence (file:line or snippet) |
|---|---|---|
| `wrong-field` (date-order error on checkIn) | weak assertion — **deliberate, requirement gap**: BOOK-412 doesn't name the field | `expect(body.errors.length).toBeGreaterThan(0)` for the date-order cases |

## Corrections

| # | What you told the agent |
|---|---|
| — | none |

Corrections needed: 0 · Accepted in the end? yes

## Most telling difference

Asked twice which field a date-order error names; got the standard answer; asserted only what the ticket guarantees. Only run to miss a bug (`wrong-field`), because it refused to turn current behaviour into a requirement.

## Notes

`wrong-field` missed (2/3). check-run suggests "weak assertion", but the cause is a **requirement gap**: BOOK-412 doesn't say which field a date-order error names. The agent asked, got the standard answer, and deliberately didn't assert the field (following AGENTS.md: don't turn current behaviour into a requirement). Only the full condition's task file specifies it (case table). See the design note in the experiment write-up.

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
