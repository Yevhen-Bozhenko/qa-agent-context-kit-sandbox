import type { APIRequestContext, APIResponse } from '@playwright/test';
import type { CreateUserRequest } from '../models';

/** API client for /api/v2/users. Returns raw responses; tests decide what to assert. */
export class UsersClient {
  constructor(private readonly request: APIRequestContext) {}

  create(body: CreateUserRequest): Promise<APIResponse> {
    return this.request.post('/api/v2/users', { data: body });
  }

  delete(id: string): Promise<APIResponse> {
    return this.request.delete(`/api/v2/users/${id}`);
  }
}
