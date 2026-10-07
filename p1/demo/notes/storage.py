"""In-memory note storage. Deliberately minimal."""
from __future__ import annotations

from dataclasses import dataclass, field
from itertools import count


@dataclass
class Note:
    id: int
    title: str
    body: str
    tags: list[str] = field(default_factory=list)


class Storage:
    """Append-only, in-memory store keyed by auto-increment id."""

    def __init__(self) -> None:
        self._notes: dict[int, Note] = {}
        self._ids = count(1)

    def add(self, title: str, body: str, tags: list[str] | None = None) -> Note:
        note = Note(id=next(self._ids), title=title, body=body, tags=list(tags or []))
        self._notes[note.id] = note
        return note

    def get(self, note_id: int) -> Note | None:
        return self._notes.get(note_id)

    def list_all(self) -> list[Note]:
        return list(self._notes.values())

    def delete(self, note_id: int) -> bool:
        return self._notes.pop(note_id, None) is not None
