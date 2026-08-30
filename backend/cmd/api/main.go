// Package main is the entry point for the AfyaMind API server.
//
//	@title			AfyaMind API
//	@version		1.0
//	@description	AfyaMind telemedicine platform REST API.
//	@description	**Authentication:** Most protected endpoints require a JWT Bearer token.
//	@description	Login via POST /auth/login, then click the **Authorize** button above and enter: `Bearer <your_token>`
//
//	@contact.name	AfyaMind Support
//	@contact.email	support@afyamind.com
//
//	@license.name	MIT
//	@license.url	https://opensource.org/licenses/MIT
//
//	@host		localhost:8080
//	@BasePath	/api/v1
//	@schemes	http https
//
//	@securityDefinitions.apikey	BearerAuth
//	@in							header
//	@name						Authorization
//	@description				JWT access token. Format: **Bearer &lt;token&gt;**
//
//	@tag.name			Health
//	@tag.description	Service liveness and readiness check
//
//	@tag.name			Auth
//	@tag.description	Registration, login, token refresh, forgot/reset password, and logout
//
//	@tag.name			Users
//	@tag.description	Authenticated user profile management (self-service)
//
//	@tag.name			Invitations
//	@tag.description	Doctor registration/invitation links
//
//	@tag.name			Clinics
//	@tag.description	Clinic registration, status toggle, and doctor list/status administration
//
//	@tag.name			AccessRequests
//	@tag.description	Patient consent & clinical record access control
//
//	@tag.name			Appointments
//	@tag.description	Appointment scheduling between patients and doctors
//
//	@tag.name			Encounters
//	@tag.description	Clinical encounter records, medical history, and status
//
//	@tag.name			ClinicalEvaluations
//	@tag.description	Chief complaints and examinations recorded during encounters
//
//	@tag.name			Prescriptions
//	@tag.description	(Coming soon) Prescription management
//
//	@tag.name			Labs
//	@tag.description	(Coming soon) Laboratory test orders and results
//
//	@tag.name			Diagnoses
//	@tag.description	(Coming soon) Diagnosis records
//
//	@tag.name			Vitals
//	@tag.description	(Coming soon) Patient vital signs
//
//	@tag.name			MagicLinks
//	@tag.description	Browser-rendered HTML pages for password reset, doctor invitations, and patient access request approvals — no API integration needed
package main

import (
	"context"
	"log"
	"time"

	_ "afyamind-backend/docs" // swaggo generated docs — DO NOT REMOVE

	"afyamind-backend/src/access-requests"
	"afyamind-backend/src/appointments"
	"afyamind-backend/src/auth"
	"afyamind-backend/src/bootstrap"
	clinicalevaluations "afyamind-backend/src/clinical-evaluations"
	"afyamind-backend/src/clinics"
	"afyamind-backend/src/config"
	"afyamind-backend/src/database"
	"afyamind-backend/src/encounters"
	"afyamind-backend/src/invitations"
	"afyamind-backend/src/magiclink"
	sharedAuth "afyamind-backend/src/shared/auth"
	"afyamind-backend/src/shared/email"
	"afyamind-backend/src/shared/middleware"
	"afyamind-backend/src/users"

	"github.com/gin-gonic/gin"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
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
	sharedAuth.DB = db
	userRepo := users.NewRepository(db)
	authRepo := auth.NewRepository(db)
	invRepo := invitations.NewRepository(db)
	clinicRepo := clinics.NewRepository(db)
	arRepo := accessrequests.NewRepository(db)
	apptRepo := appointments.NewRepository(db)
	encRepo := encounters.NewRepository(db)
	evalRepo := clinicalevaluations.NewRepository(db)

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
	apptService := appointments.NewService(apptRepo, arRepo)
	encService := encounters.NewService(encRepo, userRepo)
	evalService := clinicalevaluations.NewService(evalRepo, encRepo)

	// 6. Initialize Handlers
	userHandler := users.NewHandler(userService)
	authHandler := auth.NewHandler(authService, cfg)
	invHandler := invitations.NewHandler(invService, cfg)
	clinicHandler := clinics.NewHandler(clinicService)
	arHandler := accessrequests.NewHandler(arService, cfg)
	apptHandler := appointments.NewHandler(apptService)
	encHandler := encounters.NewHandler(encService)
	evalHandler := clinicalevaluations.NewHandler(evalService)
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
	//
	//	@Summary		Health check
	//	@Description	Returns the current service status and environment name.
	//	@Tags			Health
	//	@Produce		json
	//	@Success		200	{object}	map[string]string	"Service is healthy"
	//	@Router			/health [get]
	router.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok", "env": cfg.Env})
	})

	// Swagger UI — available at /swagger/index.html
	// Disabled in production to avoid exposing API internals.
	if cfg.Env != "production" {
		router.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))
		log.Printf("Swagger UI available at http://localhost:%s/swagger/index.html", cfg.Port)
	}

	// 8. Register API v1 Group (Base path /api/v1 as per API_Contract.md)
	apiV1 := router.Group("/api/v1")
	{
		auth.RegisterRoutes(apiV1, authHandler, cfg.JWTSecret)
		users.RegisterRoutes(apiV1, userHandler, cfg.JWTSecret)
		invitations.RegisterRoutes(apiV1, invHandler, cfg.JWTSecret)
		clinics.RegisterRoutes(apiV1, clinicHandler, cfg.JWTSecret)
		accessrequests.RegisterRoutes(apiV1, arHandler, cfg.JWTSecret)
		appointments.RegisterRoutes(apiV1, apptHandler, cfg.JWTSecret)
		encounters.RegisterRoutes(apiV1, encHandler, db, cfg.JWTSecret)
		clinicalevaluations.RegisterRoutes(apiV1, evalHandler, db, cfg.JWTSecret)
		magiclink.RegisterRoutes(apiV1, magicHandler)
	}

	v1 := router.Group("/v1")
	{
		auth.RegisterRoutes(v1, authHandler, cfg.JWTSecret)
		users.RegisterRoutes(v1, userHandler, cfg.JWTSecret)
		invitations.RegisterRoutes(v1, invHandler, cfg.JWTSecret)
		clinics.RegisterRoutes(v1, clinicHandler, cfg.JWTSecret)
		accessrequests.RegisterRoutes(v1, arHandler, cfg.JWTSecret)
		appointments.RegisterRoutes(v1, apptHandler, cfg.JWTSecret)
		encounters.RegisterRoutes(v1, encHandler, db, cfg.JWTSecret)
		clinicalevaluations.RegisterRoutes(v1, evalHandler, db, cfg.JWTSecret)
		magiclink.RegisterRoutes(v1, magicHandler)
	}

	// 8. Start HTTP Server
	serverAddr := ":" + cfg.Port
	log.Printf("AfyaMind API server running on %s (env: %s)", serverAddr, cfg.Env)
	if err := router.Run(serverAddr); err != nil {
		log.Fatalf("Server run error: %v", err)
	}
}
