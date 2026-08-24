package crisis

import (
	"net/http"

	"github.com/go-chi/chi/v5"
)

// RegisterRoutes registers all crisis routes (public + admin) on the given router.
// requireAuth and requireAdmin are middleware functions provided by the shared middleware package.
func RegisterRoutes(r chi.Router, publicHandler *PublicHandler, adminHandler *AdminHandler, requireAuth, requireAdmin func(next http.Handler) http.Handler) {
	// Public routes — no auth required
	r.Get("/crisis-resources", publicHandler.ListCrisisResources)

	// Authenticated routes
	r.Group(func(r chi.Router) {
		r.Use(requireAuth)
		r.Post("/crisis-events", publicHandler.CreateCrisisEvent)
	})

	// Admin routes
	r.Group(func(r chi.Router) {
		r.Use(requireAuth)
		r.Use(requireAdmin)

		// Crisis Resources CRUD
		r.Get("/admin/crisis-resources", adminHandler.ListResources)
		r.Get("/admin/crisis-resources/{id}", adminHandler.GetResource)
		r.Post("/admin/crisis-resources", adminHandler.CreateResource)
		r.Patch("/admin/crisis-resources/{id}", adminHandler.UpdateResource)
		r.Patch("/admin/crisis-resources/{id}/status", adminHandler.UpdateResourceStatus)
		r.Delete("/admin/crisis-resources/{id}", adminHandler.DeleteResource)

		// Crisis Events (read-only)
		r.Get("/admin/crisis-events", adminHandler.ListEvents)
		r.Get("/admin/crisis-events/{id}", adminHandler.GetEvent)
	})
}

// RegisterPublicRoutes registers only the public crisis routes (no middleware).
func RegisterPublicRoutes(r chi.Router, handler *PublicHandler) {
	r.Get("/crisis-resources", handler.ListCrisisResources)
}

// RegisterAuthRoutes registers authenticated crisis routes.
func RegisterAuthRoutes(r chi.Router, handler *PublicHandler) {
	r.Post("/crisis-events", handler.CreateCrisisEvent)
}

// RegisterAdminRoutes registers admin crisis routes.
func RegisterAdminRoutes(r chi.Router, handler *AdminHandler) {
	r.Get("/admin/crisis-resources", handler.ListResources)
	r.Get("/admin/crisis-resources/{id}", handler.GetResource)
	r.Post("/admin/crisis-resources", handler.CreateResource)
	r.Patch("/admin/crisis-resources/{id}", handler.UpdateResource)
	r.Patch("/admin/crisis-resources/{id}/status", handler.UpdateResourceStatus)
	r.Delete("/admin/crisis-resources/{id}", handler.DeleteResource)
	r.Get("/admin/crisis-events", handler.ListEvents)
	r.Get("/admin/crisis-events/{id}", handler.GetEvent)
}
