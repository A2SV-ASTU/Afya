package accessrequests

import (
	"database/sql"

	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/shared/response"
	"afyamind-backend/src/users"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// AccessGuard is a Gin middleware that other packages (encounters, vitals, labs,
// diagnoses, prescriptions, appointments) import directly.
// It checks whether the calling doctor's clinic has an active access grant
// for the target patient. The grant is keyed on clinic_id, not doctor_id.
func AccessGuard(db *sql.DB) gin.HandlerFunc {
	return func(c *gin.Context) {
		patientIDStr := c.Param("patientId")
		patientID, err := uuid.Parse(patientIDStr)
		if err != nil {
			response.RespondAppError(c, appErrors.ErrValidationError("Invalid patient ID"))
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

		// If the caller is a patient, they can only access their own data
		if role == string(users.RolePatient) {
			if callerID != patientID {
				response.RespondAppError(c, appErrors.ErrForbiddenRole())
				c.Abort()
			}
			return
		}

		// For doctor or clinic_admin: resolve clinic_id from the user row
		// (JWT claims only carry UserID and Role — no clinic_id).
		userRepo := users.NewRepository(db)
		callerUser, err := userRepo.FindByID(c.Request.Context(), callerID)
		if err != nil {
			response.RespondAppError(c, appErrors.ErrInternal("Failed to load user profile"))
			c.Abort()
			return
		}

		if callerUser.ClinicID == nil {
			response.RespondAppError(c, appErrors.ErrForbiddenGrant())
			c.Abort()
			return
		}

		// Check: does an access_requests row exist with
		//   requesting_clinic_id = caller's clinic
		//   patient_id = target patient
		//   status = 'approved'
		//   revoked_at IS NULL
		arRepo := NewRepository(db)
		_, err = arRepo.FindActiveGrant(c.Request.Context(), *callerUser.ClinicID, patientID)
		if err != nil {
			response.RespondAppError(c, appErrors.ErrForbiddenGrant())
			c.Abort()
			return
		}

		c.Next()
	}
}
