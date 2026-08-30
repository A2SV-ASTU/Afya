package accessrequests

import (
	"net/http"

	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/shared/response"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct {
	svc Service
}

func NewHandler(svc Service) *Handler {
	return &Handler{svc: svc}
}

// LookupPatient godoc
//
//	@Summary		Lookup a patient by email
//	@Description	Looks up a patient by their exact email. Accessible by clinic admins.
//	@Tags			AccessRequests
//	@Produce		json
//	@Security		BearerAuth
//	@Param			email	query		string							true	"Patient Email Address"
//	@Success		200		{object}	accessrequests.PatientLookupResponse	"Patient found"
//	@Failure		400		{object}	response.ErrorEnvelope			"Missing email query parameter"
//	@Failure		401		{object}	response.ErrorEnvelope			"Not authenticated"
//	@Failure		404		{object}	response.ErrorEnvelope			"Patient not found"
//	@Router			/patients/lookup [get]
func (h *Handler) LookupPatient(c *gin.Context) {
	email := c.Query("email")
	if email == "" {
		response.RespondAppError(c, appErrors.ErrValidationError("Missing email query parameter"))
		return
	}

	patient, err := h.svc.LookupPatient(c.Request.Context(), email)
	if err != nil {
		if err.Error() == "patient_not_found" {
			response.RespondAppError(c, appErrors.ErrNotFound("patient"))
			return
		}
		response.RespondAppError(c, appErrors.ErrInternal(err.Error()))
		return
	}

	response.JSON(c, http.StatusOK, patient)
}

// CreateRequest godoc
//
//	@Summary		Create access request for a patient
//	@Description	Initiates a request for a clinic/doctor to view patient health records.
//	@Tags			AccessRequests
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			clinicId	path		string									true	"Clinic ID"
//	@Param			body		body		accessrequests.CreateAccessRequestRequest	true	"Request details"
//	@Success		201			{object}	accessrequests.AccessRequest			"Access request created"
//	@Failure		400			{object}	response.ErrorEnvelope					"Validation error"
//	@Failure		401			{object}	response.ErrorEnvelope					"Not authenticated"
//	@Failure		404			{object}	response.ErrorEnvelope					"Patient not found"
//	@Router			/clinics/{clinicId}/access-requests [post]
func (h *Handler) CreateRequest(c *gin.Context) {
	clinicIDStr := c.Param("clinicId")
	clinicID, err := uuid.Parse(clinicIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid clinic ID"))
		return
	}

	callerID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthenticated())
		return
	}

	var req CreateAccessRequestRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError(err.Error()))
		return
	}

	ar, err := h.svc.CreateRequest(c.Request.Context(), clinicID, callerID, req)
	if err != nil {
		if err.Error() == "patient_not_found" {
			response.RespondAppError(c, appErrors.ErrNotFound("patient"))
			return
		}
		response.RespondAppError(c, appErrors.ErrInternal(err.Error()))
		return
	}

	response.JSON(c, http.StatusCreated, ar)
}

// ApproveRequest godoc
//
//	@Summary		Approve access request
//	@Description	Patient approves a pending access request from a clinic.
//	@Tags			AccessRequests
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id	path		string								true	"Access Request ID"
//	@Success		200	{object}	response.MessageEnvelope			"Access request approved"
//	@Failure		400	{object}	response.ErrorEnvelope				"Validation/ID error"
//	@Failure		401	{object}	response.ErrorEnvelope				"Not authenticated"
//	@Failure		403	{object}	response.ErrorEnvelope				"Forbidden — not target patient"
//	@Failure		409	{object}	response.ErrorEnvelope				"Request not pending"
//	@Failure		410	{object}	response.ErrorEnvelope				"Request expired"
//	@Router			/access-requests/{id}/approve [post]
func (h *Handler) ApproveRequest(c *gin.Context) {
	requestIDStr := c.Param("id")
	requestID, err := uuid.Parse(requestIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid request ID"))
		return
	}

	callerID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthenticated())
		return
	}

	if err := h.svc.ApproveRequest(c.Request.Context(), callerID, requestID); err != nil {
		if err.Error() == "not_target_patient" {
			response.RespondAppError(c, appErrors.ErrForbiddenRole())
			return
		}
		if err.Error() == "request_not_pending" {
			response.RespondAppError(c, appErrors.ErrConflict(err.Error()))
			return
		}
		if err.Error() == "request_expired" {
			response.RespondAppError(c, appErrors.ErrExpired(err.Error()))
			return
		}
		response.RespondAppError(c, appErrors.ErrInternal(err.Error()))
		return
	}

	response.JSON(c, http.StatusOK, gin.H{"status": "approved"})
}

// DenyRequest godoc
//
//	@Summary		Deny access request
//	@Description	Patient denies a pending access request from a clinic.
//	@Tags			AccessRequests
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id	path		string								true	"Access Request ID"
//	@Success		200	{object}	response.MessageEnvelope			"Access request denied"
//	@Failure		400	{object}	response.ErrorEnvelope				"Validation/ID error"
//	@Failure		401	{object}	response.ErrorEnvelope				"Not authenticated"
//	@Failure		403	{object}	response.ErrorEnvelope				"Forbidden — not target patient"
//	@Failure		409	{object}	response.ErrorEnvelope				"Request not pending"
//	@Failure		410	{object}	response.ErrorEnvelope				"Request expired"
//	@Router			/access-requests/{id}/deny [post]
func (h *Handler) DenyRequest(c *gin.Context) {
	requestIDStr := c.Param("id")
	requestID, err := uuid.Parse(requestIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid request ID"))
		return
	}

	callerID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthenticated())
		return
	}

	if err := h.svc.DenyRequest(c.Request.Context(), callerID, requestID); err != nil {
		if err.Error() == "not_target_patient" {
			response.RespondAppError(c, appErrors.ErrForbiddenRole())
			return
		}
		if err.Error() == "request_not_pending" {
			response.RespondAppError(c, appErrors.ErrConflict(err.Error()))
			return
		}
		if err.Error() == "request_expired" {
			response.RespondAppError(c, appErrors.ErrExpired(err.Error()))
			return
		}
		response.RespondAppError(c, appErrors.ErrInternal(err.Error()))
		return
	}

	response.JSON(c, http.StatusOK, gin.H{"status": "denied"})
}

// RevokeRequest godoc
//
//	@Summary		Revoke approved access request
//	@Description	Clinic admin revokes a previously approved access request.
//	@Tags			AccessRequests
//	@Produce		json
//	@Security		BearerAuth
//	@Param			clinicId	path		string								true	"Clinic ID"
//	@Param			id			path		string								true	"Access Request ID"
//	@Success		200			{object}	response.MessageEnvelope			"Access request revoked"
//	@Failure		400			{object}	response.ErrorEnvelope				"Validation error"
//	@Failure		401			{object}	response.ErrorEnvelope				"Not authenticated"
//	@Failure		403			{object}	response.ErrorEnvelope				"Forbidden — unauthorized for clinic"
//	@Failure		409			{object}	response.ErrorEnvelope				"Request not currently active/approved"
//	@Router			/clinics/{clinicId}/access-requests/{id}/revoke [post]
func (h *Handler) RevokeRequest(c *gin.Context) {
	requestIDStr := c.Param("id")
	requestID, err := uuid.Parse(requestIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid request ID"))
		return
	}

	clinicIDStr := c.Param("clinicId")
	clinicID, err := uuid.Parse(clinicIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid clinic ID"))
		return
	}

	callerID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthenticated())
		return
	}

	if err := h.svc.RevokeRequest(c.Request.Context(), clinicID, requestID, callerID); err != nil {
		if err.Error() == "unauthorized_for_clinic" {
			response.RespondAppError(c, appErrors.ErrForbiddenRole())
			return
		}
		if err.Error() == "unauthorized_clinic" {
			response.RespondAppError(c, appErrors.ErrForbiddenRole())
			return
		}
		if err.Error() == "access_request_not_approved" {
			response.RespondAppError(c, appErrors.ErrConflict(err.Error()))
			return
		}
		response.RespondAppError(c, appErrors.ErrInternal(err.Error()))
		return
	}

	response.JSON(c, http.StatusOK, gin.H{"status": "revoked_at set"})
}

// ListRequests godoc
//
//	@Summary		List access requests for a clinic
//	@Description	Lists access requests. Filterable by status (pending, approved, denied, expired).
//	@Tags			AccessRequests
//	@Produce		json
//	@Security		BearerAuth
//	@Param			clinicId	path		string								true	"Clinic ID"
//	@Param			status		query		string								false	"Filter by status"
//	@Success		200			{object}	response.DataEnvelope{data=[]accessrequests.AccessRequest}	"List of requests"
//	@Failure		400			{object}	response.ErrorEnvelope				"Validation error"
//	@Failure		401			{object}	response.ErrorEnvelope				"Not authenticated"
//	@Failure		403			{object}	response.ErrorEnvelope				"Forbidden — unauthorized for clinic"
//	@Router			/clinics/{clinicId}/access-requests [get]
func (h *Handler) ListRequests(c *gin.Context) {
	clinicIDStr := c.Param("clinicId")
	clinicID, err := uuid.Parse(clinicIDStr)
	if err != nil {
		response.RespondAppError(c, appErrors.ErrValidationError("Invalid clinic ID"))
		return
	}

	callerID, ok := middleware.GetUserID(c)
	if !ok {
		response.RespondAppError(c, appErrors.ErrUnauthenticated())
		return
	}

	status := c.Query("status")

	reqs, err := h.svc.ListRequests(c.Request.Context(), clinicID, callerID, status)
	if err != nil {
		if err.Error() == "unauthorized_for_clinic" {
			response.RespondAppError(c, appErrors.ErrForbiddenRole())
			return
		}
		response.RespondAppError(c, appErrors.ErrInternal(err.Error()))
		return
	}

	response.List(c, http.StatusOK, "access_requests", reqs)
}
