import 'package:frontend/core/mapping_constants.dart';
import 'package:frontend/models/tracking_models/exercise_tracking_frame.dart';

class FormattedTrackingFeedback {
  final String exerciseId;
  final String correctionMessage;
  final String severity;
  final Duration timestamp;

  FormattedTrackingFeedback({
    required this.exerciseId,
    required this.correctionMessage,
    required this.severity,
    required this.timestamp,
  });
}
