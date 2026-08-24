package exercises

import (
	"net/http"

	"github.com/go-chi/chi/v5"
)

// RegisterRoutes registers all exercise routes (public + admin) on the given router.
func RegisterRoutes(r chi.Router, publicHandler *PublicHandler, adminHandler *AdminHandler, requireAuth, requireAdmin func(next http.Handler) http.Handler) {
	// Public routes — no auth required
	r.Get("/exercises", publicHandler.ListExercises)
	r.Get("/exercises/{slug}", publicHandler.GetExerciseBySlug)

	// Authenticated routes
	r.Group(func(r chi.Router) {
		r.Use(requireAuth)
		r.Post("/exercises/{exercise_id}/start", publicHandler.StartExercise)
		r.Patch("/exercises/{exercise_id}/progress", publicHandler.UpdateProgress)
		r.Post("/exercises/{exercise_id}/complete", publicHandler.CompleteExercise)
		r.Get("/exercise-completions/history", publicHandler.ListCompletionHistory)
	})

	// Admin routes
	r.Group(func(r chi.Router) {
		r.Use(requireAuth)
		r.Use(requireAdmin)
		r.Get("/admin/exercises", adminHandler.ListExercises)
		r.Get("/admin/exercises/{id}", adminHandler.GetExercise)
		r.Post("/admin/exercises", adminHandler.CreateExercise)
		r.Patch("/admin/exercises/{id}", adminHandler.UpdateExercise)
		r.Patch("/admin/exercises/{id}/status", adminHandler.UpdateExerciseStatus)
		r.Post("/admin/exercises/{id}/steps", adminHandler.CreateStep)
		r.Patch("/admin/exercise-steps/{id}", adminHandler.UpdateStep)
		r.Delete("/admin/exercise-steps/{id}", adminHandler.DeleteStep)
	})
}

// RegisterPublicRoutes registers only the public exercise routes.
func RegisterPublicRoutes(r chi.Router, handler *PublicHandler) {
	r.Get("/exercises", handler.ListExercises)
	r.Get("/exercises/{slug}", handler.GetExerciseBySlug)
}

// RegisterAuthRoutes registers authenticated exercise routes.
func RegisterAuthRoutes(r chi.Router, handler *PublicHandler) {
	r.Post("/exercises/{exercise_id}/start", handler.StartExercise)
	r.Patch("/exercises/{exercise_id}/progress", handler.UpdateProgress)
	r.Post("/exercises/{exercise_id}/complete", handler.CompleteExercise)
	r.Get("/exercise-completions/history", handler.ListCompletionHistory)
}

// RegisterAdminRoutes registers admin exercise routes.
func RegisterAdminRoutes(r chi.Router, handler *AdminHandler) {
	r.Get("/admin/exercises", handler.ListExercises)
	r.Get("/admin/exercises/{id}", handler.GetExercise)
	r.Post("/admin/exercises", handler.CreateExercise)
	r.Patch("/admin/exercises/{id}", handler.UpdateExercise)
	r.Patch("/admin/exercises/{id}/status", handler.UpdateExerciseStatus)
	r.Post("/admin/exercises/{id}/steps", handler.CreateStep)
	r.Patch("/admin/exercise-steps/{id}", handler.UpdateStep)
	r.Delete("/admin/exercise-steps/{id}", handler.DeleteStep)
}
