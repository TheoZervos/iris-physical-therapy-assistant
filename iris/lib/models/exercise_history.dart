import "exercise_session.dart";

class ExerciseHistory {
  late final List<ExerciseSession> exerciseSessions;

  ExerciseHistory({required this.exerciseSessions});

  void removeSession(ExerciseSession session) {
    exerciseSessions.remove(session);
  }

  void addSession(ExerciseSession session) {
    exerciseSessions.insert(0, session);
  }

  void clearHistory() {
    exerciseSessions.clear();
  }
}
