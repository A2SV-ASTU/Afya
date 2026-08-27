# Appointments Domain Package (`src/appointments`)

This package manages standalone appointment records between patients and clinics/doctors.

## Planned Components
- `appointment.go`: `Appointment` entity struct matching `appointments` database table.
- `handler.go`: HTTP handlers for creating and listing appointments.
- `service.go`: Business rules for scheduling and retrieving appointments.
- `repository.go`: Database queries for appointment records.
- `routes.go`: Route registration for appointment endpoints.
- `dto.go`: Request and response DTO definitions.
