"""Entry point for the demo notes app."""
from __future__ import annotations

from notes import NoteService


def seed(service: NoteService) -> None:
    service.create("first", "hello world", tags=["intro"])
    service.create("second", "a note about indexing", tags=["ioc", "demo"])


def main() -> int:
    service = NoteService()
    seed(service)
    for note in service.storage.list_all():
        print(f"{note.id:>3} {note.title!r} tags={note.tags}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
