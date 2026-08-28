# AfyaMind API Documentation

This document contains the detailed specification and documentation for the AfyaMind Backend API endpoints, including authentication, user profile management, super admin clinic management, doctor invitations, and patient data access requests.

---

## Standard Response Format

### Success Response Envelope

All successful responses return a JSON object wrapping the payload in a `data` field (or top-level entity fields for specific resource endpoints):

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
    "message": "Human-readable error explanation"
  }
}
```

#### Common Error Codes

- `validation_error` (HTTP 400): Invalid body payload or missing required fields.
- `unauthenticated` (HTTP 401): Missing, invalid, or expired JWT authentication cookie/token.
- `forbidden_role` (HTTP 403): User role lacks permission for the endpoint or clinic context.
- `forbidden_grant` (HTTP 403): Operation prohibited by current system authorization policy.
- `not_found` (HTTP 404): The requested resource was not found.
- `conflict` (HTTP 409): Resource constraint violation (e.g. duplicate email, phone number, or invalid status transition).
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

### 5. Forgot Password

- **Endpoint**: `POST /api/v1/auth/forgot-password`
- **Auth Required**: No (Public)
- **Description**: Generates a secure password reset token and sends a branded HTML password reset email to the user if their account exists.

#### Request Body

```json
{
  "email": "admin@afyamind.org"
}
```

#### Responses

- **200 OK**: Always returns success to prevent user enumeration.

```json
{
  "data": {
    "message": "If an account exists with that email, a password reset link has been sent."
  }
}
```

- **400 Bad Request** (`validation_error`): Invalid email format.

---

### 6. Reset Password

- **Endpoint**: `POST /api/v1/auth/reset-password`
- **Auth Required**: No (Public)
- **Description**: Verifies the reset token and updates the user's password securely using bcrypt.

#### Request Body

```json
{
  "token": "<RESET_TOKEN_FROM_EMAIL>",
  "password": "newSecurePassword123"
}
```

#### Responses

- **200 OK**:

```json
{
  "data": {
    "message": "Password has been successfully reset. You can now log in."
  }
}
```

- **400 Bad Request** (`validation_error`): Missing token or password shorter than 8 characters.
- **410 Gone** (`expired`): Token is invalid or expired.

---

## User Management Endpoints (`/api/v1/users`)

### 7. Get Current User Profile

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

### 8. Update Current User Profile

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

### 9. Change Password

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

### 10. Delete Account

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

---

## Clinic Management Endpoints (`/api/v1/clinics`)

### 11. Create Clinic

- **Endpoint**: `POST /api/v1/clinics`
- **Auth Required**: Yes (`super_admin` required)
- **Description**: Creates a new clinic, auto-generates a secure password for the new Clinic Admin, and emails them their welcome credentials.

#### Request Body

```json
{
  "name": "General Hospital",
  "email": "contact@generalhospital.com",
  "phone": "+1234567890",
  "address": "123 Main St",
  "admin_first_name": "Clinic",
  "admin_last_name": "Admin"
}
```

#### Responses

- **201 Created**:

```json
{
  "id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
  "name": "General Hospital",
  "email": "contact@generalhospital.com",
  "phone": "+1234567890",
  "address": "123 Main St",
  "status": "active",
  "created_at": "2026-08-28T14:00:00Z",
  "updated_at": "2026-08-28T14:00:00Z"
}
```

- **400 Bad Request** (`validation_error`): Missing required fields or invalid email.
- **401 Unauthorized** (`unauthenticated`): Missing or invalid authentication token.
- **403 Forbidden** (`forbidden_role`): Caller is not a `super_admin`.
- **409 Conflict** (`conflict`): Clinic or admin email already exists.

---

### 12. List Clinics

- **Endpoint**: `GET /api/v1/clinics`
- **Auth Required**: Yes (`super_admin` required)
- **Description**: Returns a list of all registered clinics in the system.

#### Responses

- **200 OK**:

```json
{
  "clinics": [
    {
      "id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
      "name": "General Hospital",
      "email": "contact@generalhospital.com",
      "phone": "+1234567890",
      "address": "123 Main St",
      "status": "active",
      "created_at": "2026-08-28T14:00:00Z",
      "updated_at": "2026-08-28T14:00:00Z"
    }
  ]
}
```

- **401 Unauthorized** (`unauthenticated`): Missing or invalid authentication token.
- **403 Forbidden** (`forbidden_role`): Caller is not a `super_admin`.

---

### 13. Deactivate Clinic

- **Endpoint**: `PATCH /api/v1/clinics/:clinicId/deactivate`
- **Auth Required**: Yes (`super_admin` required)
- **Description**: Changes a clinic's operational status to `deactivated`.

#### Responses

- **200 OK**:

```json
{
  "status": "deactivated"
}
```

- **401 Unauthorized** (`unauthenticated`): Missing or invalid token.
- **403 Forbidden** (`forbidden_role`): Caller is not a `super_admin`.
- **404 Not Found** (`not_found`): Clinic not found.

---

### 14. Activate Clinic

- **Endpoint**: `PATCH /api/v1/clinics/:clinicId/activate`
- **Auth Required**: Yes (`super_admin` required)
- **Description**: Restores a deactivated clinic back to `active` status.

#### Responses

- **200 OK**:

```json
{
  "status": "active"
}
```

- **401 Unauthorized** (`unauthenticated`): Missing or invalid token.
- **403 Forbidden** (`forbidden_role`): Caller is not a `super_admin`.
- **404 Not Found** (`not_found`): Clinic not found.

---

### 15. Deactivate Doctor

- **Endpoint**: `PATCH /api/v1/clinics/:clinicId/doctors/:doctorId/deactivate`
- **Auth Required**: Yes (`clinic_admin` required)
- **Description**: Deactivates a doctor tied to the specified clinic.

#### Responses

- **200 OK**:

```json
{
  "status": "deactivated"
}
```

- **401 Unauthorized** (`unauthenticated`): Missing or invalid token.
- **403 Forbidden** (`forbidden_role`): Caller is not a clinic admin for this clinic.
- **404 Not Found** (`not_found`): Doctor not found in this clinic.

---

### 16. Activate Doctor

- **Endpoint**: `PATCH /api/v1/clinics/:clinicId/doctors/:doctorId/activate`
- **Auth Required**: Yes (`clinic_admin` required)
- **Description**: Reactivates a deactivated doctor tied to the specified clinic.

#### Responses

- **200 OK**:

```json
{
  "status": "active"
}
```

- **401 Unauthorized** (`unauthenticated`): Missing or invalid token.
- **403 Forbidden** (`forbidden_role`): Caller is not a clinic admin for this clinic.
- **404 Not Found** (`not_found`): Doctor not found in this clinic.

---

## Doctor Invitation Endpoints (`/api/v1/invitations`)

### 17. Invite Doctor

- **Endpoint**: `POST /api/v1/clinics/:clinicId/invitations`
- **Auth Required**: Yes (`clinic_admin` required)
- **Description**: Generates a 24-hour invitation token and emails the doctor an invitation link.

#### Request Body

```json
{
  "email": "doctor@example.com"
}
```

#### Responses

- **201 Created**:

```json
{
  "message": "Invitation created successfully"
}
```

- **400 Bad Request** (`validation_error`): Invalid clinic ID or email format.
- **401 Unauthorized** (`unauthenticated`): Missing or invalid token.
- **403 Forbidden** (`forbidden_role`): Caller is not a clinic admin for this clinic.

---

### 18. Accept Doctor Invitation

- **Endpoint**: `POST /api/v1/invitations/:token/accept`
- **Auth Required**: No (Public)
- **Description**: Consumes the token and registers an active Doctor account tied to the clinic.

#### Request Body

```json
{
  "first_name": "John",
  "last_name": "Doe",
  "phone": "+1999888777",
  "password": "docpassword123",
  "license_number": "LIC-999-555",
  "specialization": "Cardiology"
}
```

#### Responses

- **200 OK**:

```json
{
  "id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22",
  "first_name": "John",
  "last_name": "Doe",
  "role": "doctor",
  "phone": "+1999888777",
  "email": "doctor@example.com",
  "clinic_id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
  "specialization": "Cardiology",
  "license_number": "LIC-999-555",
  "doctor_status": "active",
  "created_at": "2026-08-28T14:00:00Z",
  "updated_at": "2026-08-28T14:00:00Z"
}
```

- **400 Bad Request** (`validation_error`): Missing required fields or password < 8 characters.
- **409 Conflict** (`conflict`): Invitation already used or revoked.
- **410 Gone** (`expired`): Invitation token is invalid or expired.

---

## Patient Lookup & Access Requests (`/api/v1/access-requests` & `/api/v1/patients`)

### 19. Lookup Patient by Email

- **Endpoint**: `GET /api/v1/patients/lookup`
- **Auth Required**: Yes (`clinic_admin` required)
- **Description**: Looks up and returns a patient's ID by their exact email address.

#### Query Parameters

- `email` (string, required): e.g. `patient@example.com`

#### Responses

- **200 OK**:

```json
{
  "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
  "first_name": "Jane",
  "last_name": "Doe",
  "email": "patient@example.com"
}
```

- **400 Bad Request** (`validation_error`): Missing email query parameter.
- **401 Unauthorized** (`unauthenticated`): Missing or invalid authentication token.
- **404 Not Found** (`not_found`): No patient found with the provided email.

---

### 20. Request Access to Patient Data

- **Endpoint**: `POST /api/v1/clinics/:clinicId/access-requests`
- **Auth Required**: Yes (`clinic_admin` or `doctor` required)
- **Description**: Creates a pending access request to a patient's medical records and emails the patient. Auto-expires in 5 minutes via a background job.

#### Request Body

```json
{
  "patient_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
  "reason": "Initial consultation"
}
```

#### Responses

- **201 Created**:

```json
{
  "id": "f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a33",
  "patient_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
  "requesting_clinic_id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
  "reason": "Initial consultation",
  "submitted_by_doctor_id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22",
  "status": "pending",
  "expires_at": "2026-08-28T14:05:00Z",
  "created_at": "2026-08-28T14:00:00Z",
  "updated_at": "2026-08-28T14:00:00Z"
}
```

- **400 Bad Request** (`validation_error`): Invalid body or malformed UUID.
- **401 Unauthorized** (`unauthenticated`): Missing or invalid authentication token.
- **404 Not Found** (`not_found`): Patient record not found.

---

### 21. List Access Requests

- **Endpoint**: `GET /api/v1/clinics/:clinicId/access-requests`
- **Auth Required**: Yes (`clinic_admin` or `doctor` required)
- **Description**: Returns access requests for a clinic, filterable by `status`.

#### Query Parameters

- `status` (string, optional): Filter by request status (`pending`, `approved`, `denied`, `expired`).

#### Responses

- **200 OK**:

```json
{
  "access_requests": [
    {
      "id": "f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a33",
      "patient_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
      "requesting_clinic_id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
      "reason": "Initial consultation",
      "submitted_by_doctor_id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22",
      "status": "pending",
      "expires_at": "2026-08-28T14:05:00Z",
      "created_at": "2026-08-28T14:00:00Z",
      "updated_at": "2026-08-28T14:00:00Z"
    }
  ]
}
```

- **401 Unauthorized** (`unauthenticated`): Missing or invalid authentication token.
- **403 Forbidden** (`forbidden_role`): Caller is unauthorized for this clinic.

---

### 22. Approve Access Request

- **Endpoint**: `POST /api/v1/access-requests/:id/approve`
- **Auth Required**: Yes (`patient` required)
- **Description**: Allows a patient to approve a pending access request for their records.

#### Responses

- **200 OK**:

```json
{
  "status": "approved"
}
```

- **401 Unauthorized** (`unauthenticated`): Missing or invalid authentication token.
- **403 Forbidden** (`forbidden_role`): Authenticated user is not the target patient of this request.
- **409 Conflict** (`conflict`): Request is not in `pending` status.
- **410 Gone** (`expired`): Access request has expired.

---

### 23. Deny Access Request

- **Endpoint**: `POST /api/v1/access-requests/:id/deny`
- **Auth Required**: Yes (`patient` required)
- **Description**: Allows a patient to deny a pending access request for their records.

#### Responses

- **200 OK**:

```json
{
  "status": "denied"
}
```

- **401 Unauthorized** (`unauthenticated`): Missing or invalid authentication token.
- **403 Forbidden** (`forbidden_role`): Authenticated user is not the target patient of this request.
- **409 Conflict** (`conflict`): Request is not in `pending` status.
- **410 Gone** (`expired`): Access request has expired.

---

### 24. Revoke Approved Access Request

- **Endpoint**: `POST /api/v1/clinics/:clinicId/access-requests/:id/revoke`
- **Auth Required**: Yes (`clinic_admin` required)
- **Description**: Soft-revokes an approved access grant by setting a `revoked_at` timestamp, permanently cutting off data access while preserving audit trail logs.

#### Responses

- **200 OK**:

```json
{
  "status": "revoked_at set"
}
```

- **401 Unauthorized** (`unauthenticated`): Missing or invalid authentication token.
- **403 Forbidden** (`forbidden_role`): Caller is unauthorized for this clinic or not a clinic admin.
- **409 Conflict** (`conflict`): Access request is not currently in `approved` status.
