"""Pydantic models for body pose landmark data."""

from pydantic import BaseModel, Field

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
