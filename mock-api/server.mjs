// Minimal in-memory mock of the Bookings service used by the experiment.
// Zero dependencies. Started automatically by Playwright (see playwright.config.ts).
//
// MOCK_BUG injects a deliberate defect so you can check whether generated tests catch it:
//   equal-dates   — checkOut equal to checkIn is accepted (should be rejected)
//   wrong-field   — date-order error is reported on "checkIn" instead of "checkOut"
//   guests-upper  — guests = 9 is accepted (limit should be 8)
import http from 'node:http';

const PORT = Number(process.env.MOCK_PORT ?? 4010);
const BUG = process.env.MOCK_BUG ?? '';
const KNOWN_BUGS = ['', 'equal-dates', 'wrong-field', 'guests-upper'];
if (!KNOWN_BUGS.includes(BUG)) {
  console.error(`Unknown MOCK_BUG "${BUG}". Use one of: ${KNOWN_BUGS.filter(Boolean).join(', ')}`);
  process.exit(1);
}

const bookings = new Map();
const users = new Map();
let seq = 1;

const ISO_DATE = /^\d{4}-\d{2}-\d{2}$/;
const isDate = (v) => typeof v === 'string' && ISO_DATE.test(v) && !Number.isNaN(Date.parse(v));
const EMAIL = /^[^@\s]+@[^@\s]+\.[^@\s]+$/;

function send(res, status, body) {
  res.writeHead(status, { 'content-type': 'application/json' });
  res.end(body === undefined ? '' : JSON.stringify(body));
}

function readJson(req) {
  return new Promise((resolve) => {
    let data = '';
    req.on('data', (chunk) => (data += chunk));
    req.on('end', () => {
      if (!data) return resolve({});
      try {
        resolve(JSON.parse(data));
      } catch {
        resolve(null);
      }
    });
  });
}

const validationError = (errors) => ({ code: 'VALIDATION_ERROR', errors });

function validateBooking(b) {
  const errors = [];
  for (const field of ['checkIn', 'checkOut']) {
    if (b[field] === undefined || b[field] === null) {
      errors.push({ field, message: `${field} is required` });
    } else if (!isDate(b[field])) {
      errors.push({ field, message: `${field} must be a date in YYYY-MM-DD format` });
    }
  }
  if (isDate(b.checkIn) && isDate(b.checkOut)) {
    const checkIn = Date.parse(b.checkIn);
    const checkOut = Date.parse(b.checkOut);
    const invalid = BUG === 'equal-dates' ? checkOut < checkIn : checkOut <= checkIn;
    if (invalid) {
      errors.push({
        field: BUG === 'wrong-field' ? 'checkIn' : 'checkOut',
        message: 'checkOut must be after checkIn',
      });
    }
  }
  const maxGuests = BUG === 'guests-upper' ? 9 : 8;
  if (b.guests === undefined || b.guests === null) {
    errors.push({ field: 'guests', message: 'guests is required' });
  } else if (!Number.isInteger(b.guests) || b.guests < 1 || b.guests > maxGuests) {
    errors.push({ field: 'guests', message: 'guests must be an integer between 1 and 8' });
  }
  return errors;
}

function validateUser(u) {
  const errors = [];
  if (u.email === undefined || u.email === null) {
    errors.push({ field: 'email', message: 'email is required' });
  } else if (typeof u.email !== 'string' || !EMAIL.test(u.email)) {
    errors.push({ field: 'email', message: 'email must be a valid email address' });
  }
  if (u.name === undefined || u.name === null || u.name === '') {
    errors.push({ field: 'name', message: 'name is required' });
  } else if (typeof u.name !== 'string' || u.name.length > 100) {
    errors.push({ field: 'name', message: 'name must be at most 100 characters' });
  }
  return errors;
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url ?? '/', `http://localhost:${PORT}`);
  const path = url.pathname;

  if (req.method === 'GET' && path === '/health') return send(res, 200, { status: 'ok', bug: BUG || null });

  // Bookings
  if (path === '/api/v2/bookings' && req.method === 'POST') {
    const body = await readJson(req);
    if (body === null) return send(res, 400, { code: 'INVALID_JSON', errors: [] });
    const errors = validateBooking(body);
    if (errors.length) return send(res, 400, validationError(errors));
    const booking = {
      id: `bk_${seq++}`,
      checkIn: body.checkIn,
      checkOut: body.checkOut,
      guests: body.guests,
      status: 'CONFIRMED',
    };
    bookings.set(booking.id, booking);
    return send(res, 201, booking);
  }
  const bookingMatch = path.match(/^\/api\/v2\/bookings\/([^/]+)$/);
  if (bookingMatch) {
    const booking = bookings.get(bookingMatch[1]);
    if (!booking) return send(res, 404, { code: 'NOT_FOUND', errors: [] });
    if (req.method === 'GET') return send(res, 200, booking);
    if (req.method === 'DELETE') {
      bookings.delete(booking.id);
      return send(res, 204);
    }
  }

  // Users
  if (path === '/api/v2/users' && req.method === 'POST') {
    const body = await readJson(req);
    if (body === null) return send(res, 400, { code: 'INVALID_JSON', errors: [] });
    const errors = validateUser(body);
    if (errors.length) return send(res, 400, validationError(errors));
    const user = { id: `us_${seq++}`, email: body.email, name: body.name };
    users.set(user.id, user);
    return send(res, 201, user);
  }
  const userMatch = path.match(/^\/api\/v2\/users\/([^/]+)$/);
  if (userMatch && req.method === 'DELETE') {
    if (!users.delete(userMatch[1])) return send(res, 404, { code: 'NOT_FOUND', errors: [] });
    return send(res, 204);
  }

  return send(res, 404, { code: 'NOT_FOUND', errors: [] });
});

server.listen(PORT, () => {
  console.log(`Mock Bookings API on http://localhost:${PORT}${BUG ? ` (MOCK_BUG=${BUG})` : ''}`);
});
