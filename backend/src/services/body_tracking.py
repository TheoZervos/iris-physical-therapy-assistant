"""Body pose tracking service using MediaPipe Tasks Vision API.

Captures live video from the device camera and runs real-time
pose estimation, detecting 33 body landmarks per frame.
"""
import sys
import time
from typing import AsyncGenerator
from pathlib import Path

import cv2
import math
import mediapipe as mp
import numpy as np
from mediapipe.tasks import python
from mediapipe.tasks.python import vision


from src.schemas.pose_schema import LANDMARK_NAMES, Landmark, PoseFrame
from src.utils.video_utils import get_camera_source, get_video_properties
from src.utils.drawing_utils import draw_landmarks, draw_hud


class BodyTracker:
    """Real-time body pose tracker using MediaPipe Tasks Vision API.

    Captures frames from the device camera, runs pose inference,
    and optionally displays the annotated live feed.
    """

    def __init__(
        self,
        camera_index: int = 0,
        min_detection_confidence: float = 0.5,
        min_tracking_confidence: float = 0.5,
        model_complexity: int = 1,
    ) -> None:
        """Initialize the body tracker.

        Args:
            camera_index: Device camera index (0 = default).
            min_detection_confidence: Minimum confidence for initial detection.
            min_tracking_confidence: Minimum confidence for frame-to-frame tracking.
            model_complexity: Model complexity (0=lite, 1=full, 2=heavy).
        """
        self.camera_index = camera_index
        
        # Determine model path based on complexity
        model_type = "lite" if model_complexity == 0 else "full"
        model_path = f"../models/pose_landmarker_{model_type}.task"

        # Initialize MediaPipe PoseLandmarker
        base_options = python.BaseOptions(model_asset_path=str(model_path))
        options = vision.PoseLandmarkerOptions(
            base_options=base_options,
            running_mode=vision.RunningMode.VIDEO,
            min_pose_detection_confidence=min_detection_confidence,
            min_pose_presence_confidence=min_tracking_confidence,
            min_tracking_confidence=min_tracking_confidence,
            num_poses=1
        )
        self._landmarker = vision.PoseLandmarker.create_from_options(options)

        # Video capture (opened lazily)
        self._cap: cv2.VideoCapture | None = None

        # Session tracking
        self._frame_count: int = 0
        self._start_time: float = 0.0
        self._fps_history: list[float] = []

    def _open_camera(self) -> None:
        """Open the camera if not already open."""
        if self._cap is None or not self._cap.isOpened():
            self._cap = get_camera_source(self.camera_index)
            props = get_video_properties(self._cap)
            print(f"Camera opened: {props['width']}x{props['height']} @ {props['fps']:.0f} FPS")
            print(f"Backend: {props['backend']}")

    def _process_frame(self, frame: np.ndarray, timestamp_ms: int) -> tuple[np.ndarray, PoseFrame]:
        """Run pose detection on a single frame.

        Args:
            frame: BGR image from OpenCV.
            timestamp_ms: Frame timestamp in milliseconds.

        Returns:
            Tuple of (annotated frame, PoseFrame with landmarks).
        """
        self._frame_count += 1

        # Convert BGR → RGB and create MediaPipe Image
        rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb_frame)

        # Run pose inference in VIDEO mode
        results = self._landmarker.detect_for_video(mp_image, timestamp_ms)

        # Extract landmarks into Pydantic models
        landmarks: list[Landmark] = []
        detection_confidence = 0.0

        if results.pose_landmarks and len(results.pose_landmarks) > 0:
            pose_lms = results.pose_landmarks[0]
            
            for idx, lm in enumerate(pose_lms):
                visibility = lm.visibility if hasattr(lm, 'visibility') and lm.visibility is not None else 1.0
                landmarks.append(
                    Landmark(
                        index=idx,
                        name=LANDMARK_NAMES.get(idx, f"landmark_{idx}"),
                        x=lm.x,
                        y=lm.y,
                        z=lm.z,
                        visibility=visibility,
                    )
                )
            
            # Average visibility as a proxy for overall confidence
            if landmarks:
                detection_confidence = sum(lm.visibility for lm in landmarks) / len(landmarks)

        pose_frame = PoseFrame(
            frame_number=self._frame_count,
            timestamp_ms=float(timestamp_ms),
            landmarks=landmarks,
            detection_confidence=detection_confidence,
        )

        return frame, pose_frame

    def _calculate_angle(self, pose_frame, joint):
        JOINT_MAP = { #NOTE: right and left seems backwards?
            "Right Elbow": (12, 14, 16),
            "Left Elbow": (11, 13, 15),
        }

        landmark1, landmark2, landmark3 = JOINT_MAP.get(joint)

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

        sys.stdout.write(
            f"\rAngle: {angle:.3f} | "
            f"A: x={a[0]:.3f}, y={a[1]:.3f} | "
            f"B: x={b[0]:.3f}, y={b[1]:.3f} | "
            f"C: x={c[0]:.3f}, y={c[1]:.3f}    "
        )
        sys.stdout.flush()
        return angle

    async def process_stream(self) -> AsyncGenerator[PoseFrame, None, None]:
        """Generator that yields PoseFrame objects from the live camera.

        Yields:
            PoseFrame for each captured frame.
        """
        self._open_camera()
        self._start_time = time.time()
        self._frame_count = 0

        while self._cap is not None and self._cap.isOpened():
            success, frame = self._cap.read()
            if not success:
                print("Warning: Failed to read frame from camera.")
                continue

            timestamp_ms = int((time.time() - self._start_time) * 1000)
            if timestamp_ms <= 0:
                timestamp_ms = 1

            _, pose_frame = self._process_frame(frame, timestamp_ms)
            yield pose_frame

    def run_tracker_with_display(self) -> dict:
        """Run the tracker with a live display window.

        Opens an OpenCV window showing the camera feed with skeleton
        overlay, FPS counter, and tracking status. Press 'q' to quit.

        Returns:
            Session summary with total frames, duration, and average FPS.
        """
        self._open_camera()
        self._start_time = time.time()
        self._frame_count = 0

        print("\n--- Iris Body Tracking ---")
        print("Pose detection active. Press 'q' to stop.\n")

        prev_time = time.time()
        start_time_ms = time.time() * 1000

        try:
            while self._cap is not None and self._cap.isOpened():
                success, frame = self._cap.read()
                if not success:
                    continue

                # Flip horizontally for a mirror-like experience
                frame = cv2.flip(frame, 1)

                # Process the frame
                current_time_ms = time.time() * 1000
                timestamp_ms = int(current_time_ms - start_time_ms)
                if timestamp_ms <= 0:
                    timestamp_ms = 1  # MediaPipe timestamp strictly positive and increasing

                annotated_frame, pose_frame = self._process_frame(frame, timestamp_ms)
                draw_landmarks(annotated_frame, pose_frame.landmarks)

                # Calculate FPS
                current_time = time.time()
                fps = 1.0 / max(current_time - prev_time, 1e-6)
                prev_time = current_time
                self._fps_history.append(fps)

                #Calculate Angle
                joint = "Left Elbow"
                angle = self._calculate_angle(pose_frame, joint)
                #print(angle)

                # Draw HUD
                annotated_frame = draw_hud(annotated_frame, pose_frame, fps)

                # Display
                cv2.imshow("Iris Body Tracking", annotated_frame)

                # Quit on 'q'
                if cv2.waitKey(1) & 0xFF == ord("q"):
                    break

        except KeyboardInterrupt:
            print("\nInterrupted by user.")
        finally:
            self.release()

        return self._get_session_summary()

    def _get_session_summary(self) -> dict:
        """Compute session statistics.

        Returns:
            Dictionary with total_frames, duration_seconds, and avg_fps.
        """
        duration = time.time() - self._start_time if self._start_time > 0 else 0
        avg_fps = sum(self._fps_history) / len(self._fps_history) if self._fps_history else 0

        return {
            "total_frames": self._frame_count,
            "duration_seconds": round(duration, 2),
            "avg_fps": round(avg_fps, 1),
        }

    def release(self) -> None:
        """Release camera and MediaPipe resources."""
        if self._cap is not None:
            self._cap.release()
            self._cap = None
        self._landmarker.close()
        cv2.destroyAllWindows()
        print("Resources released.")
