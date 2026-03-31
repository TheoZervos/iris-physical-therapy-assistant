"""Utility functions for video capture and camera management."""

import cv2


def get_camera_source(camera_index: int = 0) -> cv2.VideoCapture:
    """Open and validate a camera source.

    Args:
        camera_index: Device camera index (0 = default camera).

    Returns:
        An opened cv2.VideoCapture object.

    Raises:
        RuntimeError: If the camera cannot be opened.
    """
    cap = cv2.VideoCapture(camera_index)

    if not cap.isOpened():
        raise RuntimeError(
            f"Cannot open camera at index {camera_index}. "
            "Ensure a camera is connected and permissions are granted."
        )

    return cap


def get_video_properties(cap: cv2.VideoCapture) -> dict:
    """Extract properties from a VideoCapture object.

    Args:
        cap: An opened cv2.VideoCapture.

    Returns:
        Dictionary with fps, width, height, and backend info.
    """
    return {
        "fps": cap.get(cv2.CAP_PROP_FPS),
        "width": int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)),
        "height": int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)),
        "backend": cap.getBackendName(),
    }
