from typing import Literal

from src.utils.tracking_calculation_utils import calculate_angle
from src.utils.constants import BODY_VECTORS, JOINT_MAP

from src.schemas.pose_schema import PoseFrame
from src.schemas.exercise_schema import Exercise, ExerciseTrackingFrame, ExerciseCorrection, RangeOfMotion

# Gets the direction for a body vector
def get_vector_direction(pose_frame: PoseFrame, body_vec: str) -> dict[str, dict[str, str | float]]:
    entry = BODY_VECTORS[body_vec]
    if entry is None:
      return None
  
    start_idx, end_idx = entry
    landmarks = (start_idx, end_idx)
    
    if not all(0 <= lm < len(pose_frame.landmarks) for lm in landmarks):
        return None
    
    # Getting vectors
    x_vec = pose_frame.landmarks[end_idx].x - pose_frame.landmarks[start_idx].x
    y_vec = pose_frame.landmarks[end_idx].y - pose_frame.landmarks[start_idx].y
    z_vec = pose_frame.landmarks[end_idx].z - pose_frame.landmarks[start_idx].z
    
    # print(f"start: {pose_frame.landmarks[end_idx].z} | end: {pose_frame.landmarks[start_idx].z}")
    
    # Determining most likely direction
    directions = {"x": {}, "y": {}, "z": {}}
    if x_vec > 0:
        directions["x"]["direction"] = "left"
        directions["x"]["strength"] = abs(x_vec)
    else:
        directions["x"]["direction"] = "right"
        directions["x"]["strength"] = abs(x_vec)

    if y_vec > 0:
        directions["y"]["direction"] = "down"
        directions["y"]["strength"] = abs(y_vec)
    else:
        directions["y"]["direction"] = "up"
        directions["y"]["strength"] = abs(y_vec)
        
    if z_vec < 0:
        directions["z"]["direction"] = "front"
        directions["z"]["strength"] = abs(z_vec)
    else:
        directions["z"]["direction"] = "back"
        directions["z"]["strength"] = abs(z_vec)
        
    return directions
    

def get_facing_direction(pose_frame: PoseFrame) -> str:
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
    
    # print(f"right: {right_shoulder.x}")
    # print(f"left: {left_shoulder.x}")
    
    # find higher difference for best direction estimation
    if abs(x_diff) > abs(z_diff): # likely facing front or back
        if x_diff > 0:
            return "front"
        else:
            return "back"
    elif abs(x_diff) < abs(z_diff): # likely facing left or right
        if left_hip.z < right_hip.z:
            return "right"
        else:
            return "left"
    
    # something went wrong
    return "unknown"

def _is_in_rom(joint: str, pose_frame: PoseFrame, target_rom: RangeOfMotion, rom_grace: float) -> bool:
    cur_angle = calculate_angle(pose_frame, joint)
    return cur_angle < target_rom[0] - 10 and cur_angle > target_rom[1] + 10


def _get_cur_side(pose_frame: PoseFrame, facing_dir: str, exercise: Exercise) -> Literal["left", "right", "unknown"]:
    if facing_dir == "right":
        return "left"
    elif facing_dir == "left":
        return "right"
    
    for side, body_vectors in exercise.body_vec_directions.items():
            # looking for side that is being exercised (if any)
            side_found = True
            for body_vec, dir in body_vectors.items():
                cur_dir = get_vector_direction(pose_frame, body_vec)
                if cur_dir != dir:
                    side_found = False
                    break
            
            if side_found:
                return side
    
    return "unknown"

def get_body_position(pose_frame: PoseFrame, exercise: Exercise) -> ExerciseTrackingFrame:
    rom_grace = 10  # grace in degrees given for the exercise to be considered started
    facing = get_facing_direction(pose_frame)
    
    # checking user is facing correct direction
    if facing not in exercise.facing_dir:
        return ExerciseTrackingFrame(
            corrections=[ExerciseCorrection(
                message=f"facing_wrong_dir",
                severity="info"  
            )],
            cv_success=True, 
            facing_dir=facing, 
            in_position=False
        )
    
    # tracking head on facing exercise
    if facing == "front" or facing == "back":
        # finding side being exercised
        cur_side = _get_cur_side(pose_frame, facing, exercise)
        side_found = True if cur_side != "unknown" else False
        
        # checking if users body is within rom to start exercise
        in_rom = True
        if side_found:
            for joint, rom in exercise.total_rom[cur_side]:
                in_rom = _is_in_rom(joint, pose_frame, rom, rom_grace)
                if not in_rom:
                    break
        
        # generating relevant corrections
        corrections = [ExerciseCorrection(
            message="not_in_position",
            severity="info"
        )] if not side_found or not in_rom else []
        
        return ExerciseTrackingFrame(
            facing=facing,
            cur_side=cur_side,
            in_position=side_found and in_rom,
            corrections=corrections,
            cv_success=True
        )
        
    # tracking left/right facing exercise
    else:        
        # checking that user is in position for exercise in dir they are facing
        for body_vec, dir in exercise.body_vec_directions[facing].items():
            cur_dir = get_vector_direction(pose_frame, body_vec)
            in_position = cur_dir == dir
            if not in_position:
                break
        
        # getting side of body user is exercising    
        cur_side = _get_cur_side(pose_frame, facing, exercise)
            
        # checking that user is in rom to start exercise
        in_rom = True
        if in_position:
            for joint, rom in exercise.total_rom[cur_side]:
                in_rom = _is_in_rom(joint, pose_frame, rom, rom_grace)
                if not in_rom:
                    break
        
        corrections = [ExerciseCorrection(
            message="not_in_position",
            severity="info"
        )] if not in_position or not in_rom else []
        
        return ExerciseTrackingFrame(
            facing=facing,
            cur_side= "left" if facing == "right" else "right",  # track opposite of facing
            corrections=corrections,
            in_position=in_position and in_rom,
            cv_success=True
        )


def _angle_is_good(cur_angle: float, angle_range: tuple[float, float]) -> bool:
    return cur_angle > angle_range[0] and cur_angle < angle_range[1]

def get_joint_angles(
    pose_frame: PoseFrame,
    exercise: Exercise
) -> tuple[dict[str, float], dict[str, float]]:
    # get angles
    joint_angles = {
        joint: calculate_angle(pose_frame, joint)
        for joint in exercise.joints
    }
    
    # get side being exercised
    cur_facing = get_facing_direction(pose_frame)
    cur_side = _get_cur_side(pose_frame, cur_facing, exercise)
    
    # get angles that don't meet exercise range
    bad_angles = {
        joint: joint_angle
        for joint, joint_angle in joint_angles.items()
        if not _angle_is_good(
            joint_angle, 
            exercise.total_rom[cur_side][joint]
        )
    }
    
    return joint_angles, bad_angles

def get_corrections(bad_angles: dict[str, float], target_angles: dict[str, RangeOfMotion]) -> list[ExerciseCorrection]:
    corrections = []
    for joint, angle in bad_angles.items():
        if angle > target_angles[joint].high_angle:
            corrections.append(
                ExerciseCorrection(
                    message=f"{joint}:over_extended",
                    severity="warning"
                )
            )
            
        if angle < target_angles[joint].low_angle:
            corrections.append(
                ExerciseCorrection(
                    message=f"{joint}:under_extended",
                    severity="warning"
                )
            )
    
    return corrections