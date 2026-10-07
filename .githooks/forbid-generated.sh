#!/usr/bin/env bash
# Called by pre-commit (see .pre-commit-config.yaml). Receives staged file
# paths as arguments and refuses the commit if any match a forbidden
# pattern. Keep in sync with .gitignore.

set -euo pipefail

# Prefix match (directories) OR exact match (specific files).
# .env.example is intentionally allowed.
prefix_regex='^(bin/|tmp/|dist/|neo4j-data/|data/|\.cache/|models/|embeddings/|chroma/|__pycache__/|\.mypy_cache/|\.ruff_cache/|\.pytest_cache/)'
exact_regex='^(\.env|\.env\.[^/]+)$'
suffix_regex='\.(exe|test|out|dump|gguf|safetensors|bin|pyc|swp|swo)$'

status=0
for f in "$@"; do
    [ "$f" = ".env.example" ] && continue
    if [[ "$f" =~ $prefix_regex ]] || [[ "$f" =~ $exact_regex ]] || [[ "$f" =~ $suffix_regex ]]; then
        echo "forbidden: $f" >&2
        status=1
    fi
done

if [ "$status" -ne 0 ]; then
    echo "these paths belong in .gitignore, not the repository." >&2
fi
exit "$status"
