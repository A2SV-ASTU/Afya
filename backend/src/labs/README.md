# Labs Domain Package (`src/labs`)

This package manages lab result records associated with clinical encounters.

## Planned Components
- `lab_result.go`: `LabResult` entity struct matching `lab_results` database table.
- `handler.go`: HTTP handlers for creating and listing lab results for an encounter.
- `service.go`: Business rules for lab result entries.
- `repository.go`: Database queries for lab results.
- `routes.go`: Route registration for lab result endpoints.
- `dto.go`: Request and response DTO definitions.
