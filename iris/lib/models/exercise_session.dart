import 'exercise.dart';

class ExerciseSession {
  final Duration sessionLength;
  final Exercise sessionExercise;
  final DateTime date;

  ExerciseSession({
    required this.sessionLength,
    required this.sessionExercise,
    required this.date,
  });

  factory ExerciseSession.fromJson(Map<String, dynamic> json) {
    return ExerciseSession(
      sessionLength: Duration(seconds: json['sessionLength']),
      sessionExercise: Exercise.fromJson(json['sessionExercise']),
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionLength': sessionLength.inSeconds,
      'sessionExercise': sessionExercise.toJson(),
      'date': date.toIso8601String(),
    };
  }
}
