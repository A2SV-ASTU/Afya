package response

// DataEnvelope is the standard success wrapper returned by most endpoints.
// Used by Swagger annotations to generate accurate response schemas.
//
//	@Description	Standard API success response
type DataEnvelope struct {
	// The response payload - structure varies per endpoint
	Data interface{} `json:"data"`
}

// MessageEnvelope is the success wrapper for endpoints that return a simple message.
//
//	@Description	Simple message response
type MessageEnvelope struct {
	// Human-readable status message
	Data MessageBody `json:"data"`
}

// MessageBody holds a plain text message field.
type MessageBody struct {
	Message string `json:"message" example:"Operation completed successfully"`
}
