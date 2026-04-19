import numpy as np
from pydantic import BaseModel, Field, field_serializer
from typing import Any, Literal, Optional
from src.schemas.pose_schema import PoseFrame

class RangeOfMotion(BaseModel):
    low_angle: float = Field(description="The lowest angle of the exercise.")
    high_angle: float = Field(description="The highest anfle of the exercise.")

class Exercise(BaseModel):
    id: str = Field(description="The exercise id")
    joints: list[str] = Field(description="The joints the exercise needs to track")
    total_rom: dict[str, dict[str, RangeOfMotion]] = Field(
        default={}, 
        description="The starting and ending angles of the exercise for each relevant joint (range of motion) given side of the body"
    )
    body_vec_directions: dict[str, dict[str, str]] = Field(
        description="The direction the relevant body vectors for each joint should be facing to track the exercise by the side of the body being tracked"
    )
    stretch_angles: dict[str, dict[str, RangeOfMotion]] = Field(
        description="Lower and upper bounds of the angles the joints should be when stretching given a side of the body"
    )
    facing_dir: Literal["front", "back", "left/right"] = Field(description="The way the user should orient with the camera")
    
class ExerciseCorrection(BaseModel):
    message: str = Field(description="Human-readable correction instruction")
    severity: Literal["info", "warning"] = Field(description="How severe the correction is")
    
class ExerciseTrackingFrame(BaseModel):
    pose_frame: Optional[PoseFrame] = Field(default = None, description="The pose frame for the tracked frame")
    annotated_frame: Optional[list[float]] = Field(default = None, description="The annotated frame for the tracked frame")
    facing: str = Field(default="unknown", description="The direction the user is currently facing")
    cur_side: str = Field(default="", description="The current side of the body being tracked for an exercise")
    cur_angles: dict[str, float] = Field(default={}, description="The current angles for the tracked joints")
    bad_angles: dict[str, float] = Field(default={}, description="The current joints and angles that are incorrect")
    in_position: bool = Field(default=False, description="Whether or not the user is in position to start the exercise")
    corrections: list[ExerciseCorrection] = Field(default=[], description="List of exercise corrections and feedback")
    elapsed_time: float = Field(default=0, description="The total amount of time that has passed (in seconds)")
    cv_success: bool = Field(description="Whether or not the CV processing was successful")
    
    def get_annotated_frame(self):
        return np.array(self.annotated_frame)
    
    @field_serializer('annotated_frame')
    def serialize_ndarray(self, v: Any, _info):
        if isinstance(v, np.ndarray):
            return v.tolist()  # Convert to list so JSON can handle it
        return v
    
class ExerciseSession(BaseModel):
    id: str = Field(description="The exercise session id")
    total_time: float = Field(description="The duration of the exercise in seconds")
    body_time_split: dict[str, float] = Field(description="The duration spent on each segment of the body")
    correct_time: float = Field(description="The amount of time spent with correct form")
    incorrect_time: float = Field(description="The amount of time spent with incorrect form")
    inactive_time: float = Field(description="The amount of time spent not exercising.")