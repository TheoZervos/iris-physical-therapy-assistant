import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:frontend/models/tracking_models/exercise_correction.dart';

class ExerciseTrackingFrame {
  final Pose pose;
  final String facing;
  final String curSide;
  final Map<String, double> curAngles;
  final Map<String, double> badAngles;
  final bool inPosition;
  final List<ExerciseCorrection> corrections;

  ExerciseTrackingFrame({
    required this.pose,
    required this.facing,
    required this.curSide,
    required this.curAngles,
    required this.badAngles,
    required this.inPosition,
    required this.corrections,
  });
}
