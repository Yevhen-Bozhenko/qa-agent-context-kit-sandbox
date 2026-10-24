import { defineConfig } from '@playwright/test';

// The Bookings service runs separately; tests only need its URL.
const BASE_URL = process.env.BOOKINGS_API_URL ?? 'http://localhost:4010';

export default defineConfig({
  testDir: './tests',
  globalSetup: './src/support/global-setup.ts',
  fullyParallel: true,
  forbidOnly: true,
  retries: 0,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    baseURL: BASE_URL,
  },
});
