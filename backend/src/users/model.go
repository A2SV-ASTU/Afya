package users

import (
	"time"
)

type Role string

const (
	RolePerson     Role = "PERSON"
	RoleAdmin      Role = "ADMIN"
	RoleSuperAdmin Role = "SUPER_ADMIN"
)

type Status string

const (
	StatusInvited Status = "INVITED"
	StatusActive  Status = "ACTIVE"
)

type User struct {
	ID                   int64      `json:"id"`
	Email                string     `json:"email"`
	Name                 string     `json:"name"`
	PasswordHash         string     `json:"-"`
	Role                 Role       `json:"role"`
	Status               Status     `json:"status"`
	AgeAttested18        bool       `json:"age_attested_18"`
	DisclaimerAcceptedAt *time.Time `json:"disclaimer_accepted_at"`
	CreatedAt            time.Time  `json:"created_at"`
	UpdatedAt            time.Time  `json:"updated_at"`
}
