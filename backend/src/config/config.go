package config

import (
	"fmt"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	Port                     string
	Env                      string
	DBDSN                    string
	JWTSecret                string
	AccessTokenExpiryMinutes int
	RefreshTokenExpiryDays   int
	CookieDomain             string
	CookieSecure             bool
	APIBaseURL               string
}

func Load() (*Config, error) {
	// Attempt to load .env file, but don't fail if it doesn't exist (env vars might be set in OS/container)
	_ = godotenv.Load(".env", "backend/.env", "../.env", "../../.env")

	dbDSN := os.Getenv("DB_DSN")
	jwtSecret := os.Getenv("JWT_SECRET")

	if jwtSecret == "" {
		jwtSecret = "default_dev_secret_key_change_in_production"
	}

	port := getEnv("PORT", "8080")
	env := getEnv("ENV", "development")
	cookieDomain := getEnv("COOKIE_DOMAIN", "localhost")
	cookieSecure := getEnvAsBool("COOKIE_SECURE", false)

	accessTokenExpiry := getEnvAsInt("ACCESS_TOKEN_EXPIRY_MINUTES", 15)
	refreshTokenExpiry := getEnvAsInt("REFRESH_TOKEN_EXPIRY_DAYS", 7)
	apiBaseURL := getEnv("API_BASE_URL", "http://localhost:8080")

	cfg := &Config{
		Port:                     port,
		Env:                      env,
		DBDSN:                    dbDSN,
		JWTSecret:                jwtSecret,
		AccessTokenExpiryMinutes: accessTokenExpiry,
		RefreshTokenExpiryDays:   refreshTokenExpiry,
		CookieDomain:             cookieDomain,
		CookieSecure:             cookieSecure,
		APIBaseURL:               apiBaseURL,
	}

	return cfg, nil
}

func (c *Config) Validate() error {
	if c.DBDSN == "" {
		return fmt.Errorf("DB_DSN environment variable is required")
	}
	return nil
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists && value != "" {
		return value
	}
	return fallback
}

func getEnvAsInt(key string, fallback int) int {
	strValue := getEnv(key, "")
	if strValue == "" {
		return fallback
	}
	if value, err := strconv.Atoi(strValue); err == nil {
		return value
	}
	return fallback
}

func getEnvAsBool(key string, fallback bool) bool {
	strValue := getEnv(key, "")
	if strValue == "" {
		return fallback
	}
	if value, err := strconv.ParseBool(strValue); err == nil {
		return value
	}
	return fallback
}
