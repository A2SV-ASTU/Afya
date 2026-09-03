# AfyaMind API Documentation

This document contains the complete specification and reference for the AfyaMind REST API. It is aligned with the Swagger specification exposed at `/swagger/index.html`.

---

## Table of Contents

- [Standard Response Formats](#standard-response-formats)
- [Health Check](#health-check)
- [Authentication Endpoints (`/api/v1/auth`)](#authentication-endpoints-apiv1auth)
- [User Management Endpoints (`/api/v1/users`)](#user-management-endpoints-apiv1users)
- [Clinic Management Endpoints (`/api/v1/clinics`)](#clinic-management-endpoints-apiv1clinics)
- [Doctor Invitation Endpoints (`/api/v1/invitations`)](#doctor-invitation-endpoints-apiv1invitations)
- [Patient Lookup & Access Requests (`/api/v1/access-requests`)](#patient-lookup--access-requests-apiv1access-requests)
- [Appointments Endpoints (`/api/v1/appointments`)](#appointments-endpoints-apiv1appointments)
- [Clinical Encounters Endpoints (`/api/v1/encounters`)](#clinical-encounters-endpoints-apiv1encounters)
- [Clinical Evaluations Endpoints (`/api/v1/encounters/{id}/clinical-evaluation`)](#clinical-evaluations-endpoints-apiv1encountersidclinical-evaluation)
- [Labs Endpoints (`/api/v1/encounters/{encounterId}/labs`)](#labs-endpoints-apiv1encountersencounteridlabs)
- [Diagnoses Endpoints (`/api/v1/encounters/{encounterId}/diagnoses`)](#diagnoses-endpoints-apiv1encountersencounteriddiagnoses)
- [Magic Links Endpoints (`/api/v1/magic`)](#magic-links-endpoints-apiv1magic)

---

## Standard Response Formats

### 1. Success Response Envelope (Data)

Endpoints returning single or list data payloads typically wrap them inside a `data` field:

```json
{
  "data": { ... }
}
```

### 2. Success Message Envelope

Action endpoints (such as password changes, token refresh, logout) return a message envelope:

```json
{
  "data": {
    "message": "Operation completed successfully"
  }
}
```

### 3. Error Response Envelope

All error responses adhere to a consistent error schema:

```json
{
  "error": {
    "code": "error_code_string",
    "message": "Human-readable description of what went wrong"
  }
}
```

#### Standard Error Codes:
- `validation_error` (HTTP 400): Invalid request payload or missing required fields.
- `unauthenticated` (HTTP 401): Missing, invalid, or expired JWT credentials/cookies.
- `forbidden_role` (HTTP 403): User role lacks sufficient permissions.
- `forbidden_grant` (HTTP 403): Unauthorized due to missing or revoked patient access grant.
- `not_found` (HTTP 404): Resource could not be found.
- `conflict` (HTTP 409): Duplicate email/phone, or state conflict.
- `expired` (HTTP 410): Token or temporary resource has expired.
- `internal_error` (HTTP 500): Server error occurred.

---

## Health Check

### Health Check

- **Endpoint**: `GET /health`
- **Auth Required**: No (Public)
- **Description**: Returns service liveness and current environment.

#### Responses

- **200 OK**:
```json
{
  "env": "development",
  "status": "ok"
}
```

---

## Authentication Endpoints (`/api/v1/auth`)

### 1. Register Account
- **Endpoint**: `POST /api/v1/auth/register` (alias: `POST /api/v1/auth/signup`)
- **Auth Required**: No (Public)
- **Description**: Registers a new patient user account and sets HttpOnly JWT cookies (`access_token` and `refresh_token`).

#### Request Body
```json
{
  "first_name": "Jane",
  "last_name": "Doe",
  "phone": "+254712345678",
  "email": "jane.doe@example.com",
  "password": "StrongPass123!",
  "date_of_birth": "1995-06-15",
  "sex": "female"
}
```

#### Responses
- **201 Created**:
```json
{
  "data": {
    "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "first_name": "Jane",
    "last_name": "Doe",
    "role": "patient",
    "phone": "+254712345678",
    "email": "jane.doe@example.com",
    "date_of_birth": "1995-06-15T00:00:00Z",
    "sex": "female",
    "created_at": "2026-08-27T12:00:00Z",
    "updated_at": "2026-08-27T12:00:00Z"
  }
}
```
- **400 Bad Request** (`validation_error`): Invalid payload or password < 8 characters.
- **409 Conflict** (`conflict`): Email or phone number already in use.

---

### 2. User Login
- **Endpoint**: `POST /api/v1/auth/login`
- **Auth Required**: No (Public)
- **Description**: Authenticates user via email or phone + password. Sets HttpOnly JWT cookies (`access_token` and `refresh_token`).

#### Request Body
```json
{
  "email": "jane.doe@example.com",
  "password": "StrongPass123!"
}
```
*(Or use `"phone": "+254712345678"` instead of email).*

#### Responses
- **200 OK**:
```json
{
  "data": {
    "user": {
      "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
      "first_name": "Jane",
      "last_name": "Doe",
      "role": "patient",
      "phone": "+254712345678",
      "email": "jane.doe@example.com",
      "created_at": "2026-08-27T12:00:00Z",
      "updated_at": "2026-08-27T12:00:00Z"
    }
  }
}
```
- **401 Unauthorized** (`unauthenticated`): Invalid credentials.

---

### 3. Refresh Access Token
- **Endpoint**: `POST /api/v1/auth/refresh`
- **Auth Required**: No (Uses `refresh_token` cookie or JSON payload)
- **Description**: Issues a new `access_token` cookie.

#### Request Body (Optional for non-cookie clients)
```json
{
  "refresh_token": "<jwt_refresh_token>"
}
```

#### Responses
- **200 OK**:
```json
{
  "data": {
    "message": "Token refreshed successfully"
  }
}
```
- **401 Unauthorized** (`unauthenticated`): Missing or invalid refresh token.

---

### 4. Logout User
- **Endpoint**: `POST /api/v1/auth/logout`
- **Auth Required**: Yes (`BearerAuth` or session cookie)
- **Description**: Clears `access_token` and `refresh_token` HttpOnly cookies.

#### Responses
- **200 OK**:
```json
{
  "data": {
    "message": "Logged out successfully"
  }
}
```
- **401 Unauthorized** (`unauthenticated`): Not authenticated.

---

### 5. Forgot Password
- **Endpoint**: `POST /api/v1/auth/forgot-password`
- **Auth Required**: No (Public)
- **Description**: Sends a Magic Link password reset email. Always returns 200 to prevent account enumeration.

#### Request Body
```json
{
  "email": "jane.doe@example.com"
}
```

#### Responses
- **200 OK**:
```json
{
  "data": {
    "message": "If an account exists with that email, a password reset link has been sent."
  }
}
```
- **400 Bad Request** (`validation_error`): Invalid email format.

---

## User Management Endpoints (`/api/v1/users`)

### 6. Get Current User Profile
- **Endpoint**: `GET /api/v1/users/me`
- **Auth Required**: Yes (`BearerAuth`)
- **Description**: Returns profile details for the authenticated user.

#### Responses
- **200 OK**:
```json
{
  "data": {
    "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "first_name": "Jane",
    "last_name": "Doe",
    "role": "patient",
    "phone": "+254712345678",
    "email": "jane.doe@example.com",
    "date_of_birth": "1995-06-15T00:00:00Z",
    "sex": "female",
    "blood_type": "O+",
    "emergency_contact_name": "John Doe",
    "emergency_contact_phone": "+254711000000",
    "created_at": "2026-08-27T12:00:00Z",
    "updated_at": "2026-08-27T12:00:00Z"
  }
}
```

---

### 7. Update Current User Profile
- **Endpoint**: `PATCH /api/v1/users/me`
- **Auth Required**: Yes (`BearerAuth`)
- **Description**: Updates profile details for the authenticated user.

#### Request Body
```json
{
  "first_name": "Janet",
  "last_name": "Doe",
  "phone": "+254712345679",
  "email": "janet.doe@example.com",
  "date_of_birth": "1995-06-15",
  "sex": "female",
  "blood_type": "O+",
  "emergency_contact_name": "John Doe",
  "emergency_contact_phone": "+254711000000"
}
```

#### Responses
- **200 OK**: Returns updated user object.
- **400 Bad Request** (`validation_error`): Invalid payload.
- **409 Conflict** (`conflict`): Email or phone already registered by another account.

---

### 8. Change Password
- **Endpoint**: `PUT /api/v1/users/me/password` (alias: `PATCH /api/v1/users/me/password`)
- **Auth Required**: Yes (`BearerAuth`)
- **Description**: Updates password for the authenticated user.

#### Request Body
```json
{
  "current_password": "OldPassword123!",
  "new_password": "NewStrongPass456!"
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
- **400 Bad Request** (`validation_error`): Password < 8 characters.
- **401 Unauthorized** (`unauthenticated`): Incorrect current password.

---

### 9. Delete Account
- **Endpoint**: `DELETE /api/v1/users/me`
- **Auth Required**: Yes (`BearerAuth`)
- **Allowed Roles**: `patient`, `doctor`, `clinic_admin` (Prohibited for `super_admin`)
- **Description**: Permanently deletes the current user account. Not available for users with the `super_admin` role.

#### Responses
- **200 OK**:
```json
{
  "data": {
    "message": "Account deleted successfully"
  }
}
```
- **401 Unauthorized** (`unauthenticated`): Missing or invalid access token.
- **403 Forbidden** (`forbidden_role`): Super admin accounts cannot be deleted via this endpoint.

---

## Clinic Management Endpoints (`/api/v1/clinics`)

### 10. Create Clinic
- **Endpoint**: `POST /api/v1/clinics`
- **Auth Required**: Yes (`super_admin` role)
- **Description**: Registers a new clinic and creates its primary clinic administrator.

#### Request Body
```json
{
  "name": "Nairobi Central Clinic",
  "email": "admin@nairobiecentral.org",
  "phone": "+254700112233",
  "address": "123 Medical Ave, Nairobi",
  "admin_first_name": "Main",
  "admin_last_name": "Admin"
}
```

#### Responses
- **201 Created**:
```json
{
  "id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
  "name": "Nairobi Central Clinic",
  "email": "admin@nairobiecentral.org",
  "phone": "+254700112233",
  "address": "123 Medical Ave, Nairobi",
  "status": "active",
  "created_at": "2026-08-28T14:00:00Z",
  "updated_at": "2026-08-28T14:00:00Z"
}
```

---

### 11. List All Clinics
- **Endpoint**: `GET /api/v1/clinics`
- **Auth Required**: Yes (`super_admin` role)
- **Description**: Lists all registered clinics in the platform.

#### Responses
- **200 OK**:
```json
{
  "data": [
    {
      "id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
      "name": "Nairobi Central Clinic",
      "email": "admin@nairobiecentral.org",
      "phone": "+254700112233",
      "address": "123 Medical Ave, Nairobi",
      "status": "active",
      "created_at": "2026-08-28T14:00:00Z",
      "updated_at": "2026-08-28T14:00:00Z"
    }
  ]
}
```

---

### 12. Get Clinic Details
- **Endpoint**: `GET /api/v1/clinics/{clinicId}`
- **Auth Required**: Yes (`super_admin` or `clinic_admin`)
- **Description**: Retrieves details for a specific clinic.

#### Responses
- **200 OK**:
```json
{
  "data": {
    "id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
    "name": "Nairobi Central Clinic",
    "email": "admin@nairobiecentral.org",
    "phone": "+254700112233",
    "address": "123 Medical Ave, Nairobi",
    "status": "active",
    "created_at": "2026-08-28T14:00:00Z",
    "updated_at": "2026-08-28T14:00:00Z"
  }
}
```

---

### 13. Activate / Deactivate Clinic
- **Activate**: `PATCH /api/v1/clinics/{clinicId}/activate`
- **Deactivate**: `PATCH /api/v1/clinics/{clinicId}/deactivate`
- **Auth Required**: Yes (`super_admin` role)
- **Description**: Updates operational status of a clinic to `active` or `deactivated`.

#### Responses
- **200 OK**:
```json
{
  "status": "active"
}
```

---

### 14. List Doctors in Clinic
- **Endpoint**: `GET /api/v1/clinics/{clinicId}/doctors`
- **Auth Required**: Yes (`clinic_admin` role)
- **Description**: Returns all doctors registered under the specified clinic.

#### Responses
- **200 OK**:
```json
{
  "data": {
    "doctors": [
      {
        "id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22",
        "first_name": "Alex",
        "last_name": "Kariuki",
        "email": "alex.kariuki@clinic.com",
        "phone": "+254711223344",
        "specialization": "Cardiology",
        "license_number": "MED-12345",
        "doctor_status": "active",
        "created_at": "2026-08-28T14:00:00Z"
      }
    ]
  }
}
```

---

### 15. Activate / Deactivate Doctor
- **Activate**: `PATCH /api/v1/clinics/{clinicId}/doctors/{doctorId}/activate`
- **Deactivate**: `PATCH /api/v1/clinics/{clinicId}/doctors/{doctorId}/deactivate`
- **Auth Required**: Yes (`clinic_admin` role)
- **Description**: Toggles doctor status between `active` and `deactivated`.

#### Responses
- **200 OK**:
```json
{
  "status": "active"
}
```

---

## Doctor Invitation Endpoints (`/api/v1/invitations`)

### 16. Invite Doctor
- **Endpoint**: `POST /api/v1/clinics/{clinicId}/invitations`
- **Auth Required**: Yes (`clinic_admin` role)
- **Description**: Generates an invitation token valid for 24 hours and sends a Magic Link invitation email to the doctor.

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

---

### 17. Accept Doctor Invitation
- **Endpoint**: `POST /api/v1/invitations/{token}/accept`
- **Auth Required**: No (Public)
- **Description**: Consumes the invitation token and creates an active doctor user linked to the clinic.

#### Request Body
```json
{
  "first_name": "Alex",
  "last_name": "Kariuki",
  "phone": "+254711223344",
  "password": "DoctorStrongPassword123!",
  "license_number": "MED-12345",
  "specialization": "Cardiology"
}
```

#### Responses
- **201 Created**:
```json
{
  "id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22",
  "first_name": "Alex",
  "last_name": "Kariuki",
  "role": "doctor",
  "phone": "+254711223344",
  "email": "doctor@example.com",
  "clinic_id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
  "specialization": "Cardiology",
  "license_number": "MED-12345",
  "doctor_status": "active",
  "created_at": "2026-08-28T14:00:00Z",
  "updated_at": "2026-08-28T14:00:00Z"
}
```
- **409 Conflict** (`conflict`): Invitation already used or revoked.
- **410 Gone** (`expired`): Invitation token expired.

---

## Patient Lookup & Access Requests (`/api/v1/access-requests`)

### 18. Lookup Patient by Email
- **Endpoint**: `GET /api/v1/patients/lookup`
- **Auth Required**: Yes (`clinic_admin` or `doctor`)
- **Description**: Looks up a patient by their exact email address to retrieve their UUID before initiating an access request.

#### Query Parameters
- `email` (string, required): e.g. `jane.doe@example.com`

#### Responses
- **200 OK**:
```json
{
  "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
  "first_name": "Jane",
  "last_name": "Doe",
  "email": "jane.doe@example.com"
}
```
- **404 Not Found** (`not_found`): Patient not found.

---

### 19. Create Access Request
- **Endpoint**: `POST /api/v1/clinics/{clinicId}/access-requests`
- **Auth Required**: Yes (`clinic_admin` or `doctor`)
- **Description**: Creates a pending access request to a patient's medical records and sends an email to the patient containing Magic Links to Approve or Deny. (Expires in 15 minutes).

#### Request Body
```json
{
  "patient_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
  "reason": "Consultation for chronic hypertension management"
}
```

#### Responses
- **201 Created**:
```json
{
  "id": "f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a33",
  "patient_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
  "requesting_clinic_id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
  "reason": "Consultation for chronic hypertension management",
  "submitted_by_doctor_id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22",
  "status": "pending",
  "expires_at": "2026-08-28T14:15:00Z",
  "created_at": "2026-08-28T14:00:00Z",
  "updated_at": "2026-08-28T14:00:00Z"
}
```

---

### 20. List Access Requests for Clinic
- **Endpoint**: `GET /api/v1/clinics/{clinicId}/access-requests`
- **Auth Required**: Yes (`clinic_admin` or `doctor`)
- **Description**: Lists all access requests initiated by the clinic, filterable by `status`.

#### Query Parameters
- `status` (string, optional): `pending`, `approved`, `denied`, `expired`

#### Responses
- **200 OK**:
```json
{
  "data": [
    {
      "id": "f5eebc99-9c0b-4ef8-bb6d-6bb9bd380a33",
      "patient_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
      "requesting_clinic_id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
      "reason": "Consultation",
      "submitted_by_doctor_id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22",
      "status": "approved",
      "expires_at": "2026-08-28T14:15:00Z",
      "created_at": "2026-08-28T14:00:00Z",
      "updated_at": "2026-08-28T14:02:00Z"
    }
  ]
}
```

---

### 21. Revoke Access Request Grant
- **Endpoint**: `POST /api/v1/clinics/{clinicId}/access-requests/{id}/revoke`
- **Auth Required**: Yes (`clinic_admin` role)
- **Description**: Revokes an active approved access grant for the clinic.

#### Responses
- **200 OK**:
```json
{
  "status": "revoked_at set"
}
```

---

## Appointments Endpoints (`/api/v1/appointments`)

### 22. Create Appointment
- **Endpoint**: `POST /api/v1/appointments`
- **Auth Required**: Yes (`doctor` role)
- **Description**: Schedules a consultation between a patient and the doctor. Enforces active access guard grant.

#### Request Body
```json
{
  "patient_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
  "scheduled_at": "2026-09-15T10:00:00Z",
  "notes": "Annual cardiac checkup"
}
```

#### Responses
- **201 Created**:
```json
{
  "data": {
    "id": "e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a44",
    "doctor_id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22",
    "patient_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "scheduled_at": "2026-09-15T10:00:00Z",
    "status": "scheduled",
    "notes": "Annual cardiac checkup",
    "created_at": "2026-08-28T14:00:00Z",
    "updated_at": "2026-08-28T14:00:00Z"
  }
}
```

---

### 23. List Appointments for Patient
- **Endpoint**: `GET /api/v1/patients/{patientId}/appointments`
- **Auth Required**: Yes (`doctor` or `patient`)
- **Description**: Retrieves all scheduled and past appointments for a patient. Filterable by status.

#### Query Parameters
- `status` (string, optional): `scheduled`, `attended`, `cancelled`

#### Responses
- **200 OK**:
```json
{
  "data": [
    {
      "id": "e1eebc99-9c0b-4ef8-bb6d-6bb9bd380a44",
      "doctor_id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22",
      "patient_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
      "scheduled_at": "2026-09-15T10:00:00Z",
      "status": "scheduled",
      "notes": "Annual cardiac checkup",
      "created_at": "2026-08-28T14:00:00Z",
      "updated_at": "2026-08-28T14:00:00Z"
    }
  ]
}
```

---

## Clinical Encounters Endpoints (`/api/v1/encounters`)

### 24. Open New Clinical Encounter
- **Endpoint**: `POST /api/v1/patients/{patientId}/encounters`
- **Auth Required**: Yes (`doctor` role)
- **Description**: Opens a clinical encounter session for a patient. Enforces doctor access and active grant.

#### Responses
- **201 Created**:
```json
{
  "encounter": {
    "id": "d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55",
    "patient_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "doctor_id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22",
    "clinic_id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
    "status": "open",
    "started_at": "2026-08-28T14:00:00Z",
    "ended_at": null,
    "created_at": "2026-08-28T14:00:00Z",
    "updated_at": "2026-08-28T14:00:00Z"
  }
}
```

---

### 25. List Patient Encounters
- **Endpoint**: `GET /api/v1/patients/{patientId}/encounters`
- **Auth Required**: Yes (`doctor` or `patient`)
- **Description**: Lists paginated clinical encounters for a patient.

#### Query Parameters
- `page` (integer, optional, default: 1)
- `limit` (integer, optional, default: 20)

#### Responses
- **200 OK**:
```json
{
  "encounters": [
    {
      "id": "d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55",
      "patient_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
      "doctor_id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22",
      "clinic_id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
      "status": "open",
      "started_at": "2026-08-28T14:00:00Z",
      "ended_at": null,
      "created_at": "2026-08-28T14:00:00Z",
      "updated_at": "2026-08-28T14:00:00Z"
    }
  ],
  "page": 1,
  "limit": 20,
  "total": 1
}
```

---

### 26. Get Encounter Details
- **Endpoint**: `GET /api/v1/encounters/{id}`
- **Auth Required**: Yes (`doctor` or `patient`)
- **Description**: Returns full aggregated encounter data including vitals, lab results, diagnoses, and prescriptions.

#### Responses
- **200 OK**:
```json
{
  "encounter": {
    "id": "d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55",
    "patient_id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
    "doctor_id": "b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a22",
    "clinic_id": "c011e549-3e0f-4a2b-b876-ddc10cebc10f",
    "status": "open",
    "started_at": "2026-08-28T14:00:00Z",
    "ended_at": null
  },
  "patient_name": "Jane Doe",
  "doctor_name": "Dr. Alex Kariuki",
  "clinic_name": "Nairobi Central Clinic",
  "vitals": [],
  "labs": [],
  "diagnoses": [],
  "prescriptions": []
}
```

---

### 27. Close Clinical Encounter
- **Endpoint**: `PATCH /api/v1/encounters/{id}/close`
- **Auth Required**: Yes (`doctor` role)
- **Description**: Finalizes and closes an open encounter.

#### Responses
- **200 OK**:
```json
{
  "encounter": {
    "id": "d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55",
    "status": "closed",
    "ended_at": "2026-08-28T14:30:00Z"
  }
}
```

---

### 28. Get Patient Medical History for Encounter
- **Endpoint**: `GET /api/v1/encounters/{id}/medical-history`
- **Auth Required**: Yes (`doctor` or `patient`)
- **Description**: Retrieves a timeline summary of previous diagnoses, prescriptions, and vitals for this patient.

#### Responses
- **200 OK**:
```json
[
  {
    "encounter_id": "d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55",
    "encounter_date": "2026-08-28T14:00:00Z",
    "clinic_name": "Nairobi Central Clinic",
    "doctor_name": "Dr. Alex Kariuki",
    "diagnoses": ["Essential Hypertension"],
    "prescriptions": [
      {
        "medication_name": "Amlodipine",
        "dose": "5mg",
        "frequency": "OD",
        "duration": "30 days"
      }
    ],
    "vitals": {
      "systolic_bp": 130,
      "diastolic_bp": 85,
      "pulse": 72
    }
  }
]
```

---

## Clinical Evaluations Endpoints (`/api/v1/encounters/{id}/clinical-evaluation`)

### 29. Create Clinical Evaluation
- **Endpoint**: `POST /api/v1/encounters/{id}/clinical-evaluation`
- **Auth Required**: Yes (`doctor` role)
- **Description**: Records symptoms, history of present illness, allergies, and physical examination findings for an open encounter.

#### Request Body
```json
{
  "chief_complaint": "Mild chest pain and shortness of breath",
  "history_of_present_illness": "Patient reports intermittent chest tightness starting 3 days ago.",
  "past_admissions": "None",
  "family_history": "Father has history of coronary artery disease",
  "allergies_notes": "Allergic to penicillin",
  "general_appearance": "Alert, cooperative, in no acute distress",
  "system_examination": {
    "cardiovascular": "S1 S2 normal, no murmurs",
    "respiratory": "Clear bilateral breath sounds"
  }
}
```

#### Responses
- **201 Created**:
```json
{
  "clinical_evaluation": {
    "id": "e0eebc99-9c0b-4ef8-bb6d-6bb9bd380a66",
    "encounter_id": "d0eebc99-9c0b-4ef8-bb6d-6bb9bd380a55",
    "chief_complaint": "Mild chest pain and shortness of breath",
    "history_of_present_illness": "Patient reports intermittent chest tightness starting 3 days ago.",
    "allergies_notes": "Allergic to penicillin",
    "general_appearance": "Alert, cooperative, in no acute distress",
    "system_examination": {
      "cardiovascular": "S1 S2 normal, no murmurs",
      "respiratory": "Clear bilateral breath sounds"
    },
    "created_at": "2026-08-28T14:10:00Z"
  }
}
```

---

### 30. Get Clinical Evaluation
- **Endpoint**: `GET /api/v1/encounters/{id}/clinical-evaluation`
- **Auth Required**: Yes (`doctor` or `patient`)
- **Description**: Retrieves clinical evaluation details for an encounter.

#### Responses
- **200 OK**: Returns `clinical_evaluation` object.

---

## Magic Links Endpoints (`/api/v1/magic`)

Magic links are browser-rendered HTML pages used for email-driven workflows without requiring separate frontend or mobile view implementations.

### 31. View Access Request Page
- **Endpoint**: `GET /api/v1/magic/access-request`
- **Auth Required**: No (Public)
- **Description**: Serves the HTML confirmation page for a patient to approve or deny a records access request.

#### Query Parameters
- `token` (string, required): Secure token from the email link.
- `action` (string, required): `approve` or `deny`

#### Responses
- **200 OK**: Returns HTML approval/denial confirmation page.
- **400 Bad Request**: Invalid or missing parameters.

---

### 32. Confirm Access Request
- **Endpoint**: `POST /api/v1/magic/access-request`
- **Auth Required**: No (Public)
- **Description**: Processes the HTML form submission to approve or deny the access request.

#### Request Body (Form Data)
- `token` (string, required): Secure token.
- `action` (string, required): `approve` or `deny`

#### Responses
- **200 OK**: Returns HTML success or error page indicating the result.
- **400 Bad Request**: Missing form data.

---

### 33. View Password Reset Page
- **Endpoint**: `GET /api/v1/magic/reset-password`
- **Auth Required**: No (Public)
- **Description**: Serves the HTML form page for a user to enter their new password.

#### Query Parameters
- `token` (string, required): Secure token from the password reset email.

#### Responses
- **200 OK**: Returns HTML password reset form page.
- **400 Bad Request**: Invalid or missing token.

---

### 34. Confirm Password Reset
- **Endpoint**: `POST /api/v1/magic/reset-password`
- **Auth Required**: No (Public)
- **Description**: Processes the HTML password reset form submission and updates the user's password.

#### Request Body (Form Data)
- `token` (string, required): Secure token.
- `password` (string, required): New password (min 8 characters).
- `confirm_password` (string, required): Password confirmation.

#### Responses
- **200 OK**: Returns HTML success page on completion.
- **400 Bad Request**: Passwords do not match or token is missing.

---

### 35. View Accept Invitation Page
- **Endpoint**: `GET /api/v1/magic/accept-invitation`
- **Auth Required**: No (Public)
- **Description**: Serves the HTML registration form for an invited doctor.

#### Query Parameters
- `token` (string, required): Secure token from the invitation email.

#### Responses
- **200 OK**: Returns HTML doctor registration form.
- **400 Bad Request**: Invalid or missing token.

---

## Labs Endpoints (`/api/v1/encounters/{encounterId}/labs`)

### 36. Add a Lab Result
- **Endpoint**: `POST /api/v1/encounters/{encounterId}/labs`
- **Auth Required**: Yes (`doctor` role)
- **Description**: Adds a new lab result to a specific encounter.

#### Request Body
```json
{
  "test_name": "Complete Blood Count",
  "category": "laboratory",
  "summary_notes": "Normal ranges",
  "measurements": {
    "wbc": 5.5,
    "rbc": 4.2
  },
  "flag": "normal"
}
```

#### Responses
- **201 Created**: Returns the created lab result object.
- **400 Bad Request**: Validation error.
- **403 Forbidden**: Unauthorized role or missing access grant.
- **404 Not Found**: Encounter not found.
- **409 Conflict**: Encounter is closed.

---

### 37. Get Lab Results
- **Endpoint**: `GET /api/v1/encounters/{encounterId}/labs`
- **Auth Required**: Yes (`doctor` or `patient`)
- **Description**: Retrieves all lab results for a specific encounter.

#### Responses
- **200 OK**: Returns an array of lab results.
- **403 Forbidden**: Unauthorized role or missing access grant.
- **404 Not Found**: Encounter not found.

---

## Diagnoses Endpoints (`/api/v1/encounters/{encounterId}/diagnoses`)

### 38. Add a Diagnosis
- **Endpoint**: `POST /api/v1/encounters/{encounterId}/diagnoses`
- **Auth Required**: Yes (`doctor` role)
- **Description**: Adds a new diagnosis to a specific encounter.

#### Request Body
```json
{
  "diagnosis_text": "Acute Bronchitis",
  "diagnosis_type": "provisional",
  "icd_code": "J20.9",
  "notes": "Patient reports coughing."
}
```

#### Responses
- **201 Created**: Returns the created diagnosis object.
- **400 Bad Request**: Validation error.
- **403 Forbidden**: Unauthorized role or missing access grant.
- **404 Not Found**: Encounter not found.
- **409 Conflict**: Encounter is closed.

---

### 39. Get Diagnoses
- **Endpoint**: `GET /api/v1/encounters/{encounterId}/diagnoses`
- **Auth Required**: Yes (`doctor` or `patient`)
- **Description**: Retrieves all diagnoses for a specific encounter.

#### Responses
- **200 OK**: Returns an array of diagnoses.
- **403 Forbidden**: Unauthorized role or missing access grant.
- **404 Not Found**: Encounter not found.
