package bootstrap

import (
	"context"
	"database/sql"
	"fmt"
	"log"

	"golang.org/x/crypto/bcrypt"
)

const (
	defaultAdminEmail     = "admin@afyamind.org"
	defaultAdminPassword  = "password"
	defaultAdminFirstName = "Super"
	defaultAdminLastName  = "Admin"
	defaultAdminPhone     = "+251900000000"
	defaultAdminRole      = "super_admin"
)

// SeedSuperAdmin checks if the users table is empty. If it is, it creates
// a default super_admin account. If any user already exists, it skips.
// This should only be called once at application startup.
func SeedSuperAdmin(ctx context.Context, db *sql.DB) error {
	var count int
	err := db.QueryRowContext(ctx, "SELECT COUNT(*) FROM users").Scan(&count)
	if err != nil {
		return fmt.Errorf("failed to check users table: %w", err)
	}

	if count > 0 {
		log.Println("Super Admin bootstrap: skipped — users already exist in the database")
		return nil
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(defaultAdminPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash default admin password: %w", err)
	}

	query := `
		INSERT INTO users (first_name, last_name, email, phone, password_hash, role, created_at, updated_at)
		VALUES ($1, $2, $3, $4, $5, $6, NOW(), NOW())
	`
	_, err = db.ExecContext(ctx, query, defaultAdminFirstName, defaultAdminLastName, defaultAdminEmail, defaultAdminPhone, string(hashedPassword), defaultAdminRole)
	if err != nil {
		return fmt.Errorf("failed to create default super admin: %w", err)
	}

	log.Printf("Super Admin bootstrap: created default super_admin account (%s)", defaultAdminEmail)
	log.Println("⚠️  IMPORTANT: Change the default password immediately after first login!")
	return nil
}
