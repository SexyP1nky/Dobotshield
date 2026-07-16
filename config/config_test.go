package config

import "testing"

func TestLoadReadsEveryAdminConfigEnvironmentVariable(t *testing.T) {
	t.Setenv("TARGET_URL", "https://backend.example:9443")
	t.Setenv("PROXY_PORT", "127.0.0.1:8443")
	t.Setenv("HTTP_MODE", "true")
	t.Setenv("ENABLE_WAF", "true")
	t.Setenv("WAF_MODE", "monitor")
	t.Setenv("ENABLE_RESPONSE_INSPECTION", "false")
	t.Setenv("ENABLE_RATE_LIMIT", "false")
	t.Setenv("RATE_LIMIT", "12.5")
	t.Setenv("BURST_LIMIT", "25")
	t.Setenv("MAX_CONNS", "15")
	t.Setenv("MAX_TRACKED_IPS", "750")
	t.Setenv("MAX_BODY_SIZE", "2097152")
	t.Setenv("RESPONSE_INSPECTION_LIMIT", "524288")
	t.Setenv("CERT_FILE", "tls/cert.pem")
	t.Setenv("KEY_FILE", "tls/key.pem")
	t.Setenv("TRUSTED_PROXIES", "192.0.2.10,2001:db8::1")
	t.Setenv("INSECURE_SKIP_VERIFY", "true")
	t.Setenv("CONTENT_SECURITY_POLICY", "default-src 'self'")
	t.Setenv("WAF_ALLOWLIST", "SQLi:/search")
	t.Setenv("BLOCKED_IPS", "198.51.100.10,203.0.113.0/24")
	t.Setenv("RATE_LIMIT_STATE_FILE", "state/rate.json")
	t.Setenv("TRAINING_MODE", "false")
	t.Setenv("TRAINING_LOG_FILE", "audit/events.jsonl")

	cfg := Load()
	if cfg.TargetURL != "https://backend.example:9443" || cfg.ProxyPort != "127.0.0.1:8443" || !cfg.HTTPMode {
		t.Fatalf("target/proxy not loaded: %+v", cfg)
	}
	if !cfg.EnableSanitizer || cfg.WAFMode != "monitor" || cfg.EnableResponseInspection || cfg.EnableRateLimit {
		t.Fatalf("WAF toggles not loaded: %+v", cfg)
	}
	if cfg.RateLimit != 12.5 || cfg.BurstLimit != 25 || cfg.MaxConnsPerIP != 15 || cfg.MaxTrackedIPs != 750 {
		t.Fatalf("limits not loaded: %+v", cfg)
	}
	if cfg.MaxBodySize != 2097152 || cfg.ResponseInspectionLimit != 524288 {
		t.Fatalf("inspection sizes not loaded: %+v", cfg)
	}
	if cfg.CertFile != "tls/cert.pem" || cfg.KeyFile != "tls/key.pem" || !cfg.InsecureSkipVerify {
		t.Fatalf("TLS options not loaded: %+v", cfg)
	}
	if len(cfg.TrustedProxies) != 2 || cfg.TrustedProxies[1] != "2001:db8::1" {
		t.Fatalf("trusted proxies not loaded: %#v", cfg.TrustedProxies)
	}
	if cfg.ContentSecurityPolicy != "default-src 'self'" || len(cfg.WAFAllowlist) != 1 {
		t.Fatalf("WAF policy options not loaded: %+v", cfg)
	}
	if len(cfg.BlockedIPs) != 2 || cfg.BlockedIPs[1] != "203.0.113.0/24" {
		t.Fatalf("blocked IPs not loaded: %#v", cfg.BlockedIPs)
	}
	if cfg.RateLimitStateFile != "state/rate.json" || cfg.TrainingMode || cfg.TrainingLogFile != "audit/events.jsonl" {
		t.Fatalf("state/training options not loaded: %+v", cfg)
	}
}

func TestLoadReadsSecurityTogglesFromEnv(t *testing.T) {
	t.Setenv("ENABLE_WAF", "false")
	t.Setenv("ENABLE_RATE_LIMIT", "off")
	t.Setenv("MAX_BODY_SIZE", "2097152")
	t.Setenv("CONTENT_SECURITY_POLICY", "default-src 'self'")
	t.Setenv("INSECURE_SKIP_VERIFY", "true")
	t.Setenv("WAF_MODE", "monitor")
	t.Setenv("ENABLE_RESPONSE_INSPECTION", "false")
	t.Setenv("RESPONSE_INSPECTION_LIMIT", "524288")
	t.Setenv("MAX_TRACKED_IPS", "500")
	t.Setenv("WAF_ALLOWLIST", "SQLi:/api/search,XSS:/content-editor,/health")
	t.Setenv("RATE_LIMIT_STATE_FILE", "state/ratelimit.json")

	cfg := Load()

	if cfg.EnableSanitizer {
		t.Fatalf("expected ENABLE_WAF=false to disable sanitizer")
	}
	if cfg.EnableRateLimit {
		t.Fatalf("expected ENABLE_RATE_LIMIT=off to disable rate limit")
	}
	if cfg.MaxBodySize != 2097152 {
		t.Fatalf("expected MAX_BODY_SIZE to be read, got %d", cfg.MaxBodySize)
	}
	if cfg.ContentSecurityPolicy != "default-src 'self'" {
		t.Fatalf("expected CONTENT_SECURITY_POLICY to be read")
	}
	if !cfg.InsecureSkipVerify {
		t.Fatalf("expected INSECURE_SKIP_VERIFY=true to be read")
	}
	if cfg.WAFMode != "monitor" {
		t.Fatalf("expected WAF_MODE=monitor, got %q", cfg.WAFMode)
	}
	if cfg.EnableResponseInspection {
		t.Fatalf("expected ENABLE_RESPONSE_INSPECTION=false to be read")
	}
	if cfg.ResponseInspectionLimit != 524288 {
		t.Fatalf("expected RESPONSE_INSPECTION_LIMIT to be read, got %d", cfg.ResponseInspectionLimit)
	}
	if cfg.MaxTrackedIPs != 500 {
		t.Fatalf("expected MAX_TRACKED_IPS to be read, got %d", cfg.MaxTrackedIPs)
	}
	if cfg.RateLimitStateFile != "state/ratelimit.json" {
		t.Fatalf("expected RATE_LIMIT_STATE_FILE to be read")
	}
	if !IsWAFAllowed(cfg.WAFAllowlist, "SQLi in Query", "/api/search") {
		t.Fatalf("expected SQLi allowlist rule to match /api/search")
	}
	if !IsWAFAllowed(cfg.WAFAllowlist, "XSS in Body", "/content-editor/post") {
		t.Fatalf("expected XSS allowlist rule to match /content-editor/post")
	}
	if !IsWAFAllowed(cfg.WAFAllowlist, "CMD_INJ in Query", "/health") {
		t.Fatalf("expected catch-all allowlist rule to match /health")
	}
	if IsWAFAllowed(cfg.WAFAllowlist, "XSS in Query", "/api/search") {
		t.Fatalf("did not expect XSS to match SQLi-only allowlist rule")
	}
}

func TestLoadReadsTrainingDefaults(t *testing.T) {
	cfg := Load()

	if !cfg.TrainingMode {
		t.Fatalf("expected TRAINING_MODE to default to true")
	}
	if cfg.TrainingLogFile != "logs/training.jsonl" {
		t.Fatalf("expected default training log file, got %q", cfg.TrainingLogFile)
	}
	if !cfg.TrainingEnabled() {
		t.Fatalf("expected training to be enabled by default")
	}
}

func TestLoadReadsTrainingOverrides(t *testing.T) {
	t.Setenv("TRAINING_MODE", "false")
	t.Setenv("TRAINING_LOG_FILE", "data/attacks.jsonl")

	cfg := Load()

	if cfg.TrainingMode {
		t.Fatalf("expected TRAINING_MODE=false to disable training mode")
	}
	if cfg.TrainingLogFile != "data/attacks.jsonl" {
		t.Fatalf("expected TRAINING_LOG_FILE override, got %q", cfg.TrainingLogFile)
	}
	if cfg.TrainingEnabled() {
		t.Fatalf("expected training disabled when TrainingMode is false")
	}
}

func TestLoadFallsBackForInvalidNumbers(t *testing.T) {
	t.Setenv("RATE_LIMIT", "0")
	t.Setenv("BURST_LIMIT", "-1")
	t.Setenv("MAX_CONNS", "not-a-number")
	t.Setenv("MAX_BODY_SIZE", "-100")

	cfg := Load()

	if cfg.RateLimit != 10.0 {
		t.Fatalf("expected default rate limit, got %f", cfg.RateLimit)
	}
	if cfg.BurstLimit != 20 {
		t.Fatalf("expected default burst limit, got %d", cfg.BurstLimit)
	}
	if cfg.MaxConnsPerIP != 10 {
		t.Fatalf("expected default max connections, got %d", cfg.MaxConnsPerIP)
	}
	if cfg.MaxBodySize != 1024*1024 {
		t.Fatalf("expected default body size, got %d", cfg.MaxBodySize)
	}
}

func TestResponseInspectionRequiresWAFAndResponseToggle(t *testing.T) {
	tests := []struct {
		name string
		cfg  Config
		want bool
	}{
		{name: "enabled", cfg: Config{EnableSanitizer: true, EnableResponseInspection: true, WAFMode: "block"}, want: true},
		{name: "waf disabled", cfg: Config{EnableSanitizer: false, EnableResponseInspection: true, WAFMode: "block"}, want: false},
		{name: "response disabled", cfg: Config{EnableSanitizer: true, EnableResponseInspection: false, WAFMode: "block"}, want: false},
		{name: "mode off", cfg: Config{EnableSanitizer: true, EnableResponseInspection: true, WAFMode: "off"}, want: false},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			if got := test.cfg.ResponseWAFEnabled(); got != test.want {
				t.Fatalf("ResponseWAFEnabled() = %v, want %v", got, test.want)
			}
		})
	}
}
