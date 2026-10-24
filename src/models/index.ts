export interface FieldError {
  field: string;
  message: string;
}

export interface ErrorResponse {
  code: string;
  errors: FieldError[];
}

export interface CreateBookingRequest {
  checkIn?: string;
  checkOut?: string;
  guests?: number;
}

export interface Booking {
  id: string;
  checkIn: string;
  checkOut: string;
  guests: number;
  status: 'CONFIRMED';
}

export interface CreateUserRequest {
  email?: string;
  name?: string;
}

export interface User {
  id: string;
  email: string;
  name: string;
}
