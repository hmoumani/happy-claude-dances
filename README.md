# Inception-of-Context (IoC)

A local-first codebase assistant: index a target project, answer questions
about it, and generate/apply/validate patches with automatic rollback.

This repository is split into three parts, as the subject requires:

| Folder | Scope | Status |
| ------ | ----- | ------ |
| `p1/`  | Indexer, filesystem watcher, storage integration, config | **infrastructure only** — Part 1 business logic not implemented yet |
| `p2/`  | Architect HTTP API + RAG | reserved |
| `p3/`  | Patch generation, atomic apply, validation loop with rollback | reserved |

Only Part 1 infrastructure (Go service skeleton, Neo4j, dev workflow, Docker
build, Makefile) is wired up at this stage. Parser, chunker, embedder and
watcher logic are the next engineer's job.

## Prerequisites

- Go **1.24+**
- Docker Desktop / Docker Engine with the Compose v2 plugin
- GNU Make
- Optional: [`air`](https://github.com/air-verse/air) for hot reload
  ```sh
  go install github.com/air-verse/air@latest
  ```
  `make dev` falls back to `go run` if `air` is not on `$PATH`.
- Optional: [`pre-commit`](https://pre-commit.com/) for the git hooks
  ```sh
  pipx install pre-commit   # or: brew install pre-commit
  ```

## First-time setup

```sh
cp .env.example .env
# edit .env — at minimum, set a NEO4J_PASSWORD
make install-hooks      # enables the tracked pre-commit hook
make dev-infra          # start Neo4j in Docker
make dev                # run the Go service on the host, hot reload
```

Git hooks are managed by the [pre-commit](https://pre-commit.com/)
framework (`.pre-commit-config.yaml`). On install they run on every
commit:

| Hook | Source | What it does |
| --- | --- | --- |
| `go-fmt` | tekwizely/pre-commit-golang | reject unformatted Go code |
| `go-vet-mod` | tekwizely/pre-commit-golang | `go vet ./...` |
| `go-test-mod` | tekwizely/pre-commit-golang | `go test ./...` |
| `go-build-mod` | tekwizely/pre-commit-golang | `go build ./...` |
| `check-added-large-files`, `check-merge-conflict`, `check-yaml`, `end-of-file-fixer`, `trailing-whitespace`, `mixed-line-ending`, `forbid-new-submodules`, `detect-private-key` | pre-commit/pre-commit-hooks | general hygiene |
| `forbid-generated-paths` | local (`.githooks/forbid-generated.sh`) | refuse to stage `.env`, binaries, temp files, or generated Neo4j/model/vector-store data |

Run across the whole tree at any time:

```sh
make hooks-run        # pre-commit run --all-files
```

Bypass with `git commit --no-verify` only when you really know why.

Verify:

```sh
curl -s http://localhost:8080/healthz
# {"status":"ok"}
```

## Daily development workflow

The service runs **directly on the host** so a Go edit doesn't need a Docker
rebuild. Only Neo4j runs in a container.

```sh
make dev-infra          # (once per session) start Neo4j
make dev                # recompiles + restarts on every .go save
# ... edit code ...
make dev-stop           # stop Neo4j when done
```

Useful side targets:

```sh
make build              # produce ./bin/ioc
make test               # go test ./p1/...
make fmt vet            # gofmt + go vet
```

## Docker / evaluator workflow

For a peer evaluating the project, the full stack comes up with one command:

```sh
make up                 # docker compose up --build -d
make logs               # tail everything
make down               # stop
make nuke               # stop + delete the Neo4j volume
```

`make up` builds a multi-stage image for the Go service and starts both the
service and Neo4j. The service connects to Neo4j over the Compose network
(`bolt://neo4j:7687`); on the host dev workflow it uses
`bolt://localhost:7687` instead. Both are driven by the `NEO4J_URI`
environment variable — the Compose file sets the container-side value, your
local `.env` sets the host-side value.

## Neo4j Browser

Once Neo4j is running (either `make dev-infra` or `make up`):

- Browser: <http://localhost:7474>
- Bolt:    `bolt://localhost:7687`
- User / password: whatever you put in `.env`

## Environment variables

| Variable         | Default                   | Notes |
| ---------------- | ------------------------- | ----- |
| `APP_ENV`        | `development`             | `development` or `production` |
| `HTTP_ADDR`      | `:8080`                   | address the health server binds to |
| `TARGET_PATH`    | `./p1/demo`               | path of the target project the indexer will walk |
| `NEO4J_URI`      | `bolt://localhost:7687`   | overridden to `bolt://neo4j:7687` inside Compose |
| `NEO4J_USER`     | `neo4j`                   | |
| `NEO4J_PASSWORD` | *(required)*              | service refuses to start without it |

Loaded from `.env` by both the Makefile (for host dev) and Docker Compose.
`.env.example` lists everything; `.env` itself is git-ignored.

## Project structure

```
.
├── p1/
│   ├── cmd/ioc/        # entrypoint (main.go) — health server only, for now
│   ├── config/         # env-based config loader + tests
│   ├── parser/         # placeholder — logical chunker lives here
│   ├── indexer/        # placeholder — walk / chunk / embed / watch pipeline
│   ├── storage/        # placeholder — Neo4j client wrapper
│   └── demo/           # tiny target codebase the indexer will walk
├── p2/                 # reserved for Part 2 (Architect API + RAG)
├── p3/                 # reserved for Part 3 (patch loop)
├── .air.toml           # hot reload config for `make dev`
├── .env.example
├── docker-compose.yml  # Neo4j + the Go service
├── Dockerfile          # multi-stage build for the Go service
├── Makefile
├── go.mod
└── README.md
```

## What is intentionally **not** implemented yet

- Source parser / logical chunker (Part 1)
- Embedding generation (Part 1)
- Filesystem watcher with incremental reindex (Part 1)
- Neo4j schema / vector index / write path (Part 1)
- Architect HTTP API, retriever, RAG `/ask` (Part 2)
- Local LLM (Ollama) integration — belongs to Part 2/3
- Patch generation, atomic apply, validation loop, rollback (Part 3)
- Dashboard UI

The scaffold compiles, tests pass, and the service exposes `/healthz` so the
Docker stack can be verified end-to-end before any real logic lands.

## Credits

School of 42 — *Inception-of-Context*. Subject in `en.subject.pdf`.
