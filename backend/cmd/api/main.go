package main

import (
	"log"

	"afyamind-backend/src/auth"
	"afyamind-backend/src/config"
	"afyamind-backend/src/database"
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
	defer db.Close()

	log.Printf("Successfully connected to Postgres database")

	// 3. Initialize Repositories
	userRepo := users.NewRepository(db)
	authRepo := auth.NewRepositoryWithUserRepo(userRepo)

	// 4. Initialize Services
	userService := users.NewService(userRepo)
	authService := auth.NewService(authRepo, cfg)

	// 5. Initialize Handlers
	userHandler := users.NewHandler(userService)
	authHandler := auth.NewHandler(authService, cfg)

	// 6. Setup Gin Router & Middlewares
	router := gin.New()
	router.Use(middleware.Logging())
	router.Use(middleware.Recovery())
	router.Use(middleware.CORS(cfg.CookieDomain))

	// Health check endpoint
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "env": cfg.Env})
	})

	// 7. Register API v1 Group
	v1 := router.Group("/v1")
	{
		auth.RegisterRoutes(v1, authHandler, cfg.JWTSecret)
		users.RegisterRoutes(v1, userHandler, cfg.JWTSecret)
	}

	// 8. Start HTTP Server
	serverAddr := ":" + cfg.Port
	log.Printf("AfyaMind API server running on %s (env: %s)", serverAddr, cfg.Env)
	if err := router.Run(serverAddr); err != nil {
		log.Fatalf("Server run error: %v", err)
	}
}
