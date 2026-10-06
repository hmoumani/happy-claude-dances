# Inception-of-Context — root Makefile.
#
# Daily dev loop:
#     make dev-infra      # start Neo4j in Docker
#     make dev            # run the Go service on the host with hot reload
#     make dev-stop       # stop Neo4j
#
# Evaluator / full-stack:
#     make up             # docker compose up --build -d
#     make down           # docker compose down
#     make logs           # tail everything
#
# Housekeeping:
#     make build test fmt vet clean

SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

GO            ?= go
BIN_DIR       := bin
BINARY        := $(BIN_DIR)/ioc
PKG           := ./p1/...
MAIN_PKG      := ./p1/cmd/ioc
COMPOSE       := docker compose
AIR           ?= $(shell command -v air 2>/dev/null)

# Load .env if present so dev targets see NEO4J_PASSWORD etc. without exporting
# them in every shell. Compose reads .env on its own.
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

## help: list targets
.PHONY: help
help:
	@awk 'BEGIN{FS=":.*##"; printf "Targets:\n"} /^[a-zA-Z0-9_.-]+:.*##/ {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

## dev-infra: start supporting infra (Neo4j) in Docker
.PHONY: dev-infra
dev-infra:
	$(COMPOSE) up -d neo4j
	@echo "Neo4j Browser: http://localhost:7474  (bolt://localhost:7687)"

## dev: run the Go service on the host with hot reload (Air if available, else go run)
.PHONY: dev
dev:
ifeq ($(AIR),)
	@echo "air not found — falling back to 'go run'. Install with: go install github.com/air-verse/air@latest"
	$(GO) run $(MAIN_PKG)
else
	$(AIR)
endif

## dev-stop: stop supporting infra
.PHONY: dev-stop
dev-stop:
	$(COMPOSE) stop neo4j

## build: compile the Go binary into ./bin
.PHONY: build
build:
	@mkdir -p $(BIN_DIR)
	CGO_ENABLED=0 $(GO) build -trimpath -ldflags="-s -w" -o $(BINARY) $(MAIN_PKG)
	@echo "built $(BINARY)"

## test: run the Go test suite
.PHONY: test
test:
	$(GO) test $(PKG)

## fmt: gofmt the tree
.PHONY: fmt
fmt:
	$(GO) fmt $(PKG)

## vet: static analysis
.PHONY: vet
vet:
	$(GO) vet $(PKG)

## up: start the full stack via docker compose (evaluator workflow)
.PHONY: up
up:
	$(COMPOSE) up --build -d
	@echo "App:          http://localhost:8080/healthz"
	@echo "Neo4j Browser: http://localhost:7474"

## down: stop the full stack
.PHONY: down
down:
	$(COMPOSE) down

## logs: tail compose logs
.PHONY: logs
logs:
	$(COMPOSE) logs -f --tail=200

## install-hooks: install the pre-commit framework hooks (see .pre-commit-config.yaml)
.PHONY: install-hooks
install-hooks:
	@command -v pre-commit >/dev/null 2>&1 || { \
	  echo "pre-commit not found. Install one of:"; \
	  echo "  pipx install pre-commit    # recommended"; \
	  echo "  brew install pre-commit"; \
	  echo "  pip install --user pre-commit"; \
	  exit 1; }
	pre-commit install
	@echo "hooks installed — run 'pre-commit run --all-files' to try them now."

## hooks-run: run all pre-commit hooks against every file
.PHONY: hooks-run
hooks-run:
	pre-commit run --all-files

## clean: remove local build artefacts (does not touch Docker volumes)
.PHONY: clean
clean:
	rm -rf $(BIN_DIR) tmp build-errors.log

## nuke: like clean, plus docker volumes (destroys Neo4j data)
.PHONY: nuke
nuke: clean
	$(COMPOSE) down -v
