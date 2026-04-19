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
from src.utils.constants import JOINT_MAP


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
    landmarks = (base_idx, vertex_idx, end_idx)
  
    if not all(0 <= lm < len(pose_frame.landmarks) for lm in landmarks):
        return None
    
    # Extract 2-D coordinates (normalised 0-1)
    a = (pose_frame.landmarks[base_idx].x, pose_frame.landmarks[base_idx].y, pose_frame.landmarks[base_idx].z)
    b = (pose_frame.landmarks[vertex_idx].x, pose_frame.landmarks[vertex_idx].y, pose_frame.landmarks[vertex_idx].z)
    c = (pose_frame.landmarks[end_idx].x, pose_frame.landmarks[end_idx].y, pose_frame.landmarks[end_idx].z)

    return side_sign * _signed_angle(a, b, c)

# ──────────────────────── private helpers ────────────────────────

def _signed_angle(
    a: tuple[float, float, float],
    b: tuple[float, float, float],
    c: tuple[float, float, float],
) -> float:
    ba = (a[0] - b[0], a[1] - b[1], a[2] - b[2])
    bc = (c[0] - b[0], c[1] - b[1], a[2] - b[2])

    dot = ba[0] * bc[0] + ba[1] * bc[1]
    cross = ba[0] * bc[1] - ba[1] * bc[0]

    angle_rad = math.atan2(cross, dot)
    return math.degrees(angle_rad)