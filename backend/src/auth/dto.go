package auth

type SignupRequest struct {
	Email         string `json:"email" binding:"required"`
	Password      string `json:"password" binding:"required"`
	Name          string `json:"name" binding:"required"`
	AgeAttested18 bool   `json:"age_attested_18" binding:"required"`
}

type LoginRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}
