# AfyaMind API Documentation

**Base URL:** `https://api.afyamind.app/v1` (or `http://localhost:8080/v1`)
**Authentication:** HttpOnly Session Cookie (`access_token`, `refresh_token`) — No `Authorization` header required.
**Content-Type:** `application/json`

---

## Auth & Accounts API

### 1. User Signup

- **Endpoint:** `POST /auth/signup`
- **Access:** Public
- **Description:** Registers a new user account with role `PERSON`. Automatically sets HttpOnly `access_token` and `refresh_token` session cookies.

#### Request Body
```json
{
  "email": "jane@example.com",
  "password": "securePassword123",
  "name": "Jane Doe"
}
```

#### Response (201 Created)
- **Cookies Set:**
  - `access_token` (HttpOnly, Secure, SameSite=Strict, MaxAge=15m)
  - `refresh_token` (HttpOnly, Secure, SameSite=Strict, MaxAge=7d)
- **Body:**
```json
{
  "id": 1,
  "email": "jane@example.com",
  "name": "Jane Doe",
  "role": "PERSON",
  "age_attested_18": false,
  "disclaimer_accepted_at": null,
  "created_at": "2026-08-23T16:50:00Z",
  "updated_at": "2026-08-23T16:50:00Z"
}
```

#### Errors
- `400 Bad Request` (`invalid_email`):
```json
{
  "error": {
    "code": "invalid_email",
    "message": "Invalid email format"
  }
}
```
- `400 Bad Request` (`invalid_password`):
```json
{
  "error": {
    "code": "invalid_password",
    "message": "Password must be at least 8 characters long"
  }
}
```
- `400 Bad Request` (`validation_error`):
```json
{
  "error": {
    "code": "validation_error",
    "message": "Email is already registered"
  }
}
```

---

### 2. User Login

- **Endpoint:** `POST /auth/login`
- **Access:** Public
- **Description:** Authenticates existing user credentials. Sets HttpOnly `access_token` and `refresh_token` session cookies on success.

#### Request Body
```json
{
  "email": "jane@example.com",
  "password": "securePassword123"
}
```

#### Response (200 OK)
- **Cookies Set:**
  - `access_token` (HttpOnly, Secure, SameSite=Strict, MaxAge=15m)
  - `refresh_token` (HttpOnly, Secure, SameSite=Strict, MaxAge=7d)
- **Body:**
```json
{
  "id": 1,
  "email": "jane@example.com",
  "name": "Jane Doe",
  "role": "PERSON",
  "age_attested_18": false,
  "disclaimer_accepted_at": null,
  "created_at": "2026-08-23T16:50:00Z",
  "updated_at": "2026-08-23T16:50:00Z"
}
```

#### Errors
- `401 Unauthorized` (`invalid_credentials`):
```json
{
  "error": {
    "code": "invalid_credentials",
    "message": "Invalid email or password"
  }
}
```

---

### 3. Refresh Token

- **Endpoint:** `POST /auth/refresh`
- **Access:** Public (reads `refresh_token` cookie)
- **Description:** Uses existing `refresh_token` cookie to issue a fresh `access_token` cookie.

#### Request Headers & Cookies
```http
Cookie: refresh_token=<jwt_refresh_token>
```

#### Response (200 OK)
- **Cookies Set:**
  - `access_token` (HttpOnly, Secure, SameSite=Strict, MaxAge=15m)
- **Body:**
```json
{
  "id": 1,
  "email": "jane@example.com",
  "name": "Jane Doe",
  "role": "PERSON",
  "age_attested_18": false,
  "disclaimer_accepted_at": null,
  "created_at": "2026-08-23T16:50:00Z",
  "updated_at": "2026-08-23T16:50:00Z"
}
```

#### Errors
- `401 Unauthorized` (`unauthorized`):
```json
{
  "error": {
    "code": "unauthorized",
    "message": "Authentication required"
  }
}
```

---

### 4. User Logout

- **Endpoint:** `POST /auth/logout`
- **Access:** Authenticated (`access_token` cookie required)
- **Description:** Clears session cookies on the client browser.

#### Request Headers & Cookies
```http
Cookie: access_token=<jwt_access_token>
```

#### Response (204 No Content)
- **Cookies Cleared:**
  - `access_token` (MaxAge=-1)
  - `refresh_token` (MaxAge=-1)

---

## Users API

### 5. Get Current User Profile

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
  "age_attested_18": true,
  "disclaimer_accepted_at": "2026-08-23T16:30:00Z",
  "created_at": "2026-08-23T10:00:00Z",
  "updated_at": "2026-08-23T16:30:00Z"
}
```

---

### 6. Update User Profile

- **Endpoint:** `PATCH /users/me`
- **Access:** Authenticated (`access_token` cookie required)
- **Description:** Updates profile details (`name`, `email`, and/or `password`) of the authenticated user.

#### Request Body
```json
{
  "name": "Jane Smith",
  "email": "jane.smith@example.com",
  "password": "newSecurePassword123"
}
```
*(All fields are optional; at least one must be provided)*

#### Response (200 OK)
```json
{
  "id": 1,
  "email": "jane.smith@example.com",
  "name": "Jane Smith",
  "role": "PERSON",
  "age_attested_18": true,
  "disclaimer_accepted_at": "2026-08-23T16:30:00Z",
  "created_at": "2026-08-23T10:00:00Z",
  "updated_at": "2026-08-23T16:45:00Z"
}
```

#### Errors
- `400 Bad Request` (`invalid_email`):
```json
{
  "error": {
    "code": "invalid_email",
    "message": "Invalid email format"
  }
}
```
- `400 Bad Request` (`invalid_password`):
```json
{
  "error": {
    "code": "invalid_password",
    "message": "Password must be at least 8 characters long"
  }
}
```
- `400 Bad Request` (`validation_error`):
```json
{
  "error": {
    "code": "validation_error",
    "message": "Email is already registered by another account"
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

### 7. Accept Disclaimer & Age Attestation

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
  "email": "jane.smith@example.com",
  "name": "Jane Smith",
  "role": "PERSON",
  "age_attested_18": true,
  "disclaimer_accepted_at": "2026-08-23T16:50:00Z",
  "created_at": "2026-08-23T10:00:00Z",
  "updated_at": "2026-08-23T16:50:00Z"
}
```
