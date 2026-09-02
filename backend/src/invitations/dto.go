package invitations

// CreateInvitationRequest is the request body for POST /clinics/:clinicId/invitations.
type CreateInvitationRequest struct {
	// Email address to invite as a doctor
	Email string `json:"email" binding:"required,email" example:"doctor@hospital.com"`
}

// AcceptInvitationRequest is the request body for POST /invitations/:token/accept.
type AcceptInvitationRequest struct {
	// Invited doctor's first name
	FirstName string `json:"first_name" binding:"required" example:"Jane"`
	// Invited doctor's last name
	LastName string `json:"last_name" binding:"required" example:"Doe"`
	// Invited doctor's phone number
	Phone string `json:"phone" binding:"required" example:"+254712345678"`
	// Desired account password (min 8 characters)
	Password string `json:"password" binding:"required,min=8" example:"SecurePass789!"`
	// Medical license number
	LicenseNumber string `json:"license_number" binding:"required" example:"LIC-12345"`
	// Specialization area (e.g. Pediatrics, Cardiology)
	Specialization string `json:"specialization" binding:"required" example:"Pediatrics"`
}
