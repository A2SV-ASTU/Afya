# Prescriptions Domain Package (`src/prescriptions`)

This package manages prescription headers and item-level statuses (active, deactivated, completed).

## Planned Components
- `prescription.go`: `Prescription` header entity struct matching `prescriptions` table.
- `prescription_item.go`: `PrescriptionItem` entity struct matching `prescription_items` table.
- `handler.go`: HTTP handlers for creating prescriptions and updating item status (complete/deactivate).
- `service.go`: Business rules for prescription items lifecycle management.
- `repository.go`: Database queries for prescriptions and prescription items.
- `routes.go`: Route registration for prescription endpoints.
- `dto.go`: Request and response DTO definitions.
