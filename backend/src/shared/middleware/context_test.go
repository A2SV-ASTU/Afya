package middleware

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestGetUserID_ReturnsValue(t *testing.T) {
	ctx := context.WithValue(context.Background(), UserIDKey, "usr_123")
	assert.Equal(t, "usr_123", GetUserID(ctx))
}

func TestGetUserID_ReturnsEmptyForMissing(t *testing.T) {
	ctx := context.Background()
	assert.Equal(t, "", GetUserID(ctx))
}

func TestGetUserID_ReturnsEmptyForWrongType(t *testing.T) {
	ctx := context.WithValue(context.Background(), UserIDKey, 12345)
	assert.Equal(t, "", GetUserID(ctx))
}

func TestGetUserRole_ReturnsValue(t *testing.T) {
	ctx := context.WithValue(context.Background(), UserRoleKey, "ADMIN")
	assert.Equal(t, "ADMIN", GetUserRole(ctx))
}

func TestGetUserRole_ReturnsEmptyForMissing(t *testing.T) {
	ctx := context.Background()
	assert.Equal(t, "", GetUserRole(ctx))
}

func TestGetUserRole_ReturnsEmptyForWrongType(t *testing.T) {
	ctx := context.WithValue(context.Background(), UserRoleKey, 42)
	assert.Equal(t, "", GetUserRole(ctx))
}

func TestContextKeys_AreDistinct(t *testing.T) {
	assert.NotEqual(t, UserIDKey, UserRoleKey)
}

func TestContextKeys_WorkTogether(t *testing.T) {
	ctx := context.Background()
	ctx = context.WithValue(ctx, UserIDKey, "usr_abc")
	ctx = context.WithValue(ctx, UserRoleKey, "PERSON")

	assert.Equal(t, "usr_abc", GetUserID(ctx))
	assert.Equal(t, "PERSON", GetUserRole(ctx))
}
