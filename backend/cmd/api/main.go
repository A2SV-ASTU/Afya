package main

import (
	"context"
	"log"

	"afyamind-backend/src/auth"
	"afyamind-backend/src/bootstrap"
	"afyamind-backend/src/config"
	"afyamind-backend/src/database"
	"afyamind-backend/src/invitations"
	"afyamind-backend/src/shared/email"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/users"

	"github.com/gin-gonic/gin"
)

func main() {
	// 1. Load configuration
	cfg, err := config.Load()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}
	if err := cfg.Validate(); err != nil {
		log.Fatalf("Configuration validation error: %v", err)
	}

	if cfg.Env == "production" {
		gin.SetMode(gin.ReleaseMode)
	}

	// 2. Connect to Database (Neon Postgres)
	db, err := database.NewPostgresPool(cfg.DBDSN)
	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}
	defer func() {
		if err := db.Close(); err != nil {
			log.Printf("WARNING: Failed to close database connection: %v", err)
		}
	}()

	log.Printf("Successfully connected to Postgres database")

	// 3. Bootstrap: Seed default Super Admin if DB is empty
	if err := bootstrap.SeedSuperAdmin(context.Background(), db); err != nil {
		log.Printf("WARNING: Super Admin bootstrap failed: %v", err)
	}

	// 4. Initialize Repositories
	userRepo := users.NewRepository(db)
	authRepo := auth.NewRepositoryWithUserRepo(userRepo)
	invRepo := invitations.NewRepository(db)

	// 4. Initialize Email Sender (optional — logs warning if SMTP not configured)
	var emailSender *email.Sender
	smtpCfg, smtpErr := email.LoadSMTPConfig()
	if smtpErr != nil {
		log.Printf("WARNING: SMTP not configured — invitation emails will not be sent: %v", smtpErr)
	} else {
		emailSender = email.NewSender(smtpCfg)
	}

	// 5. Initialize Services
	userService := users.NewService(userRepo)
	authService := auth.NewService(authRepo, cfg)
	invService := invitations.NewService(invRepo, emailSender)

	// 6. Initialize Handlers
	userHandler := users.NewHandler(userService)
	authHandler := auth.NewHandler(authService, cfg)
	invHandler := invitations.NewHandler(invService)

	// 7. Setup Gin Router & Middlewares
	router := gin.New()
	router.Use(middleware.Logging())
	router.Use(middleware.Recovery())
	router.Use(middleware.CORS(cfg.CookieDomain))

	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "env": cfg.Env})
	})

	// 8. Register API v1 Group
	v1 := router.Group("/v1")
	{
		auth.RegisterRoutes(v1, authHandler, cfg.JWTSecret)
		users.RegisterRoutes(v1, userHandler, cfg.JWTSecret)
		invitations.RegisterRoutes(v1, invHandler, cfg.JWTSecret)
	}

	// 8. Start HTTP Server
	serverAddr := ":" + cfg.Port
	log.Printf("AfyaMind API server running on %s (env: %s)", serverAddr, cfg.Env)
	if err := router.Run(serverAddr); err != nil {
		log.Fatalf("Server run error: %v", err)
	}
}
