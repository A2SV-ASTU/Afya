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

// SendVerificationOTP sends a 6-digit email verification OTP to the user
func (s *Sender) SendVerificationOTP(toEmail, recipientName, otp string) error {
	subject := "Verify your Afya account"
	if recipientName == "" {
		recipientName = "there"
	}

	body := fmt.Sprintf(`<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: #f4f7f6; margin: 0; padding: 0; color: #333; }
        .container { max-width: 520px; margin: 40px auto; background: #ffffff; border-radius: 12px; overflow: hidden; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05); }
        .header { background: #0D9488; padding: 24px; text-align: center; }
        .header h1 { color: #ffffff; margin: 0; font-size: 24px; font-weight: 700; letter-spacing: -0.5px; }
        .content { padding: 32px 24px; }
        .greeting { font-size: 16px; margin-bottom: 16px; color: #374151; }
        .otp-box { background: #F0FDFA; border: 2px dashed #0D9488; border-radius: 8px; text-align: center; padding: 20px; margin: 24px 0; }
        .otp-code { font-size: 36px; font-weight: 800; letter-spacing: 8px; color: #0F766E; margin: 0; font-family: monospace; }
        .expiry-note { font-size: 13px; color: #6B7280; margin-top: 8px; }
        .instructions { font-size: 14px; line-height: 1.6; color: #4B5563; margin-bottom: 24px; }
        .footer { padding: 20px 24px; background: #F9FAFB; border-top: 1px solid #E5E7EB; text-align: center; font-size: 12px; color: #9CA3AF; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Afya Healthcare</h1>
        </div>
        <div class="content">
            <p class="greeting">Hi %s,</p>
            <p class="instructions">Thank you for registering with Afya. Please enter the following 6-digit verification code in the mobile application to verify your email address:</p>
            <div class="otp-box">
                <div class="otp-code">%s</div>
                <div class="expiry-note">This code expires in 10 minutes</div>
            </div>
            <p class="instructions">If you did not request this registration, please ignore this email.</p>
        </div>
        <div class="footer">
            &copy; Afya Health Systems. All rights reserved.
        </div>
    </div>
</body>
</html>`, recipientName, otp)

	return s.Send(toEmail, subject, body)
}

