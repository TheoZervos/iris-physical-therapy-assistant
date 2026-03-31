"""Iris Body Tracking — Entry Point.

Launches the live body pose tracking system using the device camera.
"""

import argparse
import sys

from src.services.body_tracking import BodyTracker


def main() -> None:
    """Parse arguments and start the body tracker."""
    parser = argparse.ArgumentParser(
        description="Iris Body Tracking — Real-time pose detection",
    )
    parser.add_argument(
        "--source",
        type=int,
        default=0,
        help="Camera device index (default: 0)",
    )
    parser.add_argument(
        "--detection-confidence",
        type=float,
        default=0.5,
        help="Minimum detection confidence (0.0-1.0, default: 0.5)",
    )
    parser.add_argument(
        "--tracking-confidence",
        type=float,
        default=0.5,
        help="Minimum tracking confidence (0.0-1.0, default: 0.5)",
    )
    parser.add_argument(
        "--model-complexity",
        type=int,
        choices=[0, 1, 2],
        default=1,
        help="Model complexity: 0=lite, 1=full, 2=heavy (default: 1)",
    )

    args = parser.parse_args()

    try:
        tracker = BodyTracker(
            camera_index=args.source,
            min_detection_confidence=args.detection_confidence,
            min_tracking_confidence=args.tracking_confidence,
            model_complexity=args.model_complexity,
        )
        summary = tracker.run_with_display()

        print("\n--- Session Summary ---")
        print(f"  Total Frames:  {summary['total_frames']}")
        print(f"  Duration:      {summary['duration_seconds']}s")
        print(f"  Average FPS:   {summary['avg_fps']}")
        print("----------------------\n")

    except RuntimeError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()