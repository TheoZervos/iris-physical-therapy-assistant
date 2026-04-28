import 'exercise.dart';
import 'session_analytics.dart';

class ExerciseSession {
  final Duration sessionLength;
  final Exercise sessionExercise;
  final DateTime date;
  final SessionAnalytics analytics;

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

  Map<String, dynamic> toJson() {
    return {
      'sessionLength': sessionLength.inSeconds,
      'sessionExercise': sessionExercise.toJson(),
      'date': date.toIso8601String(),
      'analytics': analytics.analytics,
    };
  }
}
