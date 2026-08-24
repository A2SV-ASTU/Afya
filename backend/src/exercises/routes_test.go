package exercises

import (
	"net/http"
	"testing"

	"github.com/go-chi/chi/v5"
	"github.com/stretchr/testify/assert"
)

func TestRegisterRoutes_AllEndpointsRegistered(t *testing.T) {
	router := chi.NewRouter()

	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	publicHandler := NewPublicHandler(svc)
	adminHandler := NewAdminHandler(svc)

	// Dummy middleware that just passes through
	noopMiddleware := func(next http.Handler) http.Handler {
		return next
	}

	RegisterRoutes(router, publicHandler, adminHandler, noopMiddleware, noopMiddleware)

	// Walk the routes and verify all expected paths are registered
	routes := map[string]bool{}
	_ = chi.Walk(router, func(method, route string, _ http.Handler, _ ...func(http.Handler) http.Handler) error {
		routes[method+" "+route] = true
		return nil
	})

	// Public routes
	assert.True(t, routes["GET /exercises"], "GET /exercises must be registered")
	assert.True(t, routes["GET /exercises/{slug}"], "GET /exercises/{slug} must be registered")

	// Auth routes
	assert.True(t, routes["POST /exercises/{exercise_id}/start"], "POST /exercises/{exercise_id}/start must be registered")
	assert.True(t, routes["PATCH /exercises/{exercise_id}/progress"], "PATCH /exercises/{exercise_id}/progress must be registered")
	assert.True(t, routes["POST /exercises/{exercise_id}/complete"], "POST /exercises/{exercise_id}/complete must be registered")
	assert.True(t, routes["GET /exercise-completions/history"], "GET /exercise-completions/history must be registered")

	// Admin routes
	assert.True(t, routes["GET /admin/exercises"], "GET /admin/exercises must be registered")
	assert.True(t, routes["GET /admin/exercises/{id}"], "GET /admin/exercises/{id} must be registered")
	assert.True(t, routes["POST /admin/exercises"], "POST /admin/exercises must be registered")
	assert.True(t, routes["PATCH /admin/exercises/{id}"], "PATCH /admin/exercises/{id} must be registered")
	assert.True(t, routes["PATCH /admin/exercises/{id}/status"], "PATCH /admin/exercises/{id}/status must be registered")
	assert.True(t, routes["POST /admin/exercises/{id}/steps"], "POST /admin/exercises/{id}/steps must be registered")
	assert.True(t, routes["PATCH /admin/exercise-steps/{id}"], "PATCH /admin/exercise-steps/{id} must be registered")
	assert.True(t, routes["DELETE /admin/exercise-steps/{id}"], "DELETE /admin/exercise-steps/{id} must be registered")
}

func TestRegisterRoutes_TotalEndpointCount(t *testing.T) {
	router := chi.NewRouter()

	repo := &Repository{db: nil}
	svc := NewService(repo, nil)
	publicHandler := NewPublicHandler(svc)
	adminHandler := NewAdminHandler(svc)

	noopMiddleware := func(next http.Handler) http.Handler { return next }
	RegisterRoutes(router, publicHandler, adminHandler, noopMiddleware, noopMiddleware)

	count := 0
	_ = chi.Walk(router, func(method, route string, _ http.Handler, _ ...func(http.Handler) http.Handler) error {
		count++
		return nil
	})

	// 6 public + 8 admin = 14 total endpoints
	assert.Equal(t, 14, count, "Exercises package must register exactly 14 endpoints")
}
