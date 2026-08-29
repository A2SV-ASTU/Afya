package main

import (
	"context"
	"log"
	"time"

	"afyamind-backend/src/access-requests"
	"afyamind-backend/src/auth"
	"afyamind-backend/src/bootstrap"
	"afyamind-backend/src/clinics"
	"afyamind-backend/src/config"
	"afyamind-backend/src/database"
	"afyamind-backend/src/invitations"
	"afyamind-backend/src/magiclink"
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
	authRepo := auth.NewRepository(db)
	invRepo := invitations.NewRepository(db)
	clinicRepo := clinics.NewRepository(db)
	arRepo := accessrequests.NewRepository(db)

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
	authService := auth.NewService(authRepo, cfg, emailSender)
	invService := invitations.NewService(db, invRepo, emailSender, cfg)
	clinicService := clinics.NewService(db, clinicRepo, emailSender)
	arService := accessrequests.NewService(db, arRepo, userRepo, emailSender)

	// 6. Initialize Handlers
	userHandler := users.NewHandler(userService)
	authHandler := auth.NewHandler(authService, cfg)
	invHandler := invitations.NewHandler(invService, cfg)
	clinicHandler := clinics.NewHandler(clinicService)
	arHandler := accessrequests.NewHandler(arService, cfg)
	magicHandler := magiclink.NewHandler(arService, authService, cfg)

	// 6b. Start background expiration jobs
	appCtx := context.Background()
	invitations.StartExpirationJob(appCtx, invService, 5*time.Minute)
	accessrequests.StartExpirationJob(appCtx, arRepo, 30*time.Second)

	// 7. Setup Gin Router & Middlewares
	router := gin.New()
	router.Use(middleware.Logging())
	router.Use(middleware.Recovery())
	router.Use(middleware.CORS(cfg.CookieDomain))

	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "env": cfg.Env})
	})

	// 8. Register API v1 Group (Base path /api/v1 as per API_Contract.md)
	apiV1 := router.Group("/api/v1")
	{
		auth.RegisterRoutes(apiV1, authHandler, cfg.JWTSecret)
		users.RegisterRoutes(apiV1, userHandler, cfg.JWTSecret)
		invitations.RegisterRoutes(apiV1, invHandler, cfg.JWTSecret)
		clinics.RegisterRoutes(apiV1, clinicHandler, cfg.JWTSecret)
		accessrequests.RegisterRoutes(apiV1, arHandler, cfg.JWTSecret)
		magiclink.RegisterRoutes(apiV1, magicHandler)
	}

	v1 := router.Group("/v1")
	{
		auth.RegisterRoutes(v1, authHandler, cfg.JWTSecret)
		users.RegisterRoutes(v1, userHandler, cfg.JWTSecret)
		invitations.RegisterRoutes(v1, invHandler, cfg.JWTSecret)
		clinics.RegisterRoutes(v1, clinicHandler, cfg.JWTSecret)
		accessrequests.RegisterRoutes(v1, arHandler, cfg.JWTSecret)
		magiclink.RegisterRoutes(v1, magicHandler)
	}

	// 8. Start HTTP Server
	serverAddr := ":" + cfg.Port
	log.Printf("AfyaMind API server running on %s (env: %s)", serverAddr, cfg.Env)
	if err := router.Run(serverAddr); err != nil {
		log.Fatalf("Server run error: %v", err)
	}
}
