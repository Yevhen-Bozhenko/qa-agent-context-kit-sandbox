# BOOK-412 — Validate booking dates and guest count

**Type:** Story · **Status:** Done (in production)

As a hotel, I want invalid bookings to be rejected by the API, so that no booking has
impossible dates or more guests than a room can hold.

## Acceptance criteria

1. `checkIn` and `checkOut` are required and must be dates in `YYYY-MM-DD` format.
2. `checkOut` must be **after** `checkIn`. A booking that checks out on the check-in day is invalid.
3. `guests` is required and must be an integer from **1 to 8** inclusive.
4. When a request violates any rule, the API responds `400` with:

   ```json
   { "code": "VALIDATION_ERROR", "errors": [{ "field": "<field name>", "message": "<text>" }] }
   ```

   `errors` lists exactly the fields that are invalid — one entry per invalid field.
   Messages are for humans and may change; `code` and `field` are the contract.
5. Valid requests are accepted with `201` as before.
