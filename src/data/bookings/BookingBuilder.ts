import type { CreateBookingRequest } from '../../models';
import { addDays, daysFromToday } from '../../utils/dates';

/**
 * Builds a valid booking request by default (check-in in 30 days, 3 nights, 2 guests).
 * Each `with*` / `without*` method changes exactly one thing.
 */
export class BookingBuilder {
  private checkIn: string | undefined = daysFromToday(30);
  private checkOut: string | undefined = addDays(daysFromToday(30), 3);
  private guests: number | undefined = 2;

  withCheckIn(date: string): this {
    this.checkIn = date;
    return this;
  }

  withCheckOut(date: string): this {
    this.checkOut = date;
    return this;
  }

  /** Sets checkOut relative to the current checkIn (0 = same day, -1 = the day before). */
  checkOutDaysAfterCheckIn(days: number): this {
    if (!this.checkIn) throw new Error('checkIn must be set before checkOutDaysAfterCheckIn()');
    this.checkOut = addDays(this.checkIn, days);
    return this;
  }

  withGuests(guests: number): this {
    this.guests = guests;
    return this;
  }

  withoutCheckIn(): this {
    this.checkIn = undefined;
    return this;
  }

  withoutCheckOut(): this {
    this.checkOut = undefined;
    return this;
  }

  withoutGuests(): this {
    this.guests = undefined;
    return this;
  }

  build(): CreateBookingRequest {
    const request: CreateBookingRequest = {};
    if (this.checkIn !== undefined) request.checkIn = this.checkIn;
    if (this.checkOut !== undefined) request.checkOut = this.checkOut;
    if (this.guests !== undefined) request.guests = this.guests;
    return request;
  }
}

export const aBooking = (): BookingBuilder => new BookingBuilder();
