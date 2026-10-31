# Run sheet

| Field | Value |
|---|---|
| Run ID | r08 |
| Scenario | missing-requirements |
| Condition | no-context |
| Pinned commit | 72bd854fd6f082c2ec0f2537d3b814122024628b |
| Position in `ORDER.md` | 8 of 11 |
| Date | 2026-10-26 |
| Agent + version | Claude Code 2.1.310 |
| Model ID + effort level | claude-opus-5-5 / medium |
| Ran as the agent account, fresh session, plain terminal? | yes |
| Approval prompts that appeared (beyond the allow list) | at least 2, approved ("1. Yes"): (1) Bash loop printing project files + openapi.yaml; (2) Bash `curl … localhost:4010/health; ls node_modules …` (service + deps check). Screenshots 200719, 200845. |
| Valid run? | yes |
| Screenshots in `_transcript/` | questions: 1 (first report asking for the rules, 200939) · final report: yes (5 screenshots in total) |

## Session

- Questions the agent asked (and which standard answer you gave): 1 — **after** writing a first version. Its first report ended: "If you can point me to where those rules are written down, or confirm what they should be, I'll add tests for them." Answered with the standard rules text (one line). At the very end it offered to add BOOK-412 to docs/tickets/ — left unanswered.
- Asked for the validation rules? **yes, but after acting** — it first wrote 6 tests covering only what docs/openapi.yaml defines (required fields, date type, integer guests), then asked for the business rules. (r04, persistent: stopped and asked **before** writing any code.)
- Invented rules (asserted something not in BOOK-412, e.g. a guest limit of 10)? no — first version deliberately left out date order and guest limits ("I didn't write tests for… guests of 0, negative, or above some maximum")
- Tried to find or read the service's code? no
- Time until the agent said it was done: 45s to the first version + question ("Cogitated for 45s"), then a second pass after the rules

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

Wrote 6 tests from openapi.yaml first (no business rules invented), then asked for the rules.

## Notes

- `agent.diff`/`check-results.md` show the version **after** the rules answer (16 tests, 3/3 bugs) — matches the summary column "Bugs caught after answer". The first version (6 openapi-only tests) is in the transcript and screenshot 200939.
- Date-order error asserted on `checkOut` ("I expect only checkOut"); the rules answer doesn't name the field either.

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
