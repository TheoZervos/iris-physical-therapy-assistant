from pydantic import BaseModel, Field
from typing import Literal

class Exercise(BaseModel):
    id: str = Field(description="The exercise id")
    joints: list[str] = Field(description="The joints the exercise needs to track")
    rom: dict[str, tuple[float, float]] = Field(description="The starting and ending angles of the exercise for each relevant joint (range of motion)")
    movement_dir: dict[str, str] = Field(description="The direction the relevant body vectors for each joint should be facing to track the exercise")
    stretch_angles: dict[str, tuple[int, int]] = Field(description="Lower and upper bounds of the angles joints should be when stretching")
    orientation_to_camera: Literal["front", "back", "left", "right"] = Field(description="The way the user should orient with the camera")
    
class ExerciseSession(BaseModel):
    id: str = Field(description="The exercise session id")
    total_time: float = Field(description="The duration of the exercise in seconds")
    body_time_split: dict[str, float] = Field(description="The duration spent on each segment of the body")
    correct_time: float = Field(description="The amount of time spent with correct form")
    incorrect_time: float = Field(description="The amount of time spent with incorrect form")
    inactive_time: float = Field(description="The amount of time spent not exercising.")
    
