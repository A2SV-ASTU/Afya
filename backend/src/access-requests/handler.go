package accessrequests

import (
	"net/http"

	"afyamind-backend/src/config"
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/shared/response"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct {
	svc Service
	cfg *config.Config
}

func NewHandler(svc Service, cfg *config.Config) *Handler {
	return &Handler{svc: svc, cfg: cfg}
}

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

	ar, err := h.svc.CreateRequest(c.Request.Context(), clinicID, callerID, req, h.cfg.APIBaseURL)
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
