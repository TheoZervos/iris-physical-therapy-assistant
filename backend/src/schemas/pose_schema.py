"""Pydantic models for body pose landmark data."""

from pydantic import BaseModel, Field


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


class Landmark(BaseModel):
    """A single detected body landmark (joint/point)."""

    index: int = Field(description="MediaPipe landmark index (0-32)")
    name: str = Field(description="Human-readable landmark name")
    x: float = Field(description="Normalized x coordinate (0.0 to 1.0)")
    y: float = Field(description="Normalized y coordinate (0.0 to 1.0)")
    z: float = Field(description="Depth coordinate relative to hips")
    visibility: float = Field(
        description="Confidence that the landmark is visible (0.0 to 1.0)"
    )


class PoseFrame(BaseModel):
    """Pose detection results for a single video frame."""

    frame_number: int = Field(description="Sequential frame counter")
    timestamp_ms: float = Field(description="Frame timestamp in milliseconds")
    landmarks: list[Landmark] = Field(
        default_factory=list,
        description="List of 33 detected body landmarks",
    )
    detection_confidence: float = Field(
        default=0.0,
        description="Overall pose detection confidence",
    )

    @property
    def has_pose(self) -> bool:
        """Whether a pose was detected in this frame."""
        return len(self.landmarks) > 0
