# Task: Add API tests for POST /bookings validation

## 1. Task

Add negative API tests for `POST /api/v2/bookings` covering the validation rules in BOOK-412,
plus the accepted boundary values.

## 2. Context

- Requirements: [`docs/tickets/BOOK-412.md`](../../docs/tickets/BOOK-412.md) — the acceptance criteria
  are the only source of expected behaviour. `docs/openapi.yaml` does not contain these rules.
- Happy-path test already exists: `tests/api/bookings/create-booking.spec.ts`.
- Client: `BookingsClient.create()` (fixture `bookingsClient`). Builder: `aBooking()`.

## 3. Constraints

- Only add or change files under `tests/api/bookings/` and, if needed, `src/data/bookings/`.
- Do not change client signatures or `playwright.config.ts`.
- No new dependencies.

## 4. Examples

- Model the spec on `tests/api/users/create-user-validation.spec.ts`.
- Cases to cover, at minimum:

| Case | Change from the valid default | Expected `errors[].field` |
|---|---|---|
| checkOut before checkIn | checkOut = checkIn − 1 day | `["checkOut"]` |
| checkOut equals checkIn | checkOut = checkIn | `["checkOut"]` |
| guests = 0 | guests: 0 | `["guests"]` |
| guests = 9 | guests: 9 | `["guests"]` |
| checkIn missing | no checkIn | `["checkIn"]` |

- Accepted boundaries (expect `201`, then delete the booking): `guests = 1`, `guests = 8`,
  checkOut = checkIn + 1 day.

## 5. Expected output

- New file `tests/api/bookings/create-booking-validation.spec.ts`.
- `describe` tagged `@api @regression` with annotation `{ type: 'issue', description: 'BOOK-412' }`.
- Negative tests assert status, `code` and the exact `errors[].field` list.

## 6. Validation

- Run `npx playwright test tests/api/bookings/create-booking-validation.spec.ts` three times — all pass.
- Run `npm run typecheck`.
- For each negative test, state in one line which defect would make it fail.
- If any response differs from BOOK-412, **do not adapt the test** — stop and report it as a
  possible bug, with the response body.
