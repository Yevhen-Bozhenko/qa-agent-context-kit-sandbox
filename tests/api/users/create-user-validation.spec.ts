import { test, expect } from '../../../src/fixtures';
import { aUser, type UserBuilder } from '../../../src/data/users/UserBuilder';
import type { ErrorResponse, User } from '../../../src/models';

type InvalidCase = { name: string; patch: (b: UserBuilder) => UserBuilder; field: string };

// Rules: USR-101 — email required and valid; name required, at most 100 characters.
const invalidCases: InvalidCase[] = [
  { name: 'email is missing', patch: (b) => b.withoutEmail(), field: 'email' },
  { name: 'email has no @', patch: (b) => b.withEmail('not-an-email'), field: 'email' },
  { name: 'name is missing', patch: (b) => b.withoutName(), field: 'name' },
  { name: 'name is 101 characters', patch: (b) => b.withName('a'.repeat(101)), field: 'name' },
];

test.describe(
  'POST /users validation',
  { tag: ['@api', '@regression'], annotation: { type: 'issue', description: 'USR-101' } },
  () => {
    for (const c of invalidCases) {
      test(`rejects user when ${c.name}`, async ({ usersClient }) => {
        const response = await usersClient.create(c.patch(aUser()).build());

        expect(response.status()).toBe(400);
        const body = (await response.json()) as ErrorResponse;
        expect(body.code).toBe('VALIDATION_ERROR');
        expect(body.errors.map((e) => e.field)).toEqual([c.field]);
      });
    }

    test('accepts name of exactly 100 characters', async ({ usersClient }) => {
      const response = await usersClient.create(aUser().withName('a'.repeat(100)).build());

      expect(response.status()).toBe(201);
      const user = (await response.json()) as User;
      await usersClient.delete(user.id);
    });
  },
);
