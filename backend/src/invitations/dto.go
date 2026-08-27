package invitations

type CreateInvitationRequest struct {
	Email string `json:"email" binding:"required"`
}

type AcceptInvitationRequest struct {
	Token    string `json:"token" binding:"required"`
	Password string `json:"password" binding:"required"`
}
