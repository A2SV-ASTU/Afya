package bootstrap

import (
	"context"
	"database/sql"
	"fmt"
	"log"

	"golang.org/x/crypto/bcrypt"
)

const (
	defaultAdminEmail    = "admin@gmail.com"
	defaultAdminPassword = "password"
	defaultAdminName     = "Super Admin"
	defaultAdminRole     = "SUPER_ADMIN"
)

// SeedSuperAdmin checks if the users table is empty. If it is, it creates
// a default SUPER_ADMIN account. If any user already exists, it skips.
// This should only be called once at application startup.
func SeedSuperAdmin(ctx context.Context, db *sql.DB) error {
	// 1. Check if any user exists in the database
	var count int
	err := db.QueryRowContext(ctx, "SELECT COUNT(*) FROM users").Scan(&count)
	if err != nil {
		return fmt.Errorf("failed to check users table: %w", err)
	}

	if count > 0 {
		log.Println("Super Admin bootstrap: skipped — users already exist in the database")
		return nil
	}

	// 2. Hash the default password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(defaultAdminPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash default admin password: %w", err)
	}

	// 3. Insert the default SUPER_ADMIN
	query := `
		INSERT INTO users (email, name, password_hash, role, status, age_attested_18, created_at, updated_at)
		VALUES ($1, $2, $3, $4, 'ACTIVE', false, NOW(), NOW())
	`
	_, err = db.ExecContext(ctx, query, defaultAdminEmail, defaultAdminName, string(hashedPassword), defaultAdminRole)
	if err != nil {
		return fmt.Errorf("failed to create default super admin: %w", err)
	}

	log.Printf("Super Admin bootstrap: created default SUPER_ADMIN account (%s)", defaultAdminEmail)
	log.Println("⚠️  IMPORTANT: Change the default password immediately after first login!")
	return nil
}
