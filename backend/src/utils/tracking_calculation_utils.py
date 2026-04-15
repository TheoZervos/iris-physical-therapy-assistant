import math
from src.schemas.pose_schema import JOINT_MAP, PoseFrame

def calculate_angle(pose_frame: PoseFrame, joint: str) -> float | None:    
    # Getting the landmarks for requested joint
    # a - landmark1, b - landmark2, c - landmark3
    landmark1, landmark2, landmark3 = JOINT_MAP.get(joint)
    opposite_joint = joint.replace("left", "right") if "left" in joint else joint.replace("right", "left")
    alt_lm1, alt_lm2, alt_lm3 = JOINT_MAP.get(opposite_joint)
    
    missed_landmarks = []
    for index, lm in enumerate([landmark1, landmark2, landmark3]):
        if pose_frame.landmarks[lm].visibility < 0.4:
            missed_landmarks.append((index, lm))
            
    if len(missed_landmarks) > 2:
        return None
    
    opposite_joint = joint.replace("left", "right") if "left" in joint else joint.replace("right", "left")
    a = landmark1 if landmark1 not in missed_landmarks else 
    
    ba = [landmark1[i] - landmark2[i] for i in range(len(landmark1))]
    bc = [landmark3[i] - landmark2[i] for i in range(len(landmark3))]

    dotProduct = sum(ba[i] * bc[i] for i in range(len(ba)))
    mag_ba = math.sqrt(sum(x * x for x in ba))
    mag_bc = math.sqrt(sum(x * x for x in bc))

    cos_angle = dotProduct / (mag_ba * mag_bc)
    angle = math.degrees(math.acos(cos_angle))

    return angle