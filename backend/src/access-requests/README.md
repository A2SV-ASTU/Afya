# Access Requests Domain Package (`src/access-requests`)

This package manages the clinic-to-patient data access grant flow and exports the authorization guard used across clinical domain packages.

## Planned Components
- `access_request.go`: `AccessRequest` entity struct matching `access_requests` database table.
- `handler.go`: HTTP handlers for requesting, listing, approving, denying, and revoking access requests.
- `service.go`: Business rules including 5-minute expiration caps and request state transitions.
- `repository.go`: Queries for creating, updating, and looking up access requests.
- `routes.go`: Route definitions for patient and clinic endpoints.
- `dto.go`: Request and response DTO definitions.
- `access-requests.guard.go`: Exported middleware verifying active clinic access grants before granting access to clinical data.
- `access-requests.jobs.go`: Scheduled reconciliation job to transition stale pending requests to expired.
