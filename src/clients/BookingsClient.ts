import type { APIRequestContext, APIResponse } from '@playwright/test';
import type { CreateBookingRequest } from '../models';

/** API client for /api/v2/bookings. Returns raw responses; tests decide what to assert. */
export class BookingsClient {
  constructor(private readonly request: APIRequestContext) {}

  create(body: CreateBookingRequest): Promise<APIResponse> {
    return this.request.post('/api/v2/bookings', { data: body });
  }

  get(id: string): Promise<APIResponse> {
    return this.request.get(`/api/v2/bookings/${id}`);
  }

  delete(id: string): Promise<APIResponse> {
    return this.request.delete(`/api/v2/bookings/${id}`);
  }
}
