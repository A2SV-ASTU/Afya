# Vitals Domain Package (`src/vitals`)

This package manages vital sign recordings from both clinic encounters and patient self-logging.

## Planned Components
- `vital_sign.go`: `VitalSign` entity struct matching `vital_signs` database table.
- `handler.go`: HTTP handlers for encounter vitals, patient self-logged vitals, and offline sync.
- `service.go`: Business rules including client_id deduplication for batch sync.
- `repository.go`: Database queries for vital sign recordings.
- `routes.go`: Route registration for vitals endpoints.
- `dto.go`: Request and response DTO definitions.
