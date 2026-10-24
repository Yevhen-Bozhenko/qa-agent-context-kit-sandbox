import type { CreateUserRequest } from '../../models';

let counter = 0;
const uniqueEmail = (): string => `user-${Date.now()}-${process.pid}-${counter++}@example.test`;

/**
 * Builds a valid user request by default (unique email, short name).
 * Each `with*` / `without*` method changes exactly one thing.
 */
export class UserBuilder {
  private email: string | undefined = uniqueEmail();
  private name: string | undefined = 'Test User';

  withEmail(email: string): this {
    this.email = email;
    return this;
  }

  withName(name: string): this {
    this.name = name;
    return this;
  }

  withoutEmail(): this {
    this.email = undefined;
    return this;
  }

  withoutName(): this {
    this.name = undefined;
    return this;
  }

  build(): CreateUserRequest {
    const request: CreateUserRequest = {};
    if (this.email !== undefined) request.email = this.email;
    if (this.name !== undefined) request.name = this.name;
    return request;
  }
}

export const aUser = (): UserBuilder => new UserBuilder();
