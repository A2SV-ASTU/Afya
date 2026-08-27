package auth

import (
	"context"

	"afyamind-backend/src/database"
	"afyamind-backend/src/users"

	"github.com/google/uuid"
)

type Repository interface {
	FindByEmail(ctx context.Context, email string) (*users.User, error)
	FindByPhone(ctx context.Context, phone string) (*users.User, error)
	FindByLogin(ctx context.Context, login string) (*users.User, error)
	FindByID(ctx context.Context, id uuid.UUID) (*users.User, error)
	Create(ctx context.Context, user *users.User) error
}

type repository struct {
	userRepo users.Repository
}

func NewRepository(db database.DBTX) Repository {
	return &repository{
		userRepo: users.NewRepository(db),
	}
}

func NewRepositoryWithUserRepo(userRepo users.Repository) Repository {
	return &repository{
		userRepo: userRepo,
	}
}

func (r *repository) FindByEmail(ctx context.Context, email string) (*users.User, error) {
	return r.userRepo.FindByEmail(ctx, email)
}

func (r *repository) FindByPhone(ctx context.Context, phone string) (*users.User, error) {
	return r.userRepo.FindByPhone(ctx, phone)
}

func (r *repository) FindByLogin(ctx context.Context, login string) (*users.User, error) {
	return r.userRepo.FindByLogin(ctx, login)
}

func (r *repository) FindByID(ctx context.Context, id uuid.UUID) (*users.User, error) {
	return r.userRepo.FindByID(ctx, id)
}

func (r *repository) Create(ctx context.Context, user *users.User) error {
	return r.userRepo.Create(ctx, user)
}
