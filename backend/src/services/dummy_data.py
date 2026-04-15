"""Dummy data generator for development and frontend testing.

Produces realistic ``TrackingFrame`` payloads that simulate a patient
performing a bicep curl exercise.  The right elbow cycles smoothly
between 160° (arm extended) and 40° (arm curled) over configurable
periods, and plausible corrections are injected when the simulated
angle deviates from the target.

Usage::

    from src.services.dummy_data import DummyDataGenerator

    gen = DummyDataGenerator()
    for frame in gen.generate_frames(count=120):
        print(frame.model_dump_json())
"""

import math
import time
from typing import Iterator

from src.schemas.tracking_schema import (
    ExerciseCorrection,
    JointAngle,
    TrackingFrame,
)


# ── Default exercise parameters ────────────────────────────────

_DEFAULT_JOINTS: list[dict] = [
    {
        "joint_name": "Right Elbow",
        "base_landmark": "right_shoulder",
        "vertex_landmark": "right_elbow",
        "end_landmark": "right_wrist",
        "amplitude": 60.0,   # half-range of motion in degrees
        "centre": 100.0,     # midpoint angle
        "phase_offset": 0.0, # radians
    },
    {
        "joint_name": "Left Elbow",
        "base_landmark": "left_shoulder",
        "vertex_landmark": "left_elbow",
        "end_landmark": "left_wrist",
        "amplitude": 55.0,
        "centre": 105.0,
        "phase_offset": math.pi,  # opposite phase
    },
    {
        "joint_name": "Right Shoulder",
        "base_landmark": "right_hip",
        "vertex_landmark": "right_shoulder",
        "end_landmark": "right_elbow",
        "amplitude": 10.0,
        "centre": 25.0,
        "phase_offset": 0.0,
    },
    {
        "joint_name": "Right Knee",
        "base_landmark": "right_hip",
        "vertex_landmark": "right_knee",
        "end_landmark": "right_ankle",
        "amplitude": 5.0,
        "centre": 170.0,
        "phase_offset": 0.0,
    },
]

_DEFAULT_TARGETS: dict[str, float] = {
    "Right Elbow": 45.0,   # target curl angle
    "Left Elbow": 50.0,
    "Right Shoulder": 20.0,
    "Right Knee": 175.0,
}


class DummyDataGenerator:
    """Generates simulated ``TrackingFrame`` payloads.

    Each call to :meth:`generate_frames` or :meth:`next_frame`
    produces frames with smoothly varying joint angles that mimic
    a repeating exercise motion.
    """

    def __init__(
        self,
        joints: list[dict] | None = None,
        target_angles: dict[str, float] | None = None,
        cycle_frames: int = 60,
        fps: float = 30.0,
    ) -> None:
        """
        Args:
            joints: Joint configs (see ``_DEFAULT_JOINTS`` for shape).
            target_angles: Target angle per joint for correction generation.
            cycle_frames: Number of frames per full exercise cycle.
            fps: Simulated frames per second.
        """
        self.joints = joints or _DEFAULT_JOINTS
        self.target_angles = target_angles or _DEFAULT_TARGETS
        self.cycle_frames = cycle_frames
        self.fps = fps
        self._frame_counter = 0
        self._start_time = time.time()

    def next_frame(self) -> TrackingFrame:
        """Generate the next ``TrackingFrame`` in the simulation.

        Returns:
            A fully populated ``TrackingFrame``.
        """
        self._frame_counter += 1
        t = self._frame_counter / self.cycle_frames  # normalised time
        timestamp_ms = (time.time() - self._start_time) * 1000

        joint_angles = self._compute_joint_angles(t)
        corrections = self._compute_corrections(joint_angles)

        return TrackingFrame(
            frame_number=self._frame_counter,
            timestamp_ms=round(timestamp_ms, 1),
            joint_angles=joint_angles,
            corrections=corrections,
            pose_detected=True,
        )

    def generate_frames(self, count: int = 120) -> Iterator[TrackingFrame]:
        """Yield *count* sequential ``TrackingFrame`` objects.

        Args:
            count: Number of frames to generate.

        Yields:
            ``TrackingFrame`` instances.
        """
        for _ in range(count):
            yield self.next_frame()

    def reset(self) -> None:
        """Reset the internal frame counter and start time."""
        self._frame_counter = 0
        self._start_time = time.time()

    # ── private helpers ─────────────────────────────────────────

    def _compute_joint_angles(self, t: float) -> list[JointAngle]:
        """Sinusoidal angle simulation for each configured joint."""
        angles: list[JointAngle] = []

        for jcfg in self.joints:
            # Sinusoidal sweep:  centre ± amplitude
            angle = jcfg["centre"] + jcfg["amplitude"] * math.sin(
                2 * math.pi * t + jcfg["phase_offset"]
            )
            angles.append(
                JointAngle(
                    joint_name=jcfg["joint_name"],
                    angle_degrees=round(angle, 2),
                    base_landmark=jcfg["base_landmark"],
                    vertex_landmark=jcfg["vertex_landmark"],
                    end_landmark=jcfg["end_landmark"],
                )
            )

        return angles

    def _compute_corrections(
        self,
        joint_angles: list[JointAngle],
    ) -> list[ExerciseCorrection]:
        """Generate corrections for joints deviating from targets."""
        corrections: list[ExerciseCorrection] = []

        for ja in joint_angles:
            target = self.target_angles.get(ja.joint_name)
            if target is None:
                continue

            deviation = ja.angle_degrees - target
            abs_dev = abs(deviation)

            if abs_dev < 5.0:
                continue

            if abs_dev >= 30.0:
                severity = "critical"
            elif abs_dev >= 15.0:
                severity = "warning"
            else:
                severity = "info"

            direction = "more" if deviation < 0 else "less"
            message = f"Adjust {ja.joint_name}: bend {direction} by ~{abs_dev:.0f}°"

            corrections.append(
                ExerciseCorrection(
                    joint_name=ja.joint_name,
                    current_angle=ja.angle_degrees,
                    target_angle=target,
                    deviation=round(deviation, 2),
                    message=message,
                    severity=severity,
                )
            )

        return corrections
