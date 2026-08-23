package users

import (
	"time"
)

type UserResponse struct {
	ID                   int64      `json:"id"`
	Email                string     `json:"email"`
	Name                 string     `json:"name"`
	Role                 Role       `json:"role"`
	AgeAttested18        bool       `json:"age_attested_18"`
	DisclaimerAcceptedAt *time.Time `json:"disclaimer_accepted_at"`
	CreatedAt            time.Time  `json:"created_at"`
	UpdatedAt            time.Time  `json:"updated_at"`
}

type UpdateProfileRequest struct {
	Name     *string `json:"name,omitempty"`
	Email    *string `json:"email,omitempty"`
	Password *string `json:"password,omitempty"`
}

type DisclaimerRequest struct {
	AgeAttested18 bool `json:"age_attested_18" binding:"required"`
}

func ToUserResponse(u *User) *UserResponse {
	if u == nil {
		return nil
	}
	return &UserResponse{
		ID:                   u.ID,
		Email:                u.Email,
		Name:                 u.Name,
		Role:                 u.Role,
		AgeAttested18:        u.AgeAttested18,
		DisclaimerAcceptedAt: u.DisclaimerAcceptedAt,
		CreatedAt:            u.CreatedAt,
		UpdatedAt:            u.UpdatedAt,
	}
}
