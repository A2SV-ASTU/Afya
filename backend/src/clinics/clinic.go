package clinics

import (
	"time"

	"github.com/google/uuid"
)

const (
	StatusActive      = "active"
	StatusDeactivated = "deactivated"
)

type Clinic struct {
	ID        uuid.UUID `json:"id"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	Phone     string    `json:"phone,omitempty"`
	Address   string    `json:"address,omitempty"`
	Status    string    `json:"status"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}
