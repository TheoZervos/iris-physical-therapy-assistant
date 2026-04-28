import '../models/models_lib.dart';

class ExerciseSessionViewModel {
  final ExerciseSession exerciseSession;

  ExerciseSessionViewModel({required this.exerciseSession});

  // Below will likely make api calls
  // void startSession() {}
  // void pauseSession() {}
  // void endSession() {}
  // void abandonSession() {}
  // void saveToHistory() {}

  // Getters
  Duration get sessionLength => exerciseSession.sessionLength;
  Exercise get sessionExercise => exerciseSession.sessionExercise;
  DateTime get date => exerciseSession.date;
  SessionAnalytics get analytics => exerciseSession.analytics;
}
