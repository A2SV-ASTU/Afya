package auth

type SignupRequest struct {
	FirstName   string  `json:"first_name" binding:"required"`
	LastName    string  `json:"last_name" binding:"required"`
	Phone       string  `json:"phone" binding:"required"`
	Email       string  `json:"email" binding:"required"`
	Password    string  `json:"password" binding:"required"`
	DateOfBirth *string `json:"date_of_birth,omitempty"`
	Sex         *string `json:"sex,omitempty"`
}

type LoginRequest struct {
	Email    string `json:"email,omitempty"`
	Phone    string `json:"phone,omitempty"`
	Password string `json:"password" binding:"required"`
}

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type ForgotPasswordRequest struct {
	Email string `json:"email" binding:"required,email"`
}

type ResetPasswordRequest struct {
	Token    string `json:"token,omitempty"`
	Password string `json:"password" binding:"required,min=8"`
}
