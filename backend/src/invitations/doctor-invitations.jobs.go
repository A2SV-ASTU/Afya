package invitations

import (
	"context"
	"log"
	"time"
)

// StartExpirationJob runs a background goroutine that periodically flips
// any pending invitation past its expires_at to "expired".
// The brief calls this out explicitly: don't rely on read-time checks alone.
func StartExpirationJob(ctx context.Context, svc Service, interval time.Duration) {
	go func() {
		ticker := time.NewTicker(interval)
		defer ticker.Stop()

		for {
			select {
			case <-ctx.Done():
				log.Println("invitation expiration job: stopped")
				return
			case <-ticker.C:
				n, err := svc.MarkExpired(ctx)
				if err != nil {
					log.Printf("invitation expiration job: error: %v", err)
				} else if n > 0 {
					log.Printf("invitation expiration job: marked %d invitation(s) as expired", n)
				}
			}
		}
	}()
	log.Printf("invitation expiration job: started (interval=%s)", interval)
}
