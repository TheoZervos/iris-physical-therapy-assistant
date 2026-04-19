"""FastAPI application for the Iris Physical Therapy Assistant backend.

Provides HTTP + SSE endpoints so the Flutter frontend can receive
real-time tracking data (joint angles, exercise corrections) as a
stream of JSON objects.

Run with::

    cd backend
    uv run uvicorn src.api:app --reload
"""

import asyncio
import json
from typing import Optional

from fastapi import FastAPI, Query
from fastapi.responses import StreamingResponse

from src.schemas.exercise_schema import ExerciseTrackingFrame
from src.services.body_tracking import BodyTracker

# ── App setup ───────────────────────────────────────────────────

app = FastAPI(
    title="Iris Physical Therapy Assistant",
    description="Real-time body tracking and exercise correction API",
    version="0.1.0",
)

# ── Routes ──────────────────────────────────────────────────────
@app.get("/", tags=["health"])
async def health_check():
    """Basic liveness probe."""
    return {"status": "ok", "service": "iris-backend"}

@app.get("/track_exercise", tags=["tracking"])
async def track_exercise(
    exercise_id: str,
    camera_index: Optional[int] = 1,
    min_detection_conf: Optional[float] = 0.8,
    min_tracking_conf: Optional[float] = 0.8,
):
    """Stream ``TrackingFrame`` objects as Server-Sent Events (SSE).

    Each event is a JSON-encoded ``TrackingFrame``.  The stream runs
    indefinitely until the client disconnects.

    Query params:
        source: ``dummy`` (default) or ``live``.
        fps: Target frame rate for the stream (default 30).
    """
    tracker = BodyTracker(
        camera_index=camera_index,
        min_detection_confidence=min_detection_conf,
        min_tracking_confidence=min_tracking_conf
    )

    return StreamingResponse(
        tracker.process_exercise_stream(exercise_id),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",  # disable nginx buffering if proxied
        },
    )
