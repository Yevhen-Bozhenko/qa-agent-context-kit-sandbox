# Automated checks — r04

Baseline: scenario `missing-requirements` · condition `persistent` · commit `72bd854fd6f082c2ec0f2537d3b814122024628b`

## 1. Files changed by the agent (full diff: agent.diff)
```
 docs/tickets/BOOK-412.md                           | 12 ++++
 .../api/bookings/create-booking-validation.spec.ts | 76 ++++++++++++++++++++++
 2 files changed, 88 insertions(+)
```

## 2. Type check
PASS

## 3. Booking tests vs. correct service (expected: all pass)
PASS — 17 passed

## 4. Injected bugs (expected: every bug caught = at least one test fails)

| Bug | Caught? | Result | Likely cause if missed (verify in the diff) |
|---|---|---|---|
| `equal-dates` | ✅ caught | 1 failed,16 passed | — |
| `wrong-field` | ✅ caught | 2 failed,15 passed | — |
| `guests-upper` | ✅ caught | 2 failed,15 passed | — |

**Bugs caught: 3 / 3**

## 5. Static checks on the agent's changes
- ✅ No hard waits / timeouts / retries / skips
- ✅ No raw HTTP calls (framework bypass)
- ✅ No imports from @playwright/test in specs (should use src/fixtures)
- ✅ No hand-written booking payloads (should use aBooking())

Protected files touched (playwright.config.ts, src/support/):
✅ none
