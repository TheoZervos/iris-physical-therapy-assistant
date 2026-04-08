import 'package:frontend/models/exercise.dart';
import 'package:frontend/models/session_analytics.dart';

class ExerciseSession {
  final Duration sessionLength;
  final Exercise sessionExercise;
  final DateTime date;
  final SessionAnalytics analytics;
  // Do not need to grab the session status as flutter will not
  // be handling session status directly, instead receiving ExerciseSession
  // info from python endpoint once session is over

  ExerciseSession({
    required this.sessionLength,
    required this.sessionExercise,
    required this.date,
    required this.analytics,
  });

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      sessionLength: Duration(seconds: json['sessionLength']),
      sessionExercise: Exercise.fromJson(json['sessionExercise']),
      date: DateTime.parse(json['date']),
      analytics: SessionAnalytics.fromJson(json['analytics']),
    );
  }
}
