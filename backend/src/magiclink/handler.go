package magiclink

import (
	"fmt"
	"net/http"

	accessrequests "afyamind-backend/src/access-requests"
	"afyamind-backend/src/auth"
	"afyamind-backend/src/config"

	"github.com/gin-gonic/gin"
)

// Handler serves the HTML confirmation pages and processes magic link actions
type Handler struct {
	arService   accessrequests.Service
	authService auth.Service
	cfg         *config.Config
}

// NewHandler creates a new magic link handler
func NewHandler(arService accessrequests.Service, authService auth.Service, cfg *config.Config) *Handler {
	return &Handler{
		arService:   arService,
		authService: authService,
		cfg:         cfg,
	}
}

// RegisterRoutes registers the public magic link routes directly on the router
func RegisterRoutes(rg *gin.RouterGroup, handler *Handler) {
	magic := rg.Group("/magic")
	{
		magic.GET("/access-request", handler.ViewAccessRequestPage)
		magic.POST("/access-request", handler.ConfirmAccessRequest)
		magic.GET("/reset-password", handler.ViewResetPasswordPage)
		magic.POST("/reset-password", handler.ConfirmResetPassword)
		magic.GET("/accept-invitation", handler.ViewAcceptInvitationPage)
	}
}

// ---------- Access Request: View Confirmation Page ----------

func (h *Handler) ViewAccessRequestPage(c *gin.Context) {
	token := c.Query("token")
	action := c.Query("action")

	if token == "" || (action != "approve" && action != "deny") {
		c.Header("Content-Type", "text/html; charset=utf-8")
		c.String(http.StatusBadRequest, renderErrorPage("Invalid Link", "This link is invalid or incomplete. Please check the link in your email and try again."))
		return
	}

	actionLabel := "Approve"
	actionColor := "#22c55e"
	actionDescription := "grant this clinic access to your medical records"
	if action == "deny" {
		actionLabel = "Deny"
		actionColor = "#ef4444"
		actionDescription = "deny this clinic access to your medical records"
	}

	c.Header("Content-Type", "text/html; charset=utf-8")
	c.String(http.StatusOK, renderAccessRequestPage(token, action, actionLabel, actionColor, actionDescription))
}

// ---------- Access Request: Process Confirmation ----------

func (h *Handler) ConfirmAccessRequest(c *gin.Context) {
	token := c.PostForm("token")
	action := c.PostForm("action")

	if token == "" || (action != "approve" && action != "deny") {
		c.Header("Content-Type", "text/html; charset=utf-8")
		c.String(http.StatusBadRequest, renderErrorPage("Invalid Request", "Missing token or action. Please use the link from your email."))
		return
	}

	var err error
	if action == "approve" {
		err = h.arService.ApproveByToken(c.Request.Context(), token)
	} else {
		err = h.arService.DenyByToken(c.Request.Context(), token)
	}

	if err != nil {
		msg := "Something went wrong. Please try again."
		if err.Error() == "invalid_token" {
			msg = "This link is invalid. It may have already been used or the token is incorrect."
		} else if err.Error() == "request_not_pending" {
			msg = "This access request has already been processed. No further action is needed."
		} else if err.Error() == "request_expired" {
			msg = "This access request has expired. The clinic will need to send a new request."
		}
		c.Header("Content-Type", "text/html; charset=utf-8")
		c.String(http.StatusOK, renderErrorPage("Unable to Process", msg))
		return
	}

	resultLabel := "Approved"
	resultColor := "#22c55e"
	resultMsg := "You have successfully granted access to your medical records. The clinic can now view your records."
	if action == "deny" {
		resultLabel = "Denied"
		resultColor = "#ef4444"
		resultMsg = "You have denied the access request. The clinic will not be able to view your records."
	}

	c.Header("Content-Type", "text/html; charset=utf-8")
	c.String(http.StatusOK, renderSuccessPage(resultLabel, resultColor, resultMsg))
}

// ---------- Password Reset: View Page ----------

func (h *Handler) ViewResetPasswordPage(c *gin.Context) {
	token := c.Query("token")
	if token == "" {
		c.Header("Content-Type", "text/html; charset=utf-8")
		c.String(http.StatusBadRequest, renderErrorPage("Invalid Link", "This password reset link is invalid or incomplete. Please check the link in your email."))
		return
	}

	c.Header("Content-Type", "text/html; charset=utf-8")
	c.String(http.StatusOK, renderResetPasswordPage(token, h.cfg.APIBaseURL))
}

// ---------- Password Reset: Process Form ----------

func (h *Handler) ConfirmResetPassword(c *gin.Context) {
	token := c.PostForm("token")
	password := c.PostForm("password")
	confirmPassword := c.PostForm("confirm_password")

	if token == "" {
		c.Header("Content-Type", "text/html; charset=utf-8")
		c.String(http.StatusBadRequest, renderErrorPage("Invalid Request", "Missing reset token. Please use the link from your email."))
		return
	}

	if password == "" || len(password) < 8 {
		c.Header("Content-Type", "text/html; charset=utf-8")
		c.String(http.StatusOK, renderErrorPage("Invalid Password", "Password must be at least 8 characters long. Please go back and try again."))
		return
	}

	if password != confirmPassword {
		c.Header("Content-Type", "text/html; charset=utf-8")
		c.String(http.StatusOK, renderErrorPage("Passwords Don't Match", "The passwords you entered do not match. Please go back and try again."))
		return
	}

	appErr := h.authService.ResetPassword(c.Request.Context(), token, password)
	if appErr != nil {
		msg := "Something went wrong. Please try again."
		if appErr.Code == "validation_error" {
			msg = appErr.Message
		}
		c.Header("Content-Type", "text/html; charset=utf-8")
		c.String(http.StatusOK, renderErrorPage("Unable to Reset Password", msg))
		return
	}

	c.Header("Content-Type", "text/html; charset=utf-8")
	c.String(http.StatusOK, renderSuccessPage("Password Reset", "#22c55e", "Your password has been successfully reset. You can now log in to the Afya app with your new password."))
}

// ---------- Doctor Invitation: Redirect to Web ----------

func (h *Handler) ViewAcceptInvitationPage(c *gin.Context) {
	token := c.Query("token")
	if token == "" {
		c.Header("Content-Type", "text/html; charset=utf-8")
		c.String(http.StatusBadRequest, renderErrorPage("Invalid Link", "This invitation link is invalid or incomplete. Please check the link in your email."))
		return
	}

	// For doctor invitations, the accept flow requires filling out a form with
	// first_name, last_name, phone, password, license_number, specialization.
	// We serve a full HTML form that POSTs to the existing API endpoint.
	c.Header("Content-Type", "text/html; charset=utf-8")
	c.String(http.StatusOK, renderAcceptInvitationPage(token, h.cfg.APIBaseURL))
}

// ---------- HTML Template Renderers ----------

func renderAccessRequestPage(token, action, actionLabel, actionColor, actionDescription string) string {
	return fmt.Sprintf(`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Afya - %s Access Request</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f0fdf4 0%%, #dcfce7 100%%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            position: relative;
            overflow: hidden;
        }
        body::before {
            content: '';
            position: absolute;
            top: -50%%; left: -50%%; width: 200%%; height: 200%%;
            background: radial-gradient(circle, rgba(34,197,94,0.05) 0%%, transparent 60%%);
            animation: pulse 15s ease-in-out infinite alternate;
            z-index: 0;
        }
        @keyframes pulse {
            0%% { transform: scale(1); }
            100%% { transform: scale(1.1); }
        }
        .card {
            max-width: 480px;
            width: 100%%;
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border-radius: 24px;
            border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 25px 50px -12px rgba(22, 163, 74, 0.15), 0 0 0 1px rgba(255, 255, 255, 0.2);
            overflow: hidden;
            z-index: 1;
            position: relative;
        }
        .card-header {
            background: linear-gradient(135deg, %s 0%%, #16a34a 100%%);
            padding: 48px 30px;
            text-align: center;
            color: #fff;
            position: relative;
        }
        .card-header::after {
            content: ''; position: absolute; bottom: -20px; left: 0; right: 0; height: 40px;
            background: rgba(255,255,255,0.9); border-radius: 50%% 50%% 0 0;
        }
        .card-header h1 { font-size: 28px; font-weight: 700; letter-spacing: -0.5px; }
        .card-header p { margin-top: 10px; opacity: 0.9; font-size: 16px; font-weight: 400; }
        .card-body { padding: 20px 40px 40px; text-align: center; color: #374151; line-height: 1.7; font-size: 16px; }
        .card-body p { margin-bottom: 28px; color: #4b5563; }
        .card-body strong { color: #111827; }
        .btn {
            display: inline-flex; align-items: center; justify-content: center;
            width: 100%%; padding: 16px 32px;
            border-radius: 12px; border: none;
            font-weight: 600; font-size: 16px;
            cursor: pointer; color: #fff;
            background-color: %s;
            text-decoration: none;
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px -1px rgba(34, 197, 94, 0.2), 0 2px 4px -1px rgba(34, 197, 94, 0.1);
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(34, 197, 94, 0.3), 0 4px 6px -2px rgba(34, 197, 94, 0.15);
        }
        .btn:active { transform: translateY(0); }
        .footer { padding: 24px; text-align: center; font-size: 13px; color: #9ca3af; border-top: 1px solid rgba(0,0,0,0.05); }
    </style>
</head>
<body>
    <div class="card">
        <div class="card-header">
            <h1>%s Access Request</h1>
            <p>Confirm your decision</p>
        </div>
        <div class="card-body">
            <p>You are about to <strong>%s</strong>.</p>
            <p style="font-size: 14px; color: #6b7280;">This action cannot be undone. Please click below to confirm.</p>
            <form method="POST" action="">
                <input type="hidden" name="token" value="%s">
                <input type="hidden" name="action" value="%s">
                <button type="submit" class="btn">Confirm %s</button>
            </form>
        </div>
        <div class="footer">
            <p>&copy; 2026 Afya. Secure Access Gateway.</p>
        </div>
    </div>
</body>
</html>`, actionLabel, actionColor, actionColor, actionLabel, actionDescription, token, action, actionLabel)
}

func renderSuccessPage(title, color, message string) string {
	return fmt.Sprintf(`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Afya - %s</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f0fdf4 0%%, #dcfce7 100%%);
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center; padding: 20px;
            position: relative; overflow: hidden;
        }
        body::before {
            content: ''; position: absolute; top: -50%%; left: -50%%; width: 200%%; height: 200%%;
            background: radial-gradient(circle, rgba(34,197,94,0.05) 0%%, transparent 60%%);
            animation: pulse 15s ease-in-out infinite alternate; z-index: 0;
        }
        @keyframes pulse { 0%% { transform: scale(1); } 100%% { transform: scale(1.1); } }
        .card {
            max-width: 480px; width: 100%%;
            background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(16px);
            border-radius: 24px; border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 25px 50px -12px rgba(22, 163, 74, 0.15), 0 0 0 1px rgba(255, 255, 255, 0.2);
            overflow: hidden; z-index: 1; position: relative;
        }
        .card-header {
            background: linear-gradient(135deg, %s 0%%, #16a34a 100%%);
            padding: 48px 30px; text-align: center; color: #fff; position: relative;
        }
        .card-header::after {
            content: ''; position: absolute; bottom: -20px; left: 0; right: 0; height: 40px;
            background: rgba(255,255,255,0.95); border-radius: 50%% 50%% 0 0;
        }
        .card-header h1 { font-size: 28px; font-weight: 700; letter-spacing: -0.5px; }
        .checkmark {
            width: 72px; height: 72px; background: rgba(255,255,255,0.2);
            border-radius: 50%%; display: flex; align-items: center; justify-content: center;
            margin: 0 auto 20px; font-size: 36px; border: 2px solid rgba(255,255,255,0.5);
        }
        .card-body { padding: 20px 40px 40px; text-align: center; color: #4b5563; line-height: 1.7; font-size: 16px; }
        .footer { padding: 24px; text-align: center; font-size: 13px; color: #9ca3af; border-top: 1px solid rgba(0,0,0,0.05); }
    </style>
</head>
<body>
    <div class="card">
        <div class="card-header">
            <div class="checkmark">✓</div>
            <h1>%s</h1>
        </div>
        <div class="card-body">
            <p>%s</p>
            <p style="margin-top: 24px; color: #9ca3af; font-size: 14px; font-weight: 500;">You may safely close this page.</p>
        </div>
        <div class="footer">
            <p>&copy; 2026 Afya. Secure Access Gateway.</p>
        </div>
    </div>
</body>
</html>`, color, title, message)
}

func renderErrorPage(title, message string) string {
	return fmt.Sprintf(`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Afya - %s</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #fef2f2 0%%, #fee2e2 100%%);
            min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px;
            position: relative; overflow: hidden;
        }
        body::before {
            content: ''; position: absolute; top: -50%%; left: -50%%; width: 200%%; height: 200%%;
            background: radial-gradient(circle, rgba(239,68,68,0.05) 0%%, transparent 60%%);
            animation: pulse 15s ease-in-out infinite alternate; z-index: 0;
        }
        @keyframes pulse { 0%% { transform: scale(1); } 100%% { transform: scale(1.1); } }
        .card {
            max-width: 480px; width: 100%%;
            background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(16px);
            border-radius: 24px; border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 25px 50px -12px rgba(239, 68, 68, 0.15), 0 0 0 1px rgba(255, 255, 255, 0.2);
            overflow: hidden; z-index: 1; position: relative;
        }
        .card-header {
            background: linear-gradient(135deg, #ef4444 0%%, #dc2626 100%%);
            padding: 48px 30px; text-align: center; color: #fff; position: relative;
        }
        .card-header::after {
            content: ''; position: absolute; bottom: -20px; left: 0; right: 0; height: 40px;
            background: rgba(255,255,255,0.95); border-radius: 50%% 50%% 0 0;
        }
        .card-header h1 { font-size: 28px; font-weight: 700; letter-spacing: -0.5px; }
        .icon {
            width: 72px; height: 72px; background: rgba(255,255,255,0.2);
            border-radius: 50%%; display: flex; align-items: center; justify-content: center;
            margin: 0 auto 20px; font-size: 32px; border: 2px solid rgba(255,255,255,0.5);
        }
        .card-body { padding: 20px 40px 40px; text-align: center; color: #4b5563; line-height: 1.7; font-size: 16px; }
        .footer { padding: 24px; text-align: center; font-size: 13px; color: #9ca3af; border-top: 1px solid rgba(0,0,0,0.05); }
    </style>
</head>
<body>
    <div class="card">
        <div class="card-header">
            <div class="icon">✕</div>
            <h1>%s</h1>
        </div>
        <div class="card-body">
            <p>%s</p>
            <p style="margin-top: 24px; color: #9ca3af; font-size: 14px; font-weight: 500;">You may safely close this page.</p>
        </div>
        <div class="footer">
            <p>&copy; 2026 Afya. Secure Access Gateway.</p>
        </div>
    </div>
</body>
</html>`, title, title, message)
}

func renderResetPasswordPage(token, apiBaseURL string) string {
	return fmt.Sprintf(`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Afya - Reset Password</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f0fdf4 0%%, #dcfce7 100%%);
            min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px;
            position: relative; overflow: hidden;
        }
        body::before {
            content: ''; position: absolute; top: -50%%; left: -50%%; width: 200%%; height: 200%%;
            background: radial-gradient(circle, rgba(34,197,94,0.05) 0%%, transparent 60%%);
            animation: pulse 15s ease-in-out infinite alternate; z-index: 0;
        }
        @keyframes pulse { 0%% { transform: scale(1); } 100%% { transform: scale(1.1); } }
        .card {
            max-width: 480px; width: 100%%;
            background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(16px);
            border-radius: 24px; border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 25px 50px -12px rgba(22, 163, 74, 0.15), 0 0 0 1px rgba(255, 255, 255, 0.2);
            overflow: hidden; z-index: 1; position: relative;
        }
        .card-header {
            background: linear-gradient(135deg, #22c55e 0%%, #16a34a 100%%);
            padding: 48px 30px; text-align: center; color: #fff; position: relative;
        }
        .card-header::after {
            content: ''; position: absolute; bottom: -20px; left: 0; right: 0; height: 40px;
            background: rgba(255,255,255,0.95); border-radius: 50%% 50%% 0 0;
        }
        .card-header h1 { font-size: 28px; font-weight: 700; letter-spacing: -0.5px; }
        .card-header p { margin-top: 10px; opacity: 0.9; font-size: 16px; font-weight: 400; }
        .card-body { padding: 20px 40px 40px; color: #374151; }
        .form-group { margin-bottom: 24px; text-align: left; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; font-size: 14px; color: #374151; }
        .form-group input {
            width: 100%%; padding: 14px 16px;
            border: 2px solid #e5e7eb; border-radius: 12px;
            font-size: 16px; font-family: 'Inter', sans-serif;
            transition: all 0.3s ease; outline: none; background: #f9fafb;
        }
        .form-group input:focus { border-color: #22c55e; background: #fff; box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.1); }
        .btn {
            display: inline-flex; align-items: center; justify-content: center;
            width: 100%%; padding: 16px;
            border-radius: 12px; border: none;
            font-weight: 600; font-size: 16px;
            cursor: pointer; color: #fff;
            background: linear-gradient(135deg, #22c55e 0%%, #16a34a 100%%);
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px -1px rgba(34, 197, 94, 0.2), 0 2px 4px -1px rgba(34, 197, 94, 0.1);
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(34, 197, 94, 0.3), 0 4px 6px -2px rgba(34, 197, 94, 0.15);
        }
        .hint { font-size: 13px; color: #6b7280; margin-top: 8px; }
        .footer { padding: 24px; text-align: center; font-size: 13px; color: #9ca3af; border-top: 1px solid rgba(0,0,0,0.05); }
        .password-input-wrapper { position: relative; display: flex; align-items: center; }
        .password-input-wrapper input { width: 100%%; padding-right: 48px; }
        .toggle-password {
            position: absolute;
            right: 16px;
            background: none;
            border: none;
            cursor: pointer;
            color: #9ca3af;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 4px;
            transition: color 0.2s;
        }
        .toggle-password:hover { color: #4b5563; }
        .toggle-password svg { width: 20px; height: 20px; }
    </style>
</head>
<body>
    <div class="card">
        <div class="card-header">
            <h1>Reset Password</h1>
            <p>Secure your Afya account</p>
        </div>
        <div class="card-body">
            <form method="POST" action="%s/api/v1/magic/reset-password">
                <input type="hidden" name="token" value="%s">
                <div class="form-group">
                    <label for="password">New Password</label>
                    <div class="password-input-wrapper">
                        <input type="password" id="password" name="password" placeholder="••••••••" required minlength="8">
                        <button type="button" class="toggle-password" aria-label="Toggle password visibility">
                            <svg class="eye-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                            </svg>
                        </button>
                    </div>
                    <div class="hint">Minimum 8 characters</div>
                </div>
                <div class="form-group">
                    <label for="confirm_password">Confirm Password</label>
                    <div class="password-input-wrapper">
                        <input type="password" id="confirm_password" name="confirm_password" placeholder="••••••••" required minlength="8">
                        <button type="button" class="toggle-password" aria-label="Toggle password visibility">
                            <svg class="eye-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                            </svg>
                        </button>
                    </div>
                </div>
                <button type="submit" class="btn">Update Password</button>
            </form>
        </div>
        <div class="footer">
            <p>&copy; 2026 Afya. Secure Access Gateway.</p>
        </div>
    </div>
    <script>
        document.querySelectorAll('.toggle-password').forEach(button => {
            button.addEventListener('click', function() {
                const input = this.previousElementSibling;
                const icon = this.querySelector('svg');

                if (input.type === 'password') {
                    input.type = 'text';
                    // Eye slash icon
                    icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />';
                } else {
                    input.type = 'password';
                    // Eye icon
                    icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />';
                }
            });
        });
    </script>
</body>
</html>`, apiBaseURL, token)
}

func renderAcceptInvitationPage(token, apiBaseURL string) string {
	return fmt.Sprintf(`<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Afya - Accept Invitation</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #f0fdf4 0%%, #dcfce7 100%%);
            min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 20px;
            position: relative; overflow: hidden;
        }
        body::before {
            content: ''; position: absolute; top: -50%%; left: -50%%; width: 200%%; height: 200%%;
            background: radial-gradient(circle, rgba(34,197,94,0.05) 0%%, transparent 60%%);
            animation: pulse 15s ease-in-out infinite alternate; z-index: 0;
        }
        @keyframes pulse { 0%% { transform: scale(1); } 100%% { transform: scale(1.1); } }
        .card {
            max-width: 540px; width: 100%%;
            background: rgba(255, 255, 255, 0.95); backdrop-filter: blur(16px);
            border-radius: 24px; border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 25px 50px -12px rgba(22, 163, 74, 0.15), 0 0 0 1px rgba(255, 255, 255, 0.2);
            overflow: hidden; z-index: 1; position: relative;
        }
        .card-header {
            background: linear-gradient(135deg, #22c55e 0%%, #16a34a 100%%);
            padding: 48px 30px; text-align: center; color: #fff; position: relative;
        }
        .card-header::after {
            content: ''; position: absolute; bottom: -20px; left: 0; right: 0; height: 40px;
            background: rgba(255,255,255,0.95); border-radius: 50%% 50%% 0 0;
        }
        .card-header h1 { font-size: 28px; font-weight: 700; letter-spacing: -0.5px; }
        .card-header p { margin-top: 10px; opacity: 0.9; font-size: 16px; font-weight: 400; }
        .card-body { padding: 20px 40px 40px; color: #374151; }
        .form-group { margin-bottom: 20px; text-align: left; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; font-size: 14px; color: #374151; }
        .form-group input {
            width: 100%%; padding: 14px 16px;
            border: 2px solid #e5e7eb; border-radius: 12px;
            font-size: 16px; font-family: 'Inter', sans-serif;
            transition: all 0.3s ease; outline: none; background: #f9fafb;
        }
        .form-group input:focus { border-color: #22c55e; background: #fff; box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.1); }
        .form-row { display: flex; gap: 16px; }
        .form-row .form-group { flex: 1; margin-bottom: 20px; }
        .btn {
            display: inline-flex; align-items: center; justify-content: center;
            width: 100%%; padding: 16px; margin-top: 10px;
            border-radius: 12px; border: none;
            font-weight: 600; font-size: 16px;
            cursor: pointer; color: #fff;
            background: linear-gradient(135deg, #22c55e 0%%, #16a34a 100%%);
            transition: all 0.3s ease;
            box-shadow: 0 4px 6px -1px rgba(34, 197, 94, 0.2), 0 2px 4px -1px rgba(34, 197, 94, 0.1);
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(34, 197, 94, 0.3), 0 4px 6px -2px rgba(34, 197, 94, 0.15);
        }
        .hint { font-size: 13px; color: #6b7280; margin-top: 8px; }
        .footer { padding: 24px; text-align: center; font-size: 13px; color: #9ca3af; border-top: 1px solid rgba(0,0,0,0.05); }
        .password-input-wrapper { position: relative; display: flex; align-items: center; }
        .password-input-wrapper input { width: 100%%; padding-right: 48px; }
        .toggle-password {
            position: absolute;
            right: 16px;
            background: none;
            border: none;
            cursor: pointer;
            color: #9ca3af;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 4px;
            transition: color 0.2s;
        }
        .toggle-password:hover { color: #4b5563; }
        .toggle-password svg { width: 20px; height: 20px; }

        #result { display: none; }
        #form-container { display: block; }
        .success-card { text-align: center; padding: 20px 0; }
        .success-card .checkmark {
            width: 72px; height: 72px; background: rgba(34,197,94,0.1);
            border-radius: 50%%; display: flex; align-items: center; justify-content: center;
            margin: 0 auto 20px; font-size: 32px; color: #22c55e; border: 2px solid rgba(34,197,94,0.2);
        }
        .success-card h2 { color: #111827; margin-bottom: 16px; font-size: 24px; }
        .success-card p { color: #4b5563; line-height: 1.7; font-size: 16px; }
        .error-msg {
            background-color: #fef2f2; border-left: 4px solid #ef4444;
            padding: 16px; border-radius: 8px; margin-bottom: 24px;
            color: #991b1b; font-size: 14px; font-weight: 500; display: none;
        }
    </style>
</head>
<body>
    <div class="card">
        <div class="card-header">
            <h1>Welcome to Afya</h1>
            <p>Complete your profile to get started</p>
        </div>
        <div id="form-container" class="card-body">
            <div id="error-msg" class="error-msg"></div>
            <form id="invitation-form" onsubmit="return submitForm(event)">
                <div class="form-row">
                    <div class="form-group">
                        <label for="first_name">First Name</label>
                        <input type="text" id="first_name" name="first_name" placeholder="John" required>
                    </div>
                    <div class="form-group">
                        <label for="last_name">Last Name</label>
                        <input type="text" id="last_name" name="last_name" placeholder="Doe" required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="phone">Phone Number</label>
                    <input type="tel" id="phone" name="phone" placeholder="+251912345678" required>
                </div>
                <div class="form-group">
                    <label for="specialization">Specialization</label>
                    <input type="text" id="specialization" name="specialization" placeholder="e.g. Psychiatry" required>
                </div>
                <div class="form-group">
                    <label for="license_number">License Number</label>
                    <input type="text" id="license_number" name="license_number" placeholder="e.g. MED-12345" required>
                </div>
                <div class="form-group">
                    <label for="password">Create Password</label>
                    <div class="password-input-wrapper">
                        <input type="password" id="password" name="password" placeholder="••••••••" required minlength="8">
                        <button type="button" class="toggle-password" aria-label="Toggle password visibility">
                            <svg class="eye-icon" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                            </svg>
                        </button>
                    </div>
                    <div class="hint">Minimum 8 characters</div>
                </div>
                <button type="submit" class="btn" id="submit-btn">Complete Registration</button>
            </form>
        </div>
        <div id="result" class="card-body success-card">
            <div class="checkmark">✓</div>
            <h2>Registration Complete!</h2>
            <p>Your doctor profile has been created successfully. You can now log in to the Afya platform.</p>
            <p style="margin-top: 24px; color: #9ca3af; font-size: 14px; font-weight: 500;">You may safely close this page.</p>
        </div>
        <div class="footer">
            <p>&copy; 2026 Afya. Secure Access Gateway.</p>
        </div>
    </div>
    <script>
        document.querySelectorAll('.toggle-password').forEach(button => {
            button.addEventListener('click', function() {
                const input = this.previousElementSibling;
                const icon = this.querySelector('svg');

                if (input.type === 'password') {
                    input.type = 'text';
                    // Eye slash icon
                    icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.88 9.88l-3.29-3.29m7.532 7.532l3.29 3.29M3 3l3.59 3.59m0 0A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.543 7a10.025 10.025 0 01-4.132 5.411m0 0L21 21" />';
                } else {
                    input.type = 'password';
                    // Eye icon
                    icon.innerHTML = '<path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />';
                }
            });
        });

        async function submitForm(e) {
            e.preventDefault();
            const btn = document.getElementById('submit-btn');
            const errorDiv = document.getElementById('error-msg');
            errorDiv.style.display = 'none';
            btn.disabled = true;
            btn.textContent = 'Submitting...';

            const payload = {
                first_name: document.getElementById('first_name').value,
                last_name: document.getElementById('last_name').value,
                phone: document.getElementById('phone').value,
                password: document.getElementById('password').value,
                specialization: document.getElementById('specialization').value,
                license_number: document.getElementById('license_number').value
            };

            try {
                const res = await fetch('%s/api/v1/invitations/%s/accept', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify(payload)
                });

                if (!res.ok) {
                    const data = await res.json();
                    throw new Error(data.error?.message || 'Registration failed. Please try again.');
                }

                document.getElementById('form-container').style.display = 'none';
                document.getElementById('result').style.display = 'block';
            } catch (err) {
                errorDiv.textContent = err.message;
                errorDiv.style.display = 'block';
                btn.disabled = false;
                btn.textContent = 'Complete Registration';
            }
            return false;
        }
    </script>
</body>
</html>`, apiBaseURL, token)
}
