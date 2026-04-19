# 🌿 Iris Physical Therapy Assistant — Backend

An intelligent, AI-powered physical therapy backend designed to actively monitor, assist, and correct patient movements during guided exercises.

---

## ✨ Overview

This backend is a pure Python service built on Google's **MediaPipe Tasks Vision API** for high-performance, real-time skeletal tracking. It captures a live camera feed and maps **33 human body landmarks** (shoulders, elbows, joints, etc.) with high accuracy and low latency, running natively on CPU.

---

## 🚀 Getting Started

Dependencies are managed with [`uv`](https://github.com/astral-sh/uv). To launch the live tracking feed:

```bash
cd backend
uv sync
uv run python -m src.main
```

Press **`q`** on the camera window at any time to exit and view your session's performance metrics.

### CLI Flags

| Flag | Type | Default | Description |
|------|------|---------|-------------|
| `--source` | `int` | `0` | Camera device index (`0` = built-in webcam) |
| `--model-complexity` | `int` | `1` | MediaPipe model: `0` lite, `1` full, `2` heavy |
| `--detection-confidence` | `float` | `0.5` | Min confidence to initially detect a person (0.0–1.0) |
| `--tracking-confidence` | `float` | `0.5` | Min confidence to maintain tracking across frames (0.0–1.0) |

**Example** — run with an external camera using the fastest model:

```bash
uv run python -m src.main [flags]
---

## 🏗️ Directory Architecture

The project enforces **separation of concerns** to keep the codebase clean and modular.

```
backend/
├── schemas/    # Data contracts
├── services/   # Core logic & engines
├── utils/      # Shared helpers
└── ...
```

### `schemas/`

Pydantic models defining strict data contracts (e.g., `PoseFrame`, `Landmark`). Files are split by domain — in a project with both a stock API and a weather API, you'd have `stock.py` and `weather.py`.

### `services/`

Specialized components containing core business logic, background tasks, or functional utilities (e.g., the `BodyTracker` engine). Organized by task domain, mirroring the schema structure.

### `utils/`

Generic, reusable helper functions that aren't tied to a specific service — mathematical transformations, video source validations (`video_utils.py`), string parsing, and similar pure functions that would otherwise clutter the services layer.