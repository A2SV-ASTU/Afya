package token

import (
	"testing"
	"time"
)

func TestTokenGenerateAndParse(t *testing.T) {
	secret := "test_secret_key"
	userID := int64(42)
	role := "PERSON"

	tokenStr, err := GenerateToken(userID, role, TokenTypeAccess, 5*time.Minute, secret)
	if err != nil {
		t.Fatalf("unexpected error generating token: %v", err)
	}

	claims, err := ParseToken(tokenStr, secret)
	if err != nil {
		t.Fatalf("unexpected error parsing token: %v", err)
	}

	if claims.UserID != userID {
		t.Errorf("expected userID %d, got %d", userID, claims.UserID)
	}
	if claims.Role != role {
		t.Errorf("expected role %s, got %s", role, claims.Role)
	}
	if claims.TokenType != TokenTypeAccess {
		t.Errorf("expected token type %s, got %s", TokenTypeAccess, claims.TokenType)
	}
}

func TestTokenInvalidSecret(t *testing.T) {
	secret := "test_secret_key"
	wrongSecret := "wrong_secret_key"

	tokenStr, err := GenerateToken(1, "PERSON", TokenTypeAccess, 5*time.Minute, secret)
	if err != nil {
		t.Fatalf("unexpected error generating token: %v", err)
	}

	_, err = ParseToken(tokenStr, wrongSecret)
	if err == nil {
		t.Fatal("expected error parsing token with wrong secret, got nil")
	}
}
