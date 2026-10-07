# demo target

Tiny target project the indexer will walk, chunk, embed and watch.

Kept intentionally small — a few cooperating files, one class, a handful of
methods — so the chunker, retriever and (later) patch loop each have
something real to land on without burying a 3B model in context.

Grow it later if a specific feature needs more surface area; do not grow it
preemptively.
