import '../../core/mapping_constants.dart';
import 'exercise_tracking_frame.dart';

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
