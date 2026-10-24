# Bookings API tests

API tests for the Bookings service, written with Playwright Test and TypeScript.

The tests run against the Bookings service at `http://localhost:4010`
(override with `BOOKINGS_API_URL`). The service must be running before you run the tests.

```bash
npm install
npx playwright test
npm run typecheck
```
