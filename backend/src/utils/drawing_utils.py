import cv2
import numpy as np
from src.schemas.exercise_schema import Exercise, ExerciseTrackingFrame
from src.schemas.pose_schema import Landmark, PoseFrame
from src.utils.constants import POSE_CONNECTIONS

def draw_landmarks(frame: np.ndarray, landmarks: list[Landmark]) -> None:
    """Draw pose landmarks and connections manually using OpenCV.

    Args:
        frame: the OpenCV BGR image frame.
        landmarks: list of Landmark Pydantic models.
    """
    h, w = frame.shape[:2]
    
    # Draw connections
    for connection in POSE_CONNECTIONS:
        start_idx, end_idx = connection
        if start_idx < len(landmarks) and end_idx < len(landmarks):
            lm1 = landmarks[start_idx]
            lm2 = landmarks[end_idx]
            
            # Only draw if both points are reasonably visible
            if lm1.visibility > 0.5 and lm2.visibility > 0.5:
                x1, y1 = int(lm1.x * w), int(lm1.y * h)
                x2, y2 = int(lm2.x * w), int(lm2.y * h)
                cv2.line(frame, (x1, y1), (x2, y2), (255, 255, 255), 2)

    # Draw joints
    for lm in landmarks:
        if lm.visibility > 0.5:
            x, y = int(lm.x * w), int(lm.y * h)
            cv2.circle(frame, (x, y), 5, (0, 0, 255), -1)
            cv2.circle(frame, (x, y), 5, (255, 255, 255), 1)
                
def draw_hud(
    frame: np.ndarray, 
    pose_frame: PoseFrame, 
    fps: float, 
    right_angle: float | None, 
    left_angle: float | None,
    facing: str
) -> np.ndarray:
    """Draw heads-up display info on the frame.

    Args:
        frame: The annotated video frame.
        pose_frame: Current frame's pose data.
        fps: Current frames per second.
        right_angle: Signed angle for the right elbow (degrees), or None.
        left_angle: Signed angle for the left elbow (degrees), or None.

    Returns:
        Frame with HUD overlay.
    """
    h, w = frame.shape[:2]

    # Semi-transparent background for HUD
    overlay = frame.copy()
    cv2.rectangle(overlay, (10, 10), (280, 195), (0, 0, 0), -1)
    cv2.addWeighted(overlay, 0.6, frame, 0.4, 0, frame)

    # FPS counter
    cv2.putText(
        frame,
        f"FPS: {fps:.1f}",
        (20, 35),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.7,
        (0, 255, 0),
        2,
    )

    # Landmark count
    status = "TRACKING" if pose_frame.has_pose else "NO POSE"
    color = (0, 255, 0) if pose_frame.has_pose else (0, 0, 255)
    cv2.putText(
        frame,
        f"Status: {status}",
        (20, 65),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.7,
        color,
        2,
    )
    
    # Right Elbow Angle
    cv2.putText(
        frame,
        f"Right Shoulder: {int(right_angle) if right_angle is not None else 'N/A'}",
        (20, 95),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.7,
        color,
        2,
    )

    # Left Elbow Angle
    cv2.putText(
        frame,
        f"Right Elbow:  {int(left_angle) if left_angle is not None else 'N/A'}",
        (20, 125),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.7,
        color,
        2,
    )
    
    # Facing
    cv2.putText(
        frame,
        f"Facing: {facing}",
        (20, 155),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.6,
        (255, 255, 255),
        1,
    )

    # Confidence
    cv2.putText(
        frame,
        f"Confidence: {pose_frame.detection_confidence:.1%}",
        (20, 185),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.6,
        (255, 255, 255),
        1,
    )

    # Instruction at bottom
    cv2.putText(
        frame,
        "Press 'q' to quit",
        (w // 2 - 90, h - 20),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.6,
        (200, 200, 200),
        1,
    )

    return frame

def draw_exercise_tracking_hud(
    exercise: str,
    tracking_frame: ExerciseTrackingFrame,
    annotated_frame: np.ndarray, 
    pose_frame: PoseFrame, 
) -> np.ndarray:
    # Semi-transparent background for HUD
    overlay = annotated_frame.copy()
    cv2.rectangle(overlay, (10, 10), (280, 195), (0, 0, 0), -1)
    cv2.addWeighted(overlay, 0.6, annotated_frame, 0.4, 0, annotated_frame)
    
    # Landmark count
    status = "TRACKING" if pose_frame.has_pose else "NO POSE"
    color = (0, 255, 0) if pose_frame.has_pose else (0, 0, 255)
    font = cv2.FONT_HERSHEY_SIMPLEX
    cv2.putText(
        annotated_frame,
        f"Status: {status}",
        (20, 65),
        font,
        0.7,
        color,
        2,
    )
    
    # Exercise being tracked
    cv2.putText(
        annotated_frame,
        f"Exercise: {exercise}",
        (20, 95),
        font,
        0.7,
        color,
        2
    )
    
    # Corrections to apply
    spacing = 0
    for correction in tracking_frame.corrections:
        cv2.putText(
            annotated_frame,
            correction.message,
            (20, 125+spacing),
            font,
            0.7,
            color,
            2
        )
        
    return annotated_frame