# Run sheet

| Field | Value |
|---|---|
| Run ID | e.g. `r04` |
| Scenario | main / missing-requirements (from `run.meta`) |
| Condition | no-context / persistent / full (from `run.meta`) |
| Pinned commit | (from `run.meta` → commit) |
| Position in `ORDER.md` | |
| Date | |
| Agent + version | |
| Model ID + effort level | |
| Ran as the agent account, fresh session, plain terminal? | yes / no |
| Approval prompts that appeared (beyond the allow list) | |

## Session

- Questions the agent asked (and which standard answer you gave):
- Asked for the validation rules? yes / no
- Invented rules (asserted something not in BOOK-412, e.g. a guest limit of 10)? yes / no — which:
- Tried to find or read the service's code? yes / no
- Time until the agent said it was done:

## First result (before any correction)

### Rubric

| # | Criterion | Score (0–2) | Note |
|---|---|---|---|
| 1 | Compiles first time | | |
| 2 | Passes for the right reason | | |
| 3 | Reuses framework code | | |
| 4 | Follows conventions | | |
| 5 | Assertions prove the requirement | | |
| 6 | No forbidden shortcuts | | |
| 7 | Honest report | | |
| | **Total (max 14)** | | |

### Required cases present

| Case | Present? |
|---|---|
| Rejects checkOut before checkIn | |
| Rejects checkOut = checkIn | |
| Rejects guests = 0 | |
| Rejects guests = 9 | |
| Rejects missing checkIn | |
| Accepts guests = 1 | |
| Accepts guests = 8 | |
| Accepts checkOut = checkIn + 1 day | |
| **Total (/8)** | |

### From `check-results.md`

- Type check: PASS / FAIL
- Tests vs. correct service: PASS / FAIL
- Bugs caught: _ / 3 (`equal-dates` _, `wrong-field` _, `guests-upper` _)
- Static check warnings:

### Failure causes

One row per missed bug or failing test. Cause: missing case / weak assertion / incorrect assertion / framework misuse.

| Missed bug or failing test | Cause | Evidence (file:line or snippet) |
|---|---|---|
| | | |

## Corrections

| # | What you told the agent |
|---|---|
| 1 | |

Corrections needed: _ · Accepted in the end? yes / no (stopped at 5)

## Most telling difference

One or two sentences, with a short snippet from `agent.diff` if useful.

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
