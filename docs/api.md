# AfyaMind API Documentation

This document contains the detailed specification and documentation for the AfyaMind Backend API endpoints created/refactored in Round 1.

---

## Standard Response Format

### Success Response Envelope

All successful responses return a JSON object wrapping the payload in a `data` field:

```json
{
  "data": { ... }
}
```

### Error Response Envelope

All error responses return a standardized error contract:

```json
{
  "error": {
    "code": "error_code_string",
    "message": "Human-readable error explanation",
    "details": null
  }
}
```

#### Common Error Codes

- `validation_error` (HTTP 400): Invalid body payload or missing required fields.
- `unauthenticated` (HTTP 401): Missing, invalid, or expired JWT authentication cookie/token.
- `forbidden_role` (HTTP 403): User role lacks permission for the endpoint.
- `forbidden_grant` (HTTP 403): Operation prohibited by current system authorization policy.
- `not_found` (HTTP 404): The requested resource was not found.
- `conflict` (HTTP 409): Resource constraint violation (e.g. duplicate email or phone number).
- `expired` (HTTP 410): Token or resource has expired.
- `internal_error` (HTTP 500): Server error occurred.

---

## Authentication Endpoints (`/api/v1/auth`)

### 1. Register Account

- **Endpoint**: `POST /api/v1/auth/register` (alias: `POST /api/v1/auth/signup`)
- **Auth Required**: No (Public)
- **Description**: Registers a new patient user account. Server explicitly forces `role = "patient"`.

#### Request Body

```json
{
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+251911223344",
  "email": "john.doe@example.com",
  "password": "Password123!",
  "date_of_birth": "1995-06-15",
  "sex": "male"
}
```

#### Responses

- **201 Created**: Returns user profile and sets HTTP-Only `access_token` and `refresh_token` cookies.

```json
{
  "data": {
    "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "first_name": "John",
    "last_name": "Doe",
    "role": "patient",
    "phone": "+251911223344",
    "email": "john.doe@example.com",
    "date_of_birth": "1995-06-15T00:00:00Z",
    "sex": "male",
    "blood_type": null,
    "emergency_contact_name": null,
    "emergency_contact_phone": null,
    "clinic_id": null,
    "specialization": null,
    "license_number": null,
    "doctor_status": null,
    "created_at": "2026-08-27T12:00:00Z",
    "updated_at": "2026-08-27T12:00:00Z"
  }
}
```

- **400 Bad Request** (`validation_error`): Invalid email, short password (<8 chars), or missing required fields.
- **409 Conflict** (`conflict`): Email or phone number is already registered.

---

### 2. User Login

- **Endpoint**: `POST /api/v1/auth/login`
- **Auth Required**: No (Public)
- **Description**: Authenticates any user (`patient`, `doctor`, `clinic_admin`, `super_admin`) via email or phone number.

#### Request Body (Email Login)

```json
{
  "email": "john.doe@example.com",
  "password": "Password123!"
}
```

#### Request Body (Phone Login)

```json
{
  "phone": "+251911223344",
  "password": "Password123!"
}
```

#### Responses

- **200 OK**: Sets HTTP-Only `access_token` and `refresh_token` cookies and returns user data.

```json
{
  "data": {
    "user": {
      "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
      "first_name": "John",
      "last_name": "Doe",
      "role": "patient",
      "phone": "+251911223344",
      "email": "john.doe@example.com",
      "date_of_birth": "1995-06-15T00:00:00Z",
      "sex": "male",
      "created_at": "2026-08-27T12:00:00Z",
      "updated_at": "2026-08-27T12:00:00Z"
    }
  }
}
```

- **401 Unauthorized** (`unauthenticated`): Invalid credentials or password mismatch.

---

### 3. Refresh Access Token

- **Endpoint**: `POST /api/v1/auth/refresh`
- **Auth Required**: No (Uses refresh token cookie or JSON payload)
- **Description**: Issues a new access token using a valid refresh token.

#### Request Body (Optional)

```json
{
  "refresh_token": "<refresh_jwt_token_string>"
}
```

_(If omitted, the server reads the `refresh_token` HTTP-Only cookie)._

#### Responses

- **200 OK**: Updates HTTP-Only `access_token` cookie.

```json
{
  "data": {
    "message": "Token refreshed successfully"
  }
}
```

- **401 Unauthorized** (`unauthenticated`): Invalid, missing, or expired refresh token.

---

### 4. Logout User

- **Endpoint**: `POST /api/v1/auth/logout`
- **Auth Required**: Yes (`access_token` cookie required)
- **Description**: Invalidates and clears `access_token` and `refresh_token` HTTP-Only session cookies.

#### Responses

- **200 OK**:

```json
{
  "data": {
    "message": "Logged out successfully"
  }
}
```

- **401 Unauthorized** (`unauthenticated`): Missing or invalid access token session.

---

## User Management Endpoints (`/api/v1/users`)

### 5. Get Current User Profile

- **Endpoint**: `GET /api/v1/users/me`
- **Auth Required**: Yes (`access_token` cookie required)
- **Description**: Fetches profile data of the authenticated user.

#### Responses

- **200 OK**:

```json
{
  "data": {
    "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "first_name": "John",
    "last_name": "Doe",
    "role": "patient",
    "phone": "+251911223344",
    "email": "john.doe@example.com",
    "date_of_birth": "1995-06-15T00:00:00Z",
    "sex": "male",
    "blood_type": "O+",
    "emergency_contact_name": "Jane Doe",
    "emergency_contact_phone": "+251911000000",
    "created_at": "2026-08-27T12:00:00Z",
    "updated_at": "2026-08-27T12:00:00Z"
  }
}
```

- **401 Unauthorized** (`unauthenticated`): Missing or invalid authentication token.
- **404 Not Found** (`not_found`): User record not found.

---

### 6. Update Current User Profile

- **Endpoint**: `PATCH /api/v1/users/me`
- **Auth Required**: Yes (`access_token` cookie required)
- **Description**: Updates profile attributes for the authenticated user (`first_name`, `last_name`, `email`, `phone`, `date_of_birth`, `sex`, `blood_type`, `emergency_contact_name`, `emergency_contact_phone`). Only `role` is immutable and cannot be changed via profile update.

#### Request Body

```json
{
  "first_name": "Johnny",
  "last_name": "Doe",
  "email": "johnny.doe@example.com",
  "phone": "+251911998877",
  "date_of_birth": "1995-06-15",
  "sex": "male",
  "blood_type": "O+",
  "emergency_contact_name": "Jane Doe",
  "emergency_contact_phone": "+251911000000"
}
```

#### Responses

- **200 OK**:

```json
{
  "data": {
    "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "first_name": "Johnny",
    "last_name": "Doe",
    "role": "patient",
    "phone": "+251911998877",
    "email": "johnny.doe@example.com",
    "date_of_birth": "1995-06-15T00:00:00Z",
    "sex": "male",
    "blood_type": "O+",
    "emergency_contact_name": "Jane Doe",
    "emergency_contact_phone": "+251911000000",
    "created_at": "2026-08-27T12:00:00Z",
    "updated_at": "2026-08-27T12:05:00Z"
  }
}
```

- **400 Bad Request** (`validation_error`): Invalid date/email format or request payload.
- **401 Unauthorized** (`unauthenticated`): Missing or invalid authentication token.
- **409 Conflict** (`conflict`): Updated email or phone number is already registered by another user account.

---

### 7. Change Password

- **Endpoint**: `PUT /api/v1/users/me/password` (alias: `PATCH /api/v1/users/me/password`)
- **Auth Required**: Yes (`access_token` cookie required)
- **Description**: Changes the password for the current authenticated user.

#### Request Body

```json
{
  "current_password": "OldPassword123!",
  "new_password": "NewSuperPassword456!"
}
```

#### Responses

- **200 OK**:

```json
{
  "data": {
    "message": "Password updated successfully"
  }
}
```

- **400 Bad Request** (`validation_error`): New password is less than 8 characters or missing required fields.
- **401 Unauthorized** (`unauthenticated`): Incorrect `current_password` or missing access token.

---

### 8. Delete Account

- **Endpoint**: `DELETE /api/v1/users/me`
- **Auth Required**: Yes (`access_token` cookie required)
- **Description**: Deletes the user account permanently.

#### Responses

- **200 OK**:

```json
{
  "data": {
    "message": "Account deleted successfully"
  }
}
```

- **401 Unauthorized** (`unauthenticated`): Missing or invalid authentication token.
