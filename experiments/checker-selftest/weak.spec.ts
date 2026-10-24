// SYNTHETIC FIXTURE for selftest-checker.sh — not agent output, never an experiment result.
// Deliberately weak: raw HTTP, hand-written payloads, a guessed guest limit, status-only asserts.
// Expected checker score: 0/3 bugs caught, static warnings present.
import { test, expect } from '@playwright/test';

test('rejects checkOut before checkIn', async ({ request }) => {
  const res = await request.post('/api/v2/bookings', {
    data: { checkIn: '2030-05-10', checkOut: '2030-05-09', guests: 2 },
  });
  expect(res.status()).toBe(400);
});

test('rejects too many guests', async ({ request }) => {
  const res = await request.post('/api/v2/bookings', {
    data: { checkIn: '2030-05-10', checkOut: '2030-05-12', guests: 20 },
  });
  expect(res.status()).toBe(400);
});

test('rejects missing guests', async ({ request }) => {
  const res = await request.post('/api/v2/bookings', {
    data: { checkIn: '2030-05-10', checkOut: '2030-05-12' },
  });
  expect(res.status()).toBe(400);
});
