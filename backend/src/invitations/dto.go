package invitations

type CreateInvitationRequest struct {
	Email string `json:"email" binding:"required,email"`
}

type AcceptInvitationRequest struct {
	FirstName      string `json:"first_name" binding:"required"`
	LastName       string `json:"last_name" binding:"required"`
	Phone          string `json:"phone" binding:"required"`
	Password       string `json:"password" binding:"required,min=8"`
	LicenseNumber  string `json:"license_number" binding:"required"`
	Specialization string `json:"specialization" binding:"required"`
}
