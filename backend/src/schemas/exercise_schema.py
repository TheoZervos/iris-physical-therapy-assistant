from pydantic import BaseModel, Field
from typing import Literal

class Exercise(BaseModel):
    id: str = Field(description="The exercise id")
    joints: list[str] = Field(description="The joints the exercise needs to track")
    joint_angles: dict[str, tuple[int, int]] = Field(description="Lower and upper bounds of the angle of a joint")
    orientation_to_camera: Literal["facing", "perpendicular"] = Field(description="The way that the user should orient with the camera")
    
class ExerciseSession(BaseModel):
    id: str = Field(description="The exercise session id")
    elapsed_time: float = Field(description="The duration of the exercise in seconds")
    time_per_side: tuple[float, float] = Field(description="The time spend on each side of the body")
    correct_time: float = Field(description="The amount of time spent with correct form")
    
# A LIST OF SUPPORTED EXERCISES
EXERCISES: dict[str, Exercise] = {
    "CAS1": Exercise(
        id="CAS1", 
        joints=["elbow", "shoulder"],
        joint_angles={
            "elbow": (-90, -110),
            "shoulder": (0, 0)
        },
        orientation_to_camera="facing"
    )
}