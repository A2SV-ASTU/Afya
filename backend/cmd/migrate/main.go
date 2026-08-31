package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load(".env", "backend/.env")
	dsn := os.Getenv("DB_DSN")
	if dsn == "" {
		log.Fatal("DB_DSN not set")
	}

	db, err := sql.Open("postgres", dsn)
	if err != nil {
		log.Fatalf("Failed to connect: %v", err)
	}
	defer db.Close()

	sqlBytes, err := os.ReadFile("migrations/000005_add_token_hash_to_access_requests.up.sql")
	if err != nil {
		log.Fatalf("Failed to read migration file: %v", err)
	}

	_, err = db.Exec(string(sqlBytes))
	if err != nil {
		log.Fatalf("Migration failed: %v", err)
	}

	fmt.Println("✅ Migration 000005 applied successfully — token_hash column added to access_requests")
}
