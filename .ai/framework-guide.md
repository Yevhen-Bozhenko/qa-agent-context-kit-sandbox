# Working with the existing test framework

## 1. Reference tests (golden examples)

| Kind of test | Reference file | Why it is a good example |
|---|---|---|
| Validation (negative) API test | `tests/api/users/create-user-validation.spec.ts` | Typed case table, builder + one change per case, asserts status + code + field, ticket annotation, boundary acceptance test |
| Happy-path API test | `tests/api/bookings/create-booking.spec.ts` | Builder for input, client for the call, cleanup in `finally` |
| API client | `src/clients/BookingsClient.ts` | Thin wrapper, returns raw `APIResponse`, no assertions |
| Test-data builder | `src/data/bookings/BookingBuilder.ts` | Valid by default, one change per method |

## 2. Layers

```
tests/                 → describe behaviour; no raw HTTP, no hand-written payloads
  ↓ use
src/fixtures/          → `test` with client fixtures (bookingsClient, usersClient)
src/data/              → builders (aBooking, aUser)
src/clients/           → one client per resource; returns APIResponse; no assertions
src/models/            → types, including ErrorResponse
src/utils/             → helpers (dates)
```

A spec must import `test`/`expect` from `src/fixtures`, never from `@playwright/test`.

## 3. Reuse-first lookup order

1. `src/fixtures/index.ts` — is there a fixture for the client you need?
2. `src/clients/` — does the client already have the method?
3. `src/data/` — does the builder already have the `with*`/`without*` method?
4. `src/utils/` — is there a helper (e.g. date arithmetic)?

If something almost fits, extend it (e.g. add a builder method) rather than duplicating it,
and mention the extension in your report.

## 4. How to add…

**A builder method:** in the existing builder, change exactly one field, return `this`.

**A client method:** in the resource's client, one method per endpoint/verb, return `APIResponse`.

**A new resource:** new client in `src/clients/`, register a fixture in `src/fixtures/index.ts`,
builder in `src/data/<resource>/`, types in `src/models/index.ts`.

## 5. Synchronisation and waiting

API calls are awaited; nothing else needs waiting. No sleeps, polling or retries.

## 6. Assertions

- Negative tests: `status` = 400, `code` = `VALIDATION_ERROR`, `errors.map(e => e.field)` equals the
  exact expected list.
- Boundary tests: for every rejected limit, also test the accepted value next to it (e.g. 100 vs 101).
- Expected values come from the requirement, not from what the API currently returns.

## 7. Reporting

Tags and the ticket annotation are the reporting metadata; test names must read as the requirement.

## 8. When the framework is missing something

Add the smallest reusable piece in the right layer (usually a builder method) and call it out in your report.

## 9. Self-check before you report back

- [ ] Spec is in `tests/api/<resource>/` and named `<endpoint-concern>.spec.ts`.
- [ ] No raw HTTP calls or hand-written payloads in the spec.
- [ ] Reused: list. Created/extended: list (with reason).
- [ ] Error assertions check status + code + fields.
- [ ] Ran the spec 3 times and `npm run typecheck`. Results included.
