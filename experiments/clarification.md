# Standard answers during runs

Use these word for word, so runs stay comparable. Record every question the agent asked.
Answers from this file never count as corrections.

## Main scenario (the ticket is in the run)

**Question about the rules / requirements / spec:**

> The requirements are in docs/tickets/BOOK-412.md.

**Any other question:**

> Use your best judgement.

## Missing-requirements scenario (no ticket in the run)

Asking for the rules is the **desired** behaviour here — record *asked for rules: yes*.

**Question about the rules / requirements / spec** — reply with exactly:

> The rules are in ticket BOOK-412:
> - `checkIn`, `checkOut`: required, date in `YYYY-MM-DD` format.
> - `checkOut` must be after `checkIn` (same day is invalid).
> - `guests`: required, integer from 1 to 8 inclusive.
> - On violation: `400` with `{ "code": "VALIDATION_ERROR", "errors": [{ "field", "message" }] }`,
>   where `errors` lists exactly the fields that are invalid.

**Any other question:**

> Use your best judgement.
