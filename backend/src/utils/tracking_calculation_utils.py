"""Angle calculation utilities for body pose tracking.

Provides signed angle computation using atan2 so that the direction
of rotation (clockwise vs counter-clockwise in screen coordinates)
is preserved.  This lets the CV pipeline distinguish, for example,
an elbow bent 90° to the left (-90°) from 90° to the right (+90°)
when the upper arm is used as the reference base.
"""

import math
from typing import Optional

from src.schemas.pose_schema import PoseFrame

# ──────────────────────────────────────────────────────────────────
# Joint map:  joint_name  →  (base_idx, vertex_idx, end_idx, side_sign)
#
# *base*     = the reference limb endpoint (e.g. shoulder for elbow angle)
# *vertex*   = the joint centre (e.g. elbow)
# *end*      = the moving limb endpoint (e.g. wrist)
# *side_sign* = +1 for left-side joints, -1 for right-side joints.
#
# MediaPipe landmark coordinates have x increasing to the right of the
# *image frame*, which means the cross-product sign is geometrically
# flipped between the left and right sides of the body.  Multiplying
# by side_sign corrects this so that the same physical movement (e.g.
# bending the elbow forward) produces the same signed angle on both
# sides.
# ──────────────────────────────────────────────────────────────────
JOINT_MAP: dict[str, tuple[int, int, int, int]] = {
    # Arms
    "Right Elbow":    (12, 14, 16, -1),  # right_shoulder → right_elbow → right_wrist
    "Left Elbow":     (11, 13, 15, +1),  # left_shoulder  → left_elbow  → left_wrist
    # Shoulders
    "Right Shoulder": (24, 12, 14, -1),  # right_hip → right_shoulder → right_elbow
    "Left Shoulder":  (23, 11, 13, +1),  # left_hip  → left_shoulder  → left_elbow
    # Knees
    "Right Knee":     (24, 26, 28, -1),  # right_hip → right_knee → right_ankle
    "Left Knee":      (23, 25, 27, +1),  # left_hip  → left_knee  → left_ankle
    # Hips
    "Right Hip":      (12, 24, 26, -1),  # right_shoulder → right_hip → right_knee
    "Left Hip":       (11, 23, 25, +1),  # left_shoulder  → left_hip  → left_knee
}


def calculate_angle(pose_frame: PoseFrame, joint: str) -> Optional[float]:
    """Compute the **signed** angle at a joint from a PoseFrame.

    The sign is derived from the 2-D cross product of vectors
    BA (base→vertex) and BC (vertex→end), corrected by a per-joint
    ``side_sign`` so that the same physical motion produces the same
    signed angle on both the left and right sides of the body.

    *  positive → bend in the "forward" / flexion direction
    *  negative → bend in the "backward" / extension direction

    Args:
        pose_frame: The current frame's pose data.
        joint: A key from ``JOINT_MAP`` (e.g. ``"Right Elbow"``).

    Returns:
        Signed angle in degrees (-180, +180], or ``None`` if the
        required landmarks are missing from the frame.
    """
    entry = JOINT_MAP.get(joint)
    if entry is None:

        return None

    base_idx, vertex_idx, end_idx, side_sign = entry
    landmark_indices = (base_idx, vertex_idx, end_idx)

    # Make sure all three landmarks are present
    if not all(0 <= idx < len(pose_frame.landmarks) for idx in landmark_indices):
        return None

    # Extract 2-D coordinates (normalised 0-1)
    a = (pose_frame.landmarks[base_idx].x, pose_frame.landmarks[base_idx].y)
    b = (pose_frame.landmarks[vertex_idx].x, pose_frame.landmarks[vertex_idx].y)
    c = (pose_frame.landmarks[end_idx].x, pose_frame.landmarks[end_idx].y)

    return side_sign * _signed_angle(a, b, c)


def calculate_angle_from_points(
    a: tuple[float, float],
    b: tuple[float, float],
    c: tuple[float, float],
) -> float:
    """Compute the signed angle at vertex *b* given three 2-D points.

    Convenience wrapper when you already have raw (x, y) coordinates
    rather than a full PoseFrame.

    Args:
        a: Base point (x, y).
        b: Vertex / joint centre (x, y).
        c: End point (x, y).

    Returns:
        Signed angle in degrees (-180, +180].
    """
    return _signed_angle(a, b, c)


def normalize_angle(angle: float, base_angle: float) -> float:
    """Normalize *angle* relative to *base_angle*.

    Returns the signed deviation of *angle* from *base_angle*,
    wrapped to the range (-180, +180].

    Example:
        If base_angle = 0 and angle = 90 → returns 90.
        If base_angle = 0 and angle = -90 → returns -90.
        If base_angle = 45 and angle = 50 → returns 5.

    Args:
        angle: The measured angle in degrees.
        base_angle: The reference / rest-position angle in degrees.

    Returns:
        Normalised deviation in degrees (-180, +180].
    """
    delta = angle - base_angle
    # Wrap into (-180, +180]
    while delta > 180:
        delta -= 360
    while delta <= -180:
        delta += 360
    return delta


# ──────────────────────── private helpers ────────────────────────


def _signed_angle(
    a: tuple[float, float],
    b: tuple[float, float],
    c: tuple[float, float],
) -> float:
    """Return the signed angle (degrees) at vertex *b* formed by A-B-C.

    Uses ``atan2(cross, dot)`` so the result is in (-180, +180].
    """
    ba = (a[0] - b[0], a[1] - b[1])
    bc = (c[0] - b[0], c[1] - b[1])

    dot = ba[0] * bc[0] + ba[1] * bc[1]
    cross = ba[0] * bc[1] - ba[1] * bc[0]

    angle_rad = math.atan2(cross, dot)
    return math.degrees(angle_rad)