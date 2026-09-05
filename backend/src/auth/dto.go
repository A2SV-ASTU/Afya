package auth

// SignupRequest is the request body for POST /auth/register and POST /auth/signup.
type SignupRequest struct {
	// Patient's first name
	FirstName string `json:"first_name" binding:"required" example:"Jane"`
	// Patient's last name
	LastName string `json:"last_name" binding:"required" example:"Doe"`
	// Phone number in E.164 format
	Phone string `json:"phone" binding:"required" example:"+254712345678"`
	// Email address (used as login identifier)
	Email string `json:"email" binding:"required" example:"jane.doe@example.com"`
	// Account password (min 8 chars recommended)
	Password string `json:"password" binding:"required" example:"StrongPass123!"`
	// Date of birth in YYYY-MM-DD format (optional)
	DateOfBirth *string `json:"date_of_birth,omitempty" example:"1990-05-15"`
	// Biological sex: "male" or "female" (optional)
	Sex *string `json:"sex,omitempty" example:"female"`
}

// LoginRequest is the request body for POST /auth/login.
// Provide either email or phone together with password.
type LoginRequest struct {
	// Email address (use either email or phone)
	Email string `json:"email,omitempty" example:"jane.doe@example.com"`
	// Phone number (use either email or phone)
	Phone string `json:"phone,omitempty" example:"+254712345678"`
	// Account password
	Password string `json:"password" binding:"required" example:"StrongPass123!"`
}

// RefreshRequest is the optional JSON body for POST /auth/refresh.
// If omitted the server reads the refresh_token HttpOnly cookie.
type RefreshRequest struct {
	// Refresh token (optional — cookie is preferred)
	RefreshToken string `json:"refresh_token" example:"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."`
}

// ForgotPasswordRequest is the request body for POST /auth/forgot-password.
type ForgotPasswordRequest struct {
	// Email address of the account to reset password for
	Email string `json:"email" binding:"required,email" example:"jane.doe@example.com"`
}

// ResetPasswordRequest is the request body for POST /auth/reset-password.
type ResetPasswordRequest struct {
	// Password reset token received via email
	Token string `json:"token,omitempty" example:"abc123resettoken"`
	// The new password to set (minimum 8 characters)
	Password string `json:"password" binding:"required,min=8" example:"NewSecurePass123!"`
}

// VerifyEmailRequest is the request body for POST /auth/verify-email.
type VerifyEmailRequest struct {
	// Registered patient email address
	Email string `json:"email" binding:"required,email" example:"jane.doe@example.com"`
	// 6-digit verification code received via email
	OTP string `json:"otp" binding:"required,len=6" example:"123456"`
}

// ResendOTPRequest is the request body for POST /auth/resend-otp.
type ResendOTPRequest struct {
	// Registered patient email address
	Email string `json:"email" binding:"required,email" example:"jane.doe@example.com"`
}

// SignupResponse is returned upon successful patient registration.
type SignupResponse struct {
	Message string `json:"message" example:"Registration successful. Please verify your email with the 6-digit code sent to your inbox."`
	Email   string `json:"email" example:"jane.doe@example.com"`
}

