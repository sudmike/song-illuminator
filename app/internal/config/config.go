package config

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

const defaultPort = "8080"

type Config struct {
	Environment        string
	Port               string
	FirestoreProjectID string
	StaticDir          string
}

func Load() (Config, error) {
	return load(os.LookupEnv)
}

func load(lookup func(string) (string, bool)) (Config, error) {
	cfg := Config{
		Environment:        valueOrDefault(lookup, "APP_ENV", "development"),
		Port:               valueOrDefault(lookup, "PORT", defaultPort),
		FirestoreProjectID: valueOrDefault(lookup, "FIRESTORE_PROJECT_ID", ""),
		StaticDir:          valueOrDefault(lookup, "STATIC_DIR", "frontend/dist"),
	}

	port, err := strconv.Atoi(cfg.Port)
	if err != nil || port < 1 || port > 65535 {
		return Config{}, fmt.Errorf("PORT must be a number between 1 and 65535")
	}
	if cfg.Environment == "production" && cfg.FirestoreProjectID == "" {
		return Config{}, fmt.Errorf("FIRESTORE_PROJECT_ID is required in production")
	}

	return cfg, nil
}

func valueOrDefault(lookup func(string) (string, bool), key, fallback string) string {
	if value, ok := lookup(key); ok {
		return strings.TrimSpace(value)
	}
	return fallback
}
