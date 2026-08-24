package response

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestJSON_SetsContentType(t *testing.T) {
	w := httptest.NewRecorder()
	JSON(w, http.StatusOK, map[string]string{"key": "value"})

	assert.Equal(t, "application/json", w.Header().Get("Content-Type"))
	assert.Equal(t, http.StatusOK, w.Code)
}

func TestJSON_EncodesPayload(t *testing.T) {
	w := httptest.NewRecorder()
	payload := map[string]string{"hello": "world"}
	JSON(w, http.StatusOK, payload)

	var parsed map[string]string
	err := json.Unmarshal(w.Body.Bytes(), &parsed)
	require.NoError(t, err)
	assert.Equal(t, "world", parsed["hello"])
}

func TestJSON_NilPayload(t *testing.T) {
	w := httptest.NewRecorder()
	JSON(w, http.StatusNoContent, nil)

	assert.Equal(t, http.StatusNoContent, w.Code)
	assert.Empty(t, w.Body.Bytes())
}

func TestError_MatchesContractFormat(t *testing.T) {
	w := httptest.NewRecorder()
	Error(w, http.StatusNotFound, "not_found", "Resource not found.")

	assert.Equal(t, http.StatusNotFound, w.Code)
	assert.Equal(t, "application/json", w.Header().Get("Content-Type"))

	var resp ErrorBody
	err := json.Unmarshal(w.Body.Bytes(), &resp)
	require.NoError(t, err)
	assert.Equal(t, "not_found", resp.Error.Code)
	assert.Equal(t, "Resource not found.", resp.Error.Message)
}

func TestError_AllErrorCodes(t *testing.T) {
	// Test all error codes from the contract's Appendix
	codes := []struct {
		status  int
		code    string
		message string
	}{
		{http.StatusBadRequest, "invalid_email", "Email address is invalid."},
		{http.StatusBadRequest, "invalid_password", "Password too short."},
		{http.StatusUnauthorized, "invalid_credentials", "Email or password is incorrect."},
		{http.StatusUnauthorized, "unauthorized", "Missing or expired session cookie."},
		{http.StatusForbidden, "forbidden_role", "Not permitted for this role."},
		{http.StatusBadRequest, "invalid_token", "Token is invalid."},
		{http.StatusBadRequest, "attestation_required", "Must confirm age."},
		{http.StatusNotFound, "not_found", "Resource not found."},
		{http.StatusBadRequest, "validation_error", "Request body failed validation."},
	}

	for _, tc := range codes {
		t.Run(tc.code, func(t *testing.T) {
			w := httptest.NewRecorder()
			Error(w, tc.status, tc.code, tc.message)

			var resp ErrorBody
			err := json.Unmarshal(w.Body.Bytes(), &resp)
			require.NoError(t, err)
			assert.Equal(t, tc.code, resp.Error.Code)
			assert.Equal(t, tc.message, resp.Error.Message)
		})
	}
}

func TestError_ResponseStructure(t *testing.T) {
	w := httptest.NewRecorder()
	Error(w, http.StatusBadRequest, "validation_error", "Bad request.")

	// Contract: { "error": { "code": "string", "message": "string" } }
	var raw map[string]interface{}
	err := json.Unmarshal(w.Body.Bytes(), &raw)
	require.NoError(t, err)

	// Must have exactly "error" at top level
	assert.Len(t, raw, 1, "Error response must have exactly one top-level key")
	assert.Contains(t, raw, "error")

	errorObj := raw["error"].(map[string]interface{})
	assert.Contains(t, errorObj, "code")
	assert.Contains(t, errorObj, "message")
	assert.Len(t, errorObj, 2, "Error object must have exactly 'code' and 'message'")
}

func TestNoContent_Returns204(t *testing.T) {
	w := httptest.NewRecorder()
	NoContent(w)

	assert.Equal(t, http.StatusNoContent, w.Code)
	assert.Empty(t, w.Body.Bytes())
}
