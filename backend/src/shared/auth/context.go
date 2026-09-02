package auth

import (
	"database/sql"

	"afyamind-backend/src/shared/errors"
	"afyamind-backend/src/shared/middleware"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

type UserContext struct {
	ID       uuid.UUID
	Role     string
	ClinicID *uuid.UUID
}

var DB *sql.DB

func GetUser(c *gin.Context) (*UserContext, error) {
	id, ok1 := middleware.GetUserID(c)
	role, ok2 := middleware.GetUserRole(c)
	if !ok1 || !ok2 {
		return nil, errors.ErrUnauthorized()
	}

	var clinicID sql.NullString
	if DB != nil {
		_ = DB.QueryRow("SELECT clinic_id FROM users WHERE id = $1", id).Scan(&clinicID)
	}

	var cid *uuid.UUID
	if clinicID.Valid && clinicID.String != "" {
		parsed, err := uuid.Parse(clinicID.String)
		if err == nil {
			cid = &parsed
		}
	}

	return &UserContext{
		ID:       id,
		Role:     role,
		ClinicID: cid,
	}, nil
}
