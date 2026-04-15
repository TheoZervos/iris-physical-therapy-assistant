"""Angle tracking service.

Consumes a ``PoseFrame`` (raw landmark data) and produces a fully
structured ``TrackingFrame`` with signed joint angles and exercise
corrections, ready to be serialised to JSON and streamed to the
frontend.
"""

from src.schemas.pose_schema import LANDMARK_NAMES, PoseFrame
from src.schemas.tracking_schema import (
    ExerciseCorrection,
    JointAngle,
    TrackingFrame,
)
from src.utils.tracking_calculation_utils import (
    JOINT_MAP,
    calculate_angle,
)


class AngleTracker:
    """Stateless helper that converts pose data into tracking payloads.

    Usage::

        tracker = AngleTracker()
        frame = tracker.build_tracking_frame(pose_frame)
        json_str = frame.model_dump_json()
    """

    def __init__(
        self,
        target_angles: dict[str, float] | None = None,
        warning_threshold: float = 15.0,
        critical_threshold: float = 30.0,
    ) -> None:
        """Initialise the tracker.

        Args:
            target_angles: Optional mapping of joint name → target angle
                (degrees).  When provided, corrections are generated for
                joints whose current angle deviates from the target.
            warning_threshold: Deviation (degrees) at which a correction
                becomes a *warning*.
            critical_threshold: Deviation (degrees) at which a correction
                becomes *critical*.
        """
        self.target_angles = target_angles or {}
        self.warning_threshold = warning_threshold
        self.critical_threshold = critical_threshold

    # ── public API ──────────────────────────────────────────────

    def compute_joint_angles(self, pose_frame: PoseFrame) -> list[JointAngle]:
        """Compute signed angles for every joint in ``JOINT_MAP``.

        Args:
            pose_frame: A frame containing detected landmarks.

        Returns:
            List of ``JointAngle`` models (one per trackable joint).
            Joints whose landmarks are missing are silently skipped.
        """
        angles: list[JointAngle] = []

        for joint_name, (base_idx, vertex_idx, end_idx, _side_sign) in JOINT_MAP.items():
            angle = calculate_angle(pose_frame, joint_name)
            if angle is None:
                continue

            angles.append(
                JointAngle(
                    joint_name=joint_name,
                    angle_degrees=round(angle, 2),
                    base_landmark=LANDMARK_NAMES.get(base_idx, f"landmark_{base_idx}"),
                    vertex_landmark=LANDMARK_NAMES.get(vertex_idx, f"landmark_{vertex_idx}"),
                    end_landmark=LANDMARK_NAMES.get(end_idx, f"landmark_{end_idx}"),
                )
            )

        return angles

    def generate_corrections(
        self,
        joint_angles: list[JointAngle],
    ) -> list[ExerciseCorrection]:
        """Compare measured angles to targets and emit corrections.

        Only joints that appear in ``self.target_angles`` are checked.

        Args:
            joint_angles: The angles computed for the current frame.

        Returns:
            List of ``ExerciseCorrection`` objects for joints that
            deviate from their target.
        """
        if not self.target_angles:
            return []

        corrections: list[ExerciseCorrection] = []

        for ja in joint_angles:
            target = self.target_angles.get(ja.joint_name)
            if target is None:
                continue

            deviation = ja.angle_degrees - target
            abs_dev = abs(deviation)

            if abs_dev < 5.0:
                # Within acceptable tolerance — no correction needed
                continue

            severity = self._classify_severity(abs_dev)
            message = self._build_message(ja.joint_name, deviation, abs_dev)

            corrections.append(
                ExerciseCorrection(
                    joint_name=ja.joint_name,
                    current_angle=ja.angle_degrees,
                    target_angle=target,
                    deviation=round(deviation, 2),
                    message=message,
                    severity=severity,
                )
            )

        return corrections

    def build_tracking_frame(self, pose_frame: PoseFrame) -> TrackingFrame:
        """Build a complete ``TrackingFrame`` from raw pose data.

        This is the main entry-point: give it a ``PoseFrame`` and get
        back a fully populated payload ready for JSON serialisation.

        Args:
            pose_frame: Raw frame from the body tracker.

        Returns:
            A ``TrackingFrame`` containing joint angles and corrections.
        """
        joint_angles = self.compute_joint_angles(pose_frame)
        corrections = self.generate_corrections(joint_angles)

        return TrackingFrame(
            frame_number=pose_frame.frame_number,
            timestamp_ms=pose_frame.timestamp_ms,
            joint_angles=joint_angles,
            corrections=corrections,
            pose_detected=pose_frame.has_pose,
        )

    # ── private helpers ─────────────────────────────────────────

    def _classify_severity(self, abs_deviation: float) -> str:
        if abs_deviation >= self.critical_threshold:
            return "critical"
        if abs_deviation >= self.warning_threshold:
            return "warning"
        return "info"

    @staticmethod
    def _build_message(joint_name: str, deviation: float, abs_dev: float) -> str:
        direction = "more" if deviation < 0 else "less"
        return f"Adjust {joint_name}: bend {direction} by ~{abs_dev:.0f}°"
