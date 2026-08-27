# Clinical Evaluations Domain Package (`src/clinical-evaluations`)

This package manages doctor clinical evaluation write-ups attached to encounters.

## Planned Components
- `clinical_evaluation.go`: `ClinicalEvaluation` entity struct.
- `handler.go`: HTTP handlers for creating and retrieving clinical evaluations per encounter.
- `service.go`: Business rules for clinical evaluation recording.
- `repository.go`: Database queries for clinical evaluation records.
- `routes.go`: Route registration for clinical evaluation endpoints.
- `dto.go`: Request and response DTO definitions.
