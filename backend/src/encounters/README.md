# Encounters Domain Package (`src/encounters`)

This package manages patient encounter sessions, acting as the anchor record for clinical visits.

## Planned Components
- `encounter.go`: `Encounter` entity struct matching `encounters` database table.
- `handler.go`: HTTP handlers for creating, retrieving, and closing encounters.
- `service.go`: Business logic for managing encounter lifecycle and aggregating clinical evaluation, vitals, lab, diagnosis, and prescription details.
- `repository.go`: Database queries for encounter records.
- `routes.go`: Route registration wrapped with access request grant verification.
- `dto.go`: Request and response DTO definitions.
