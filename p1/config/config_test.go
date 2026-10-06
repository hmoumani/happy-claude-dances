package config

import "testing"

func TestLoad_RequiresPassword(t *testing.T) {
	t.Setenv("NEO4J_PASSWORD", "")
	if _, err := Load(); err == nil {
		t.Fatal("expected error when NEO4J_PASSWORD is unset")
	}
}

func TestLoad_Defaults(t *testing.T) {
	t.Setenv("NEO4J_PASSWORD", "secret")
	cfg, err := Load()
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if cfg.AppEnv != ModeDev {
		t.Errorf("AppEnv default: got %q, want %q", cfg.AppEnv, ModeDev)
	}
	if cfg.HTTPAddr != ":8080" {
		t.Errorf("HTTPAddr default: got %q", cfg.HTTPAddr)
	}
	if cfg.Neo4jURI != "bolt://localhost:7687" {
		t.Errorf("Neo4jURI default: got %q", cfg.Neo4jURI)
	}
	if cfg.Neo4jUser != "neo4j" {
		t.Errorf("Neo4jUser default: got %q", cfg.Neo4jUser)
	}
}

func TestParseMode(t *testing.T) {
	cases := map[string]Mode{
		"":            ModeDev,
		"development": ModeDev,
		"dev":         ModeDev,
		"prod":        ModeProd,
		"production":  ModeProd,
		"PRODUCTION":  ModeProd,
	}
	for in, want := range cases {
		if got := parseMode(in); got != want {
			t.Errorf("parseMode(%q) = %q, want %q", in, got, want)
		}
	}
}
