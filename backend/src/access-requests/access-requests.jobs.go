package accessrequests

import (
	"context"
	"log"
	"time"
)

// MarkExpiredRequests flips stale pending access requests to expired.
func MarkExpiredRequests(ctx context.Context, repo Repository) (int64, error) {
	return repo.MarkExpired(ctx)
}

// StartExpirationJob runs a background goroutine that periodically flips
// any pending access request past its expires_at to "expired".
// approve/deny handlers still check expires_at at call time — this job
// is belt-and-suspenders, not the sole mechanism.
func StartExpirationJob(ctx context.Context, repo Repository, interval time.Duration) {
	go func() {
		ticker := time.NewTicker(interval)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				log.Println("access-request expiration job: stopped")
				return
			case <-ticker.C:
				n, err := repo.MarkExpired(ctx)
				if err != nil {
					log.Printf("access-request expiration job: error: %v", err)
				} else if n > 0 {
					log.Printf("access-request expiration job: marked %d request(s) as expired", n)
				}
			}
		}
	}()
	log.Printf("access-request expiration job: started (interval=%s)", interval)
}
