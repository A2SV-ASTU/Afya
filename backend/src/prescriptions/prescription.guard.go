package prescriptions

import (
	"database/sql"

	accessrequests "afyamind-backend/src/access-requests"
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/shared/response"
	"afyamind-backend/src/users"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// PrescriptionAccessGuard verifies prescription ownership and active access grants
// by resolving prescription ID (":id") to its parent patient ID.
func PrescriptionAccessGuard(db *sql.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		prescriptionIDStr := c.Param("id")
		prescriptionID, err := uuid.Parse(prescriptionIDStr)
		if err != nil {
			response.RespondAppError(c, appErrors.ErrValidationError("invalid prescription id"))
			c.Abort()
			return
		}

		// Resolve encounter ID
		var encounterID uuid.UUID
		err = db.QueryRowContext(c.Request.Context(),
			`SELECT encounter_id FROM prescriptions WHERE id = $1`, prescriptionID,
		).Scan(&encounterID)
		if err != nil {
			if err == sql.ErrNoRows {
				response.RespondAppError(c, appErrors.ErrNotFound("prescription not found"))
			} else {
				response.RespondAppError(c, appErrors.ErrInternal("failed to lookup prescription"))
			}
			c.Abort()
			return
		}

		// Resolve patient ID
		var patientID uuid.UUID
		err = db.QueryRowContext(c.Request.Context(),
			`SELECT patient_id FROM encounters WHERE id = $1`, encounterID,
		).Scan(&patientID)
		if err != nil {
			if err == sql.ErrNoRows {
				response.RespondAppError(c, appErrors.ErrNotFound("encounter not found"))
			} else {
				response.RespondAppError(c, appErrors.ErrInternal("failed to lookup encounter"))
			}
			c.Abort()
			return
		}

		callerID, ok := middleware.GetUserID(c)
		if !ok {
			response.RespondAppError(c, appErrors.ErrUnauthenticated())
			c.Abort()
			return
		}
		role, _ := middleware.GetUserRole(c)

		// Patient checking ownership of their own records
		if role == string(users.RolePatient) {
			if callerID != patientID {
				response.RespondAppError(c, appErrors.ErrForbiddenRole())
				c.Abort()
				return
			}
			c.Next()
			return
		}

		// Doctor or clinic admin checking active grant
		userRepo := users.NewRepository(db)
		callerUser, err := userRepo.FindByID(c.Request.Context(), callerID)
		if err != nil {
			response.RespondAppError(c, appErrors.ErrInternal("failed to load user profile"))
			c.Abort()
			return
		}
		if callerUser.ClinicID == nil {
			response.RespondAppError(c, appErrors.ErrForbiddenGrant())
			c.Abort()
			return
		}

		arRepo := accessrequests.NewRepository(db)
		_, err = arRepo.FindActiveGrant(c.Request.Context(), *callerUser.ClinicID, patientID)
		if err != nil {
			response.RespondAppError(c, appErrors.ErrForbiddenGrant())
			c.Abort()
			return
		}

		c.Next()
	}
}
