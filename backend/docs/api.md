# AfyaMind API Documentation

**Base URL:** `https://api.afyamind.app/v1` (or `http://localhost:8080/v1`)
**Authentication:** HttpOnly Session Cookie (`access_token`) — No `Authorization` header required.
**Content-Type:** `application/json`

---

## Users API

### 1. Get Current User Profile

- **Endpoint:** `GET /users/me`
- **Access:** Authenticated (`access_token` cookie required)
- **Description:** Retrieves the current authenticated user's full profile, including disclaimer attestation status.

#### Request Headers & Cookies
```http
Cookie: access_token=<jwt_access_token>
```

#### Response (200 OK)
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "Jane Doe",
  "role": "PERSON",
  "status": "ACTIVE",
  "age_attested_18": true,
  "disclaimer_accepted_at": "2026-08-23T16:30:00Z",
  "created_at": "2026-08-23T10:00:00Z",
  "updated_at": "2026-08-23T16:30:00Z"
}
```

#### Errors
- `401 Unauthorized`:
```json
{
  "error": {
    "code": "unauthorized",
    "message": "Authentication required"
  }
}
```
- `404 Not Found`:
```json
{
  "error": {
    "code": "not_found",
    "message": "User not found"
  }
}
```

---

### 2. Update User Profile

- **Endpoint:** `PATCH /users/me`
- **Access:** Authenticated (`access_token` cookie required)
- **Description:** Updates the profile name of the authenticated user. Note: `role`, `email`, and `password_hash` are non-mutable.

#### Request Body
```json
{
  "name": "Jane Smith"
}
```

#### Response (200 OK)
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "Jane Smith",
  "role": "PERSON",
  "status": "ACTIVE",
  "age_attested_18": true,
  "disclaimer_accepted_at": "2026-08-23T16:30:00Z",
  "created_at": "2026-08-23T10:00:00Z",
  "updated_at": "2026-08-23T16:45:00Z"
}
```

#### Errors
- `400 Bad Request` (`validation_error`):
```json
{
  "error": {
    "code": "validation_error",
    "message": "Name field is required and cannot be empty"
  }
}
```
- `401 Unauthorized`:
```json
{
  "error": {
    "code": "unauthorized",
    "message": "Authentication required"
  }
}
```

---

### 3. Accept Disclaimer & Age Attestation

- **Endpoint:** `POST /users/me/disclaimer`
- **Access:** Authenticated (`access_token` cookie required)
- **Description:** Records the user's age attestation (18+) and disclaimer acceptance timestamp. Unlocks mood logging, exercises, and chat.

#### Request Body
```json
{
  "age_attested_18": true
}
```

#### Response (200 OK)
```json
{
  "id": 1,
  "email": "user@example.com",
  "name": "Jane Smith",
  "role": "PERSON",
  "status": "ACTIVE",
  "age_attested_18": true,
  "disclaimer_accepted_at": "2026-08-23T16:50:00Z",
  "created_at": "2026-08-23T10:00:00Z",
  "updated_at": "2026-08-23T16:50:00Z"
}
```

#### Errors
- `400 Bad Request` (`validation_error`):
```json
{
  "error": {
    "code": "validation_error",
    "message": "Age attestation (18+) is required to accept disclaimer"
  }
}
```
- `401 Unauthorized`:
```json
{
  "error": {
    "code": "unauthorized",
    "message": "Authentication required"
  }
}
```
