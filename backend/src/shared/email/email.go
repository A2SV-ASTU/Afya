package email

import (
	"fmt"
	"log"
	"net/smtp"
	"os"
	"strconv"
)

// SMTPConfig holds the SMTP configuration loaded from environment variables
type SMTPConfig struct {
	Host     string
	Port     int
	Username string
	Password string
	From     string
	FromName string
}

// LoadSMTPConfig reads SMTP configuration from environment variables
func LoadSMTPConfig() (*SMTPConfig, error) {
	host := os.Getenv("SMTP_HOST")
	if host == "" {
		return nil, fmt.Errorf("SMTP_HOST environment variable is required")
	}

	portStr := os.Getenv("SMTP_PORT")
	if portStr == "" {
		return nil, fmt.Errorf("SMTP_PORT environment variable is required")
	}
	port, err := strconv.Atoi(portStr)
	if err != nil {
		return nil, fmt.Errorf("SMTP_PORT must be a valid integer: %w", err)
	}

	username := os.Getenv("SMTP_USERNAME")
	if username == "" {
		return nil, fmt.Errorf("SMTP_USERNAME environment variable is required")
	}

	password := os.Getenv("SMTP_PASSWORD")
	if password == "" {
		return nil, fmt.Errorf("SMTP_PASSWORD environment variable is required")
	}

	from := os.Getenv("SMTP_FROM_EMAIL")
	if from == "" {
		return nil, fmt.Errorf("SMTP_FROM_EMAIL environment variable is required")
	}

	fromName := os.Getenv("SMTP_FROM_NAME")
	if fromName == "" {
		fromName = "AfyaMind"
	}

	return &SMTPConfig{
		Host:     host,
		Port:     port,
		Username: username,
		Password: password,
		From:     from,
		FromName: fromName,
	}, nil
}

// Sender provides email sending functionality
type Sender struct {
	cfg *SMTPConfig
}

// NewSender creates a new email Sender with the given SMTP configuration
func NewSender(cfg *SMTPConfig) *Sender {
	return &Sender{cfg: cfg}
}

// Send sends an email with the given subject and body to the specified recipient
func (s *Sender) Send(to string, subject string, body string) error {
	from := fmt.Sprintf("%s <%s>", s.cfg.FromName, s.cfg.From)

	msg := fmt.Sprintf("From: %s\r\n"+
		"To: %s\r\n"+
		"Subject: %s\r\n"+
		"MIME-Version: 1.0\r\n"+
		"Content-Type: text/html; charset=\"UTF-8\"\r\n"+
		"\r\n"+
		"%s", from, to, subject, body)

	addr := fmt.Sprintf("%s:%d", s.cfg.Host, s.cfg.Port)
	auth := smtp.PlainAuth("", s.cfg.Username, s.cfg.Password, s.cfg.Host)

	if err := smtp.SendMail(addr, auth, s.cfg.From, []string{to}, []byte(msg)); err != nil {
		log.Printf("ERROR sending email to %s: %v", to, err)
		return fmt.Errorf("failed to send email to %s: %w", to, err)
	}

	log.Printf("Email sent successfully to %s (subject: %s)", to, subject)
	return nil
}
