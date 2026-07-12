package config

import "testing"

func TestLoadDefaults(t *testing.T) {
	cfg, err := load(func(string) (string, bool) { return "", false })
	if err != nil {
		t.Fatalf("load defaults: %v", err)
	}
	if cfg.Port != "8080" || cfg.Environment != "development" {
		t.Fatalf("unexpected defaults: %#v", cfg)
	}
}

func TestProductionRequiresFirestoreProject(t *testing.T) {
	values := map[string]string{"APP_ENV": "production"}
	_, err := load(func(key string) (string, bool) { value, ok := values[key]; return value, ok })
	if err == nil {
		t.Fatal("expected production validation error")
	}
}

func TestRejectsInvalidPort(t *testing.T) {
	values := map[string]string{"PORT": "localhost:8080"}
	_, err := load(func(key string) (string, bool) { value, ok := values[key]; return value, ok })
	if err == nil {
		t.Fatal("expected port validation error")
	}
}
