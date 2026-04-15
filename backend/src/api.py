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

from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse

from src.services.dummy_data import DummyDataGenerator

# ── App setup ───────────────────────────────────────────────────

app = FastAPI(
    title="Iris Physical Therapy Assistant",
    description="Real-time body tracking and exercise correction API",
    version="0.1.0",
)

# Allow the Flutter web frontend (and any local dev origins) to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # tighten in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routes ──────────────────────────────────────────────────────


@app.get("/", tags=["health"])
async def health_check():
    """Basic liveness probe."""
    return {"status": "ok", "service": "iris-backend"}


@app.get("/api/tracking/snapshot", tags=["tracking"])
async def tracking_snapshot():
    """Return a single ``TrackingFrame`` (useful for polling).

    Always uses dummy data for now; will switch to the live
    ``BodyTracker`` pipeline once the CV model is integrated.
    """
    gen = DummyDataGenerator()
    frame = gen.next_frame()
    return frame.model_dump()


@app.get("/api/tracking/stream", tags=["tracking"])
async def tracking_stream(
    source: str = Query(
        default="dummy",
        description="Data source: 'dummy' for simulated data, 'live' for camera feed",
        pattern="^(dummy|live)$",
    ),
    fps: float = Query(
        default=30.0,
        description="Target frames per second for the stream",
        gt=0,
        le=120,
    ),
):
    """Stream ``TrackingFrame`` objects as Server-Sent Events (SSE).

    Each event is a JSON-encoded ``TrackingFrame``.  The stream runs
    indefinitely until the client disconnects.

    Query params:
        source: ``dummy`` (default) or ``live``.
        fps: Target frame rate for the stream (default 30).
    """

    async def _event_generator():
        if source == "live":
            # TODO: wire up BodyTracker.process_stream() here once
            #       the camera pipeline is ready for headless use.
            #       For now, fall back to dummy data.
            gen = DummyDataGenerator(fps=fps)
        else:
            gen = DummyDataGenerator(fps=fps)

        interval = 1.0 / fps

        while True:
            frame = gen.next_frame()
            payload = json.dumps(frame.model_dump())
            yield f"data: {payload}\n\n"
            await asyncio.sleep(interval)

    return StreamingResponse(
        _event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",  # disable nginx buffering if proxied
        },
    )
