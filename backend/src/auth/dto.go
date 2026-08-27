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
	Login    string `json:"login"`
	Email    string `json:"email"`
	Phone    string `json:"phone"`
	Password string `json:"password" binding:"required"`
}

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}
