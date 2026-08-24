package audit

import "context"

// Logger is the interface that every domain package's admin writes call
// to record an audit log entry. The concrete implementation is in
// audit/service.go (owned by Dev B), but all domain packages depend
// only on this interface, keeping audit a leaf package.
type Logger interface {
	Log(ctx context.Context, actorUserID, action, entityType, entityID string, details map[string]interface{}) error
}
