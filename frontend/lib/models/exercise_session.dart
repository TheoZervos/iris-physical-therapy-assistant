import 'package:frontend/models/exercise.dart';
import 'package:frontend/models/session_analytics.dart';

class ExerciseSession {
  final Duration sessionLength;
  final Exercise sessionExercise;
  final DateTime date;
  final SessionAnalytics analytics;
  // Do not need to grab the session status as flutter will not
  // be handling session status directly, instead receiving ExerciseSession
  // info from python endpoint

  ExerciseSession({
    required this.sessionLength,
    required this.sessionExercise,
    required this.date,
    required this.analytics,
  });
}
