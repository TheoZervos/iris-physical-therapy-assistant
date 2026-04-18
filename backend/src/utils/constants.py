from src.schemas.exercise_schema import Exercise

# Mapping of MediaPipe's 33 pose landmark indices to human-readable names
LANDMARK_NAMES: dict[int, str] = {
    0: "nose",
    1: "left_eye_inner",
    2: "left_eye",
    3: "left_eye_outer",
    4: "right_eye_inner",
    5: "right_eye",
    6: "right_eye_outer",
    7: "left_ear",
    8: "right_ear",
    9: "mouth_left",
    10: "mouth_right",
    11: "left_shoulder",
    12: "right_shoulder",
    13: "left_elbow",
    14: "right_elbow",
    15: "left_wrist",
    16: "right_wrist",
    17: "left_pinky",
    18: "right_pinky",
    19: "left_index",
    20: "right_index",
    21: "left_thumb",
    22: "right_thumb",
    23: "left_hip",
    24: "right_hip",
    25: "left_knee",
    26: "right_knee",
    27: "left_ankle",
    28: "right_ankle",
    29: "left_heel",
    30: "right_heel",
    31: "left_foot_index",
    32: "right_foot_index",
}

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

# Vectors formed by parts of the body between joints
BODY_VECTORS: dict[str, tuple[int, int]] = {
    # Arms
    "right_forearm_vec": (14, 16),
    "left_forearm_vec": (13, 15),
    "right_bicep_vec": (12, 14),
    "left_bicep_vec": (11, 13),
    # Legs
    "right_quad_vec": (24, 26),
    "left_quad_vec": (23, 25),
    "right_calf_vec": (26, 28),
    "left_calf_vec": (25, 27)
}

# Connections between the 33 MediaPipe pose landmarks for drawing the skeleton
POSE_CONNECTIONS = [
    (15, 21), (16, 22), (15, 17), (16, 18), (15, 19), (16, 20), (17, 19), (18, 20),
    (11, 13), (12, 14), (13, 15), (14, 16), (11, 12), (11, 23), (12, 24), (23, 24),
    (23, 25), (24, 26), (25, 27), (26, 28), (27, 29), (28, 30), (29, 31), (30, 32),
    (27, 31), (28, 32), (0, 1), (0, 4), (1, 2), (4, 5), (2, 3), (5, 6), (3, 7),
    (6, 8), (9, 10)
]

# A LIST OF SUPPORTED EXERCISES
EXERCISES: dict[str, Exercise] = {
    "CAS1": Exercise(
        id="CAS1", 
        joints=["elbow", "shoulder"],
        rom={},
        movement_dir={
            "right_elbow": "left",
            "left_elbow": "right",
        },
        stretch_angles={
            "elbow": (75, 100),
            "shoulder": (0, 0)
        },
        orientation_to_camera="facing"
    )
}