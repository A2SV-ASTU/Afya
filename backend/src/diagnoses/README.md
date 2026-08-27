# Diagnoses Domain Package (`src/diagnoses`)

This package manages medical diagnoses recorded during encounters.

## Planned Components
- `diagnosis.go`: `Diagnosis` entity struct matching `diagnoses` database table.
- `handler.go`: HTTP handlers for creating and listing diagnoses for an encounter.
- `service.go`: Business rules for diagnosis management.
- `repository.go`: Database queries for diagnosis records.
- `routes.go`: Route registration for diagnosis endpoints.
- `dto.go`: Request and response DTO definitions.
