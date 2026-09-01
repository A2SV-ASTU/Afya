package invitations

import (
	"time"

	"github.com/google/uuid"
)

const (
	StatusPending  = "pending"
	StatusAccepted = "accepted"
	StatusExpired  = "expired"
	StatusRevoked  = "revoked"
)

type DoctorInvitation struct {
	ID         uuid.UUID  `json:"id"`
	ClinicID   uuid.UUID  `json:"clinic_id"`
	Email      string     `json:"email"`
	TokenHash  string     `json:"-"`
	Status     string     `json:"status"`
	ExpiresAt  time.Time  `json:"expires_at"`
	AcceptedAt *time.Time `json:"accepted_at,omitempty"`
	CreatedAt  time.Time  `json:"created_at"`
	InvitedBy  *uuid.UUID `json:"invited_by,omitempty"`
}
