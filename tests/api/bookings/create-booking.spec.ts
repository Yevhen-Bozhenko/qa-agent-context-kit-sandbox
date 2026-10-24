import { test, expect } from '../../../src/fixtures';
import { aBooking } from '../../../src/data/bookings/BookingBuilder';
import type { Booking } from '../../../src/models';

test.describe('POST /bookings', { tag: ['@api', '@smoke'] }, () => {
  test('creates a booking with valid data', async ({ bookingsClient }) => {
    const request = aBooking().build();

    const response = await bookingsClient.create(request);

    expect(response.status()).toBe(201);
    const booking = (await response.json()) as Booking;
    try {
      expect(booking).toMatchObject({ ...request, status: 'CONFIRMED' });
      const stored = await bookingsClient.get(booking.id);
      expect(stored.status()).toBe(200);
    } finally {
      await bookingsClient.delete(booking.id);
    }
  });
});
