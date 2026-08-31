package labs

import (
	"database/sql"

	ar "afyamind-backend/src/access-requests"
	appErrors "afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/shared/response"
	"afyamind-backend/src/users"
	"github.com/gin-gonic/gin"
)

// EncounterAccessGuard is a wrapper to use access-requests.AccessGuard which requires patientId in URL.
func EncounterAccessGuard(db *sql.DB) gin.HandlerFunc {
	arGuard := ar.AccessGuard(db)
	return func(c *gin.Context) {
		role, ok := middleware.GetUserRole(c)
		if !ok {
			response.RespondAppError(c, appErrors.ErrUnauthenticated())
			c.Abort()
			return
		}

		// If caller is patient, check if they are the encounter's patient
		if role == string(users.RolePatient) {
			encounterIDStr := c.Param("encounterId")
			var patientID string
			err := db.QueryRow("SELECT patient_id FROM encounters WHERE id = $1", encounterIDStr).Scan(&patientID)
			if err != nil {
				response.RespondAppError(c, appErrors.ErrNotFound("Encounter not found"))
				c.Abort()
				return
			}
			callerID, _ := middleware.GetUserID(c)
			if callerID.String() != patientID {
				response.RespondAppError(c, appErrors.ErrForbiddenRole())
				c.Abort()
				return
			}
			c.Next()
			return
		}

		// For doctors, we need to pass patientId to the AccessGuard
		encounterIDStr := c.Param("encounterId")
		var patientID string
		err := db.QueryRow("SELECT patient_id FROM encounters WHERE id = $1", encounterIDStr).Scan(&patientID)
		if err != nil {
			response.RespondAppError(c, appErrors.ErrNotFound("Encounter not found"))
			c.Abort()
			return
		}

		// Append patientId param to gin.Context so arGuard can pick it up
		c.Params = append(c.Params, gin.Param{Key: "patientId", Value: patientID})

		arGuard(c)
	}
}

func RegisterRoutes(router *gin.RouterGroup, handler *Handler, db *sql.DB, jwtSecret string) {
	group := router.Group("/encounters/:encounterId/labs")
	group.Use(middleware.RequireAuth(jwtSecret))
	group.Use(EncounterAccessGuard(db))
	{
		group.POST("", middleware.RequireRole(string(users.RoleDoctor)), handler.CreateLabResult)
		group.GET("", middleware.RequireRole(string(users.RoleDoctor), string(users.RolePatient)), handler.GetLabResults)
	}
}
