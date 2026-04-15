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
    "right_elbow":    (12, 14, 16, -1),  # right_shoulder → right_elbow → right_wrist
    "left_elbow":     (11, 13, 15, +1),  # left_shoulder  → left_elbow  → left_wrist
    # Shoulders
    "right_shoulder": (24, 12, 14, -1),  # right_hip → right_shoulder → right_elbow
    "left_shoulder":  (23, 11, 13, +1),  # left_hip  → left_shoulder  → left_elbow
    # Knees
    "right_knee":     (24, 26, 28, -1),  # right_hip → right_knee → right_ankle
    "left_knee":      (23, 25, 27, +1),  # left_hip  → left_knee  → left_ankle
    # Hips
    # "Right Hip":      (12, 24, 26, -1),  # right_shoulder → right_hip → right_knee
    # "Left Hip":       (11, 23, 25, +1),  # left_shoulder  → left_hip  → left_knee
}

def get_facing_direction(pose_frame: PoseFrame):
    """Determine the direction that the user is facing

    Args:
        pose_frame (PoseFrame): The current frame's pose data.
        
    Returns:
        The direction the user is facing
        ["front", "back", "left", "right", "unknown"]
    """
    if not all(0 <= lm < len(pose_frame.landmarks) for lm in [23, 24, 11, 12]):
        return "unknown"
    
    left_hip = pose_frame.landmarks[23]
    right_hip = pose_frame.landmarks[24]
    left_shoulder = pose_frame.landmarks[11]
    right_shoulder = pose_frame.landmarks[12]
    
    # get differences in hips and shoulders
    hip_x_diff = left_hip.x - right_hip.x
    hip_z_diff = left_hip.z - right_hip.z
    shoulder_x_diff = left_shoulder.x - right_shoulder.x
    shoulder_z_diff = left_shoulder.z - right_shoulder.z
    
    # get sum of total differences
    x_diff = hip_x_diff + shoulder_x_diff
    z_diff = hip_z_diff + shoulder_z_diff
    
    # find higher difference for best direction estimation
    if abs(x_diff) > abs(z_diff): # likely facing front or back
        if x_diff > 0:
            return "front"
        else:
            return "back"
    elif abs(x_diff) < abs(z_diff):
        if left_hip.z < right_hip.z:
            return "right"
        else:
            return "left"
    
    # something went wrong
    return "unknown"

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
    
    print(f"{joint} | {pose_frame.landmarks[base_idx].z}")
    
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