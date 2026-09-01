package prescriptions

import (
	"net/http"

	"afyamind-backend/src/shared/auth"
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/response"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type Handler struct{ svc Service }

func NewHandler(svc Service) *Handler { return &Handler{svc: svc} }

// CreatePrescription godoc
//
//	@Summary		Create a prescription for an encounter
//	@Description	Creates a new medical prescription with items during an encounter. Enforces doctor access.
//	@Tags			Prescriptions
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id		path		string										true	"Encounter ID"
//	@Param			body	body		prescriptions.CreatePrescriptionRequest		true	"Prescription creation payload"
//	@Success		201		{object}	prescriptions.PrescriptionResponse			"Prescription created successfully"
//	@Failure		400		{object}	response.ErrorEnvelope						"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope						"Not authenticated"
//	@Failure		403		{object}	response.ErrorEnvelope						"Forbidden role / Access denied"
//	@Router			/encounters/{id}/prescriptions [post]
func (h *Handler) CreatePrescription(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}
	encounterIDStr := c.Param("encounterId")
	if encounterIDStr == "" {
		encounterIDStr = c.Param("id")
	}
	encounterID, err := uuid.Parse(encounterIDStr)
	if err != nil {
		response.SendError(c, appErrors.ErrValidationError("invalid encounter id"))
		return
	}
	var req CreatePrescriptionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, appErrors.ErrValidationError(err.Error()))
		return
	}
	p, err := h.svc.CreatePrescription(c.Request.Context(), user, encounterID, req)
	if err != nil {
		response.SendError(c, err)
		return
	}
	response.JSON(c, http.StatusCreated, gin.H{"prescription": p})
}

// ListPrescriptions godoc
//
//	@Summary		List prescriptions for an encounter
//	@Description	Lists all prescriptions associated with a specific encounter. Patient or Doctor with active access grant only.
//	@Tags			Prescriptions
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id		path		string										true	"Encounter ID"
//	@Success		200		{array}		prescriptions.PrescriptionResponse			"List of prescriptions"
//	@Failure		400		{object}	response.ErrorEnvelope						"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope						"Not authenticated"
//	@Failure		403		{object}	response.ErrorEnvelope						"Forbidden / Access denied"
//	@Router			/encounters/{id}/prescriptions [get]
func (h *Handler) ListPrescriptions(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}
	encounterIDStr := c.Param("encounterId")
	if encounterIDStr == "" {
		encounterIDStr = c.Param("id")
	}
	encounterID, err := uuid.Parse(encounterIDStr)
	if err != nil {
		response.SendError(c, appErrors.ErrValidationError("invalid encounter id"))
		return
	}
	prescriptions, err := h.svc.ListPrescriptions(c.Request.Context(), user, encounterID)
	if err != nil {
		response.SendError(c, err)
		return
	}
	response.List(c, http.StatusOK, "prescriptions", prescriptions)
}

// UpdatePrescription godoc
//
//	@Summary		Update a prescription
//	@Description	Updates notes or items of an active prescription. Enforces doctor access.
//	@Tags			Prescriptions
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id		path		string										true	"Prescription ID"
//	@Param			body	body		prescriptions.UpdatePrescriptionRequest		true	"Prescription update payload"
//	@Success		200		{object}	prescriptions.PrescriptionResponse			"Prescription updated successfully"
//	@Failure		400		{object}	response.ErrorEnvelope						"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope						"Not authenticated"
//	@Failure		403		{object}	response.ErrorEnvelope						"Forbidden / Access denied"
//	@Router			/prescriptions/{id} [patch]
func (h *Handler) UpdatePrescription(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}
	prescriptionID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.SendError(c, appErrors.ErrValidationError("invalid prescription id"))
		return
	}
	var req UpdatePrescriptionRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		response.SendError(c, appErrors.ErrValidationError(err.Error()))
		return
	}
	p, err := h.svc.UpdatePrescription(c.Request.Context(), user, prescriptionID, req)
	if err != nil {
		response.SendError(c, err)
		return
	}
	response.JSON(c, http.StatusOK, gin.H{"prescription": p})
}

// CompletePrescription godoc
//
//	@Summary		Complete prescription items
//	@Description	Marks specific items in a prescription as completed. Enforces patient access.
//	@Tags			Prescriptions
//	@Accept			json
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id		path		string										true	"Prescription ID"
//	@Param			body	body		prescriptions.CompletePrescriptionRequest	false	"Optional list of item IDs to mark completed (if empty, marks all)"
//	@Success		200		{object}	map[string]string							"Returns status 'completed' on success"
//	@Failure		400		{object}	response.ErrorEnvelope						"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope						"Not authenticated"
//	@Failure		403		{object}	response.ErrorEnvelope						"Forbidden / Access denied"
//	@Router			/prescriptions/{id}/complete [patch]
func (h *Handler) CompletePrescription(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}
	prescriptionID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.SendError(c, appErrors.ErrValidationError("invalid prescription id"))
		return
	}
	var req CompletePrescriptionRequest
	_ = c.ShouldBindJSON(&req)
	if err := h.svc.CompletePrescription(c.Request.Context(), user, prescriptionID, req); err != nil {
		response.SendError(c, err)
		return
	}
	response.JSON(c, http.StatusOK, gin.H{"status": "completed"})
}

// DeactivatePrescription godoc
//
//	@Summary		Deactivate active prescription items
//	@Description	Deactivates all active items within a prescription. Enforces doctor access.
//	@Tags			Prescriptions
//	@Produce		json
//	@Security		BearerAuth
//	@Param			id		path		string								true	"Prescription ID"
//	@Success		200		{object}	map[string]string					"Returns status 'deactivated' on success"
//	@Failure		400		{object}	response.ErrorEnvelope				"Validation error"
//	@Failure		401		{object}	response.ErrorEnvelope				"Not authenticated"
//	@Failure		403		{object}	response.ErrorEnvelope				"Forbidden / Access denied"
//	@Router			/prescriptions/{id}/deactivate [patch]
func (h *Handler) DeactivatePrescription(c *gin.Context) {
	user, err := auth.GetUser(c)
	if err != nil {
		response.SendError(c, err)
		return
	}
	prescriptionID, err := uuid.Parse(c.Param("id"))
	if err != nil {
		response.SendError(c, appErrors.ErrValidationError("invalid prescription id"))
		return
	}
	if err := h.svc.DeactivatePrescription(c.Request.Context(), user, prescriptionID); err != nil {
		response.SendError(c, err)
		return
	}
	response.JSON(c, http.StatusOK, gin.H{"status": "deactivated"})
}
