package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"strings"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

const migrationsDir = "migrations"

type MigrationFile struct {
	Version  int64
	FullName string
	FileName string
}

func parseMigrationFile(filename string) (*MigrationFile, error) {
	if !strings.HasSuffix(filename, ".up.sql") {
		return nil, fmt.Errorf("not an up migration")
	}
	base := strings.TrimSuffix(filename, ".up.sql")
	parts := strings.Split(base, "_")
	if len(parts) == 0 {
		return nil, fmt.Errorf("invalid filename format: %s", filename)
	}
	v, err := strconv.ParseInt(parts[0], 10, 64)
	if err != nil {
		return nil, fmt.Errorf("could not parse version number from %s: %w", filename, err)
	}
	return &MigrationFile{
		Version:  v,
		FullName: base,
		FileName: filename,
	}, nil
}

func ensureMigrationsTable(ctx context.Context, db *sql.DB) error {
	query := `
		CREATE TABLE IF NOT EXISTS schema_migrations (
			version BIGINT PRIMARY KEY,
			dirty BOOLEAN NOT NULL DEFAULT false
		);
	`
	_, err := db.ExecContext(ctx, query)
	return err
}

func getAppliedVersions(ctx context.Context, db *sql.DB) (map[int64]bool, error) {
	rows, err := db.QueryContext(ctx, "SELECT version FROM schema_migrations WHERE dirty = false")
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	applied := make(map[int64]bool)
	for rows.Next() {
		var v int64
		if err := rows.Scan(&v); err != nil {
			return nil, err
		}
		applied[v] = true
	}
	return applied, rows.Err()
}

func loadMigrationFiles() ([]*MigrationFile, error) {
	entries, err := os.ReadDir(migrationsDir)
	if err != nil {
		return nil, err
	}

	var list []*MigrationFile
	for _, entry := range entries {
		if !entry.IsDir() && strings.HasSuffix(entry.Name(), ".up.sql") {
			mf, err := parseMigrationFile(entry.Name())
			if err == nil {
				list = append(list, mf)
			}
		}
	}

	sort.Slice(list, func(i, j int) bool {
		return list[i].Version < list[j].Version
	})

	return list, nil
}

func runAllUpMigrations(ctx context.Context, db *sql.DB) {
	applied, err := getAppliedVersions(ctx, db)
	if err != nil {
		log.Fatalf("Failed to fetch applied migrations: %v", err)
	}

	files, err := loadMigrationFiles()
	if err != nil {
		log.Fatalf("Failed to load migration files: %v", err)
	}

	appliedCount := 0
	for _, mf := range files {
		if applied[mf.Version] {
			fmt.Printf("⏭️  [SKIPPED] %s (already applied)\n", mf.FileName)
			continue
		}

		filePath := filepath.Join(migrationsDir, mf.FileName)
		sqlBytes, err := os.ReadFile(filePath)
		if err != nil {
			log.Fatalf("Failed to read %s: %v", filePath, err)
		}

		fmt.Printf("⏳ [APPLYING] %s...\n", mf.FileName)
		_, err = db.ExecContext(ctx, string(sqlBytes))
		if err != nil {
			log.Fatalf("❌ Migration failed on %s: %v", mf.FileName, err)
		}

		_, err = db.ExecContext(ctx, `
			INSERT INTO schema_migrations (version, dirty)
			VALUES ($1, false)
			ON CONFLICT (version) DO UPDATE SET dirty = false
		`, mf.Version)
		if err != nil {
			log.Fatalf("Failed to record migration version %d: %v", mf.Version, err)
		}

		fmt.Printf("✅ [APPLIED]  %s\n", mf.FileName)
		appliedCount++
	}

	if appliedCount == 0 {
		fmt.Println("✨ Database schema is already up to date (no pending migrations).")
	} else {
		fmt.Printf("🎉 Successfully applied %d migration(s).\n", appliedCount)
	}
}

func runDownMigrations(ctx context.Context, db *sql.DB, steps int) {
	rows, err := db.QueryContext(ctx, "SELECT version FROM schema_migrations ORDER BY version DESC")
	if err != nil {
		log.Fatalf("Failed to fetch applied migrations: %v", err)
	}
	defer rows.Close()

	var appliedVersions []int64
	for rows.Next() {
		var v int64
		if err := rows.Scan(&v); err != nil {
			log.Fatalf("Failed to scan version: %v", err)
		}
		appliedVersions = append(appliedVersions, v)
	}

	if len(appliedVersions) == 0 {
		fmt.Println("No applied migrations to roll back.")
		return
	}

	files, err := loadMigrationFiles()
	if err != nil {
		log.Fatalf("Failed to load migration files: %v", err)
	}
	versionToName := make(map[int64]string)
	for _, mf := range files {
		versionToName[mf.Version] = mf.FullName
	}

	rollbackCount := 0
	for i, v := range appliedVersions {
		if steps > 0 && i >= steps {
			break
		}

		name, ok := versionToName[v]
		if !ok {
			log.Fatalf("Could not find matching migration for version %d", v)
		}

		downFile := name + ".down.sql"
		filePath := filepath.Join(migrationsDir, downFile)
		sqlBytes, err := os.ReadFile(filePath)
		if err != nil {
			log.Fatalf("Failed to read rollback file %s: %v", filePath, err)
		}

		fmt.Printf("⏳ [ROLLING BACK] %s...\n", downFile)
		_, err = db.ExecContext(ctx, string(sqlBytes))
		if err != nil {
			log.Fatalf("❌ Rollback failed on %s: %v", downFile, err)
		}

		_, err = db.ExecContext(ctx, "DELETE FROM schema_migrations WHERE version = $1", v)
		if err != nil {
			log.Fatalf("Failed to remove migration version %d: %v", v, err)
		}

		fmt.Printf("✅ [ROLLED BACK]  %s\n", downFile)
		rollbackCount++
	}

	fmt.Printf("🎉 Successfully rolled back %d migration(s).\n", rollbackCount)
}

func printMigrationStatus(ctx context.Context, db *sql.DB) {
	applied, err := getAppliedVersions(ctx, db)
	if err != nil {
		log.Fatalf("Failed to fetch applied migrations: %v", err)
	}

	files, err := loadMigrationFiles()
	if err != nil {
		log.Fatalf("Failed to load migration files: %v", err)
	}

	fmt.Println("\n📋 Database Migration Status:")
	fmt.Println("==================================================")
	for _, mf := range files {
		if applied[mf.Version] {
			fmt.Printf("  [✔ APPLIED] %s (v%d)\n", mf.FileName, mf.Version)
		} else {
			fmt.Printf("  [  PENDING] %s (v%d)\n", mf.FileName, mf.Version)
		}
	}
	fmt.Println("==================================================")
}

func main() {
	_ = godotenv.Load(".env", "backend/.env")
	dsn := os.Getenv("DB_DSN")
	if dsn == "" {
		log.Fatal("DB_DSN environment variable is not set")
	}

	ctx := context.Background()
	db, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer db.Close()

	if err := db.PingContext(ctx); err != nil {
		log.Fatalf("Database ping error: %v", err)
	}

	if err := ensureMigrationsTable(ctx, db); err != nil {
		log.Fatalf("Failed to initialize schema_migrations table: %v", err)
	}

	if len(os.Args) > 1 {
		cmd := os.Args[1]
		switch cmd {
		case "status":
			printMigrationStatus(ctx, db)
			return
		case "down":
			steps := 1
			if len(os.Args) > 2 {
				parsed, err := strconv.Atoi(os.Args[2])
				if err == nil && parsed > 0 {
					steps = parsed
				}
			}
			runDownMigrations(ctx, db, steps)
			return
		case "up":
			runAllUpMigrations(ctx, db)
			return
		default:
			if strings.HasSuffix(cmd, ".sql") {
				sqlBytes, err := os.ReadFile(cmd)
				if err != nil {
					log.Fatalf("Failed to read file %s: %v", cmd, err)
				}
				_, err = db.ExecContext(ctx, string(sqlBytes))
				if err != nil {
					log.Fatalf("Migration failed on %s: %v", cmd, err)
				}
				fmt.Printf("✅ Executed %s successfully\n", cmd)
				return
			}
			fmt.Printf("Unknown command: %s. Usage: go run cmd/migrate/main.go [up | down <steps> | status | <path/to/file.sql>]\n", cmd)
			return
		}
	}

	// Default: run all up migrations
	runAllUpMigrations(ctx, db)
}
