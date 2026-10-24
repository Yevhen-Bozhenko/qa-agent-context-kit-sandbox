import type { FullConfig } from '@playwright/test';

/** Fails fast with a clear message when the Bookings service isn't running. */
export default async function globalSetup(config: FullConfig): Promise<void> {
  const baseURL = config.projects[0]?.use.baseURL;
  try {
    const response = await fetch(`${baseURL}/health`);
    if (!response.ok) throw new Error(`health check returned ${response.status}`);
  } catch {
    throw new Error(
      `Bookings service is not reachable at ${baseURL}. It must be running before the tests start.`,
    );
  }
}
