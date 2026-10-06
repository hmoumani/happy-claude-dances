package config

import (
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Mode string

const (
	ModeDev  Mode = "development"
	ModeProd Mode = "production"
)

type Config struct {
	AppEnv        Mode
	HTTPAddr      string
	TargetPath    string
	Neo4jURI      string
	Neo4jUser     string
	Neo4jPassword string
}

func Load() (Config, error) {
	cfg := Config{
		AppEnv:        parseMode(getenv("APP_ENV", "development")),
		HTTPAddr:      getenv("HTTP_ADDR", ":8080"),
		TargetPath:    getenv("TARGET_PATH", "./p1/demo"),
		Neo4jURI:      getenv("NEO4J_URI", "bolt://localhost:7687"),
		Neo4jUser:     getenv("NEO4J_USER", "neo4j"),
		Neo4jPassword: os.Getenv("NEO4J_PASSWORD"),
	}
	if strings.TrimSpace(cfg.Neo4jPassword) == "" {
		return cfg, fmt.Errorf("NEO4J_PASSWORD is required")
	}
	return cfg, nil
}

func getenv(key, fallback string) string {
	if v, ok := os.LookupEnv(key); ok && v != "" {
		return v
	}
	return fallback
}

func parseMode(v string) Mode {
	switch strings.ToLower(v) {
	case "prod", "production":
		return ModeProd
	default:
		return ModeDev
	}
}

// GetenvInt is a small helper kept here so future config values (timeouts,
// batch sizes, poll intervals) can land without pulling a config library.
func GetenvInt(key string, fallback int) int {
	v, ok := os.LookupEnv(key)
	if !ok || v == "" {
		return fallback
	}
	n, err := strconv.Atoi(v)
	if err != nil {
		return fallback
	}
	return n
}
