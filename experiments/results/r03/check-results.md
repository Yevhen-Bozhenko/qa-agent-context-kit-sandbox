# Automated checks — r03

Baseline: scenario `main` · condition `persistent` · commit `72bd854fd6f082c2ec0f2537d3b814122024628b`

## 1. Files changed by the agent (full diff: agent.diff)
```
 .../api/bookings/create-booking-validation.spec.ts | 81 ++++++++++++++++++++++
 1 file changed, 81 insertions(+)
```

## 2. Type check
PASS

## 3. Booking tests vs. correct service (expected: all pass)
PASS — 14 passed

## 4. Injected bugs (expected: every bug caught = at least one test fails)

| Bug | Caught? | Result | Likely cause if missed (verify in the diff) |
|---|---|---|---|
| `equal-dates` | ✅ caught | 1 failed,13 passed | — |
| `wrong-field` | ❌ missed | 14 passed | weak assertion: errors[].field not checked exactly |
| `guests-upper` | ✅ caught | 1 failed,13 passed | — |

**Bugs caught: 2 / 3**

## 5. Static checks on the agent's changes
- ✅ No hard waits / timeouts / retries / skips
- ✅ No raw HTTP calls (framework bypass)
- ✅ No imports from @playwright/test in specs (should use src/fixtures)
- ✅ No hand-written booking payloads (should use aBooking())

Protected files touched (playwright.config.ts, src/support/):
✅ none
