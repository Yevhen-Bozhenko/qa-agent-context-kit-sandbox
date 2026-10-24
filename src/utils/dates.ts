/** Date helpers. All dates are handled in UTC and formatted as YYYY-MM-DD. */

export function toIsoDate(date: Date): string {
  return date.toISOString().slice(0, 10);
}

export function addDays(isoDate: string, days: number): string {
  const date = new Date(`${isoDate}T00:00:00Z`);
  date.setUTCDate(date.getUTCDate() + days);
  return toIsoDate(date);
}

export function daysFromToday(days: number): string {
  return addDays(toIsoDate(new Date()), days);
}
