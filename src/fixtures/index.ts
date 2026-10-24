import { test as base, expect } from '@playwright/test';
import { BookingsClient } from '../clients/BookingsClient';
import { UsersClient } from '../clients/UsersClient';

type ApiFixtures = {
  bookingsClient: BookingsClient;
  usersClient: UsersClient;
};

/** Import `test` and `expect` from here in every spec — not from '@playwright/test'. */
export const test = base.extend<ApiFixtures>({
  bookingsClient: async ({ request }, use) => {
    await use(new BookingsClient(request));
  },
  usersClient: async ({ request }, use) => {
    await use(new UsersClient(request));
  },
});

export { expect };
