package crisis

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

	noopMiddleware := func(next http.Handler) http.Handler { return next }
	RegisterRoutes(router, publicHandler, adminHandler, noopMiddleware, noopMiddleware)

	routes := map[string]bool{}
	chi.Walk(router, func(method, route string, _ http.Handler, _ ...func(http.Handler) http.Handler) error {
		routes[method+" "+route] = true
		return nil
	})

	// Public routes
	assert.True(t, routes["GET /crisis-resources"], "GET /crisis-resources must be registered")

	// Auth routes
	assert.True(t, routes["POST /crisis-events"], "POST /crisis-events must be registered")

	// Admin routes — Crisis Resources CRUD
	assert.True(t, routes["GET /admin/crisis-resources"], "GET /admin/crisis-resources must be registered")
	assert.True(t, routes["GET /admin/crisis-resources/{id}"], "GET /admin/crisis-resources/{id} must be registered")
	assert.True(t, routes["POST /admin/crisis-resources"], "POST /admin/crisis-resources must be registered")
	assert.True(t, routes["PATCH /admin/crisis-resources/{id}"], "PATCH /admin/crisis-resources/{id} must be registered")
	assert.True(t, routes["PATCH /admin/crisis-resources/{id}/status"], "PATCH /admin/crisis-resources/{id}/status must be registered")
	assert.True(t, routes["DELETE /admin/crisis-resources/{id}"], "DELETE /admin/crisis-resources/{id} must be registered")

	// Admin routes — Crisis Events (read-only)
	assert.True(t, routes["GET /admin/crisis-events"], "GET /admin/crisis-events must be registered")
	assert.True(t, routes["GET /admin/crisis-events/{id}"], "GET /admin/crisis-events/{id} must be registered")
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
	chi.Walk(router, func(method, route string, _ http.Handler, _ ...func(http.Handler) http.Handler) error {
		count++
		return nil
	})

	// 1 public + 1 auth + 8 admin = 10 total endpoints
	assert.Equal(t, 10, count, "Crisis package must register exactly 10 endpoints")
}
