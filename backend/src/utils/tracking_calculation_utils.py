import math

def calculate_angle(pose_frame, joint) -> float | None:
    JOINT_MAP = { #NOTE: right and left seems backwards?
        "Right Elbow": (12, 14, 16),
        "Left Elbow": (11, 13, 15),
    }
    
    # Getting the landmarks for requested joint
    landmark1, landmark2, landmark3 = JOINT_MAP.get(joint)
    if not all(0 <= lm < len(pose_frame.landmarks) for lm in [landmark1, landmark2, landmark3]):
        return None

    a = (pose_frame.landmarks[landmark1].x, pose_frame.landmarks[landmark1].y)
    b = (pose_frame.landmarks[landmark2].x, pose_frame.landmarks[landmark2].y)
    c = (pose_frame.landmarks[landmark3].x, pose_frame.landmarks[landmark3].y)

    ba = [a[i] - b[i] for i in range(len(a))]
    bc = [c[i] - b[i] for i in range(len(c))]

    dotProduct = sum(ba[i] * bc[i] for i in range(len(ba)))
    mag_ba = math.sqrt(sum(x * x for x in ba))
    mag_bc = math.sqrt(sum(x * x for x in bc))

    cos_angle = dotProduct / (mag_ba * mag_bc)
    angle = math.degrees(math.acos(cos_angle))

    return angle