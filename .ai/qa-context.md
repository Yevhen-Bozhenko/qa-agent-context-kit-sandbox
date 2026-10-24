# QA project context

> Persistent context for AI coding agents. Loaded on every task.

## 1. Product and domain

- System under test: the Bookings service — a REST API for creating and managing hotel bookings,
  plus a small Users API.
- Main consumers: the booking web app and partner integrations (API only).
- Business rules come from tickets in `docs/tickets/<TICKET-ID>.md` and their acceptance criteria.
  `docs/openapi.yaml` describes request/response *shapes* only — it does not contain all business rules.
- If a task has no ticket (or the ticket doesn't cover a rule you'd need to assert), ask — don't infer
  rules from the spec's shapes, existing tests or the service's current responses.

## 2. Test stack

| Item | Value |
|---|---|
| Language / version | TypeScript 5.6 (strict) |
| Test runner | Playwright Test 1.48 (API testing via `request`) |
| UI driver | none (API-only project) |
| API client | Classes in `src/clients/` wrapping Playwright's `APIRequestContext` |
| Assertions | Playwright `expect` |
| Reporting | Playwright list + HTML reporter |
| Package manager | npm |
| System under test locally | Bookings service at `http://localhost:4010`, run separately (must be up before tests) |

Do not add new dependencies without asking.

## 3. Repository map

```
docs/openapi.yaml          # API shapes (not the full business rules)
docs/tickets/              # tickets with acceptance criteria — the source of expected behaviour
src/
  clients/                 # one API client per resource (BookingsClient, UsersClient)
  data/                    # test-data builders: aBooking(), aUser()
  fixtures/index.ts        # extended `test` with client fixtures — import test/expect from here
  models/index.ts          # request/response types, ErrorResponse
  utils/dates.ts           # date helpers (UTC, YYYY-MM-DD)
tests/
  api/<resource>/          # one folder per resource; one spec per endpoint + concern
```

## 4. How to run

| Purpose | Command |
|---|---|
| All tests | `npx playwright test` |
| One file | `npx playwright test tests/api/bookings/<file>.spec.ts` |
| One test by name | `npx playwright test -g "<test name>"` |
| By tag | `npx playwright test --grep @regression` |
| Type check (also our lint) | `npm run typecheck` |
| Open report | `npx playwright show-report` |

Agents: run the narrowest command that covers your change, then `npm run typecheck`.

## 5. Environments and configuration

- Local runs only, against the service on `http://localhost:4010` (override: `BOOKINGS_API_URL`).
- If the service isn't running, the run fails fast with a clear message — ask for it to be started;
  don't try to start or replace it yourself.
- Never point tests at any other host.
- The service's implementation is not a requirements source: its current behaviour may be wrong.
  Expected behaviour comes from tickets and their acceptance criteria.

## 6. Test data

- Build request bodies with `aBooking()` / `aUser()` — never hand-write payload objects in tests.
- The default builder output is always valid; change exactly one thing per negative case.
- Tests that create data delete it at the end (see `tests/api/bookings/create-booking.spec.ts`).
- Validation tests that expect `400` create nothing, so they need no cleanup.

## 7. Conventions

- File naming: `tests/api/<resource>/<endpoint-concern>.spec.ts`, e.g. `create-booking-validation.spec.ts`.
- Test naming: `rejects <resource> when <condition>` / `accepts <resource> when <condition>`.
- Tags: `@api` on every API test, plus `@smoke` (happy paths) or `@regression` (everything else).
- Ticket link: `annotation: { type: 'issue', description: '<TICKET-ID>' }` on the `describe`.
- Structure: arrange (builder) → act (client call) → assert; one behaviour per test.
- Parameterised cases: a typed `cases` array + `for … of` loop (see the users validation spec).
- Assertions on errors: status **and** `code` **and** the exact list of `errors[].field`.

## 8. Definition of done for a test

- [ ] It would fail if the behaviour it covers were broken (explain how, for negative tests).
- [ ] It passes locally 3 times in a row.
- [ ] It is independent and cleans up what it creates.
- [ ] It uses the existing clients, builders and fixtures.
- [ ] `npm run typecheck` passes.
- [ ] Tags and ticket annotation are present.

## 9. Never do

- Never weaken or delete assertions to make a test pass.
- Never adapt an expected value to the API's actual response without a requirement saying so —
  a mismatch is a possible bug: report it.
- Never add hard waits, retries or raised timeouts.
- Never modify `playwright.config.ts` or the global setup.
- Never call `request.post/get/…` directly in a spec — go through `src/clients/`.

## 10. Known pitfalls

- Dates are compared as calendar dates in UTC. Use `src/utils/dates.ts`, not `new Date()` arithmetic in tests.
- The builder's default check-in is 30 days from today — don't hardcode absolute dates.

## 11. Glossary

| Term | Meaning |
|---|---|
| Booking | A reservation: `checkIn`, `checkOut` (dates), `guests` |
| Validation error | `400` with `{ code: "VALIDATION_ERROR", errors: [{ field, message }] }` |
