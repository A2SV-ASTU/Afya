package database

import (
	"context"
	"database/sql"
)

// DBTX is an interface satisfied by both *sql.DB and *sql.Tx,
// allowing repositories to work inside or outside a transaction.
type DBTX interface {
	ExecContext(ctx context.Context, query string, args ...interface{}) (sql.Result, error)
	QueryContext(ctx context.Context, query string, args ...interface{}) (*sql.Rows, error)
	QueryRowContext(ctx context.Context, query string, args ...interface{}) *sql.Row
}
