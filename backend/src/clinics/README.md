# Clinics Domain Package (`src/clinics`)

This package manages clinic resources, clinic activation/deactivation, and clinic-doctor relationships.

## Planned Components
- `clinic.go`: `Clinic` entity struct matching `clinics` database table.
- `handler.go`: HTTP handlers for `POST /clinics`, `GET /clinics`, `GET /clinics/:id`, `PATCH /clinics/:id/deactivate`, `GET /clinics/:clinicId/doctors`, `GET /clinics/:clinicId/invitations`, and `PATCH /clinics/:clinicId/doctors/:doctorId/deactivate`.
- `service.go`: Business logic including atomic creation of Clinic + clinic_admin User row in a single transaction.
- `repository.go`: Database queries for clinic operations and doctor-scoped queries.
- `routes.go`: Route registration with super_admin and clinic_admin role guards.
- `dto.go`: Request and response DTO definitions.
