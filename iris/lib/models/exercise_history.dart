import "exercise_session.dart";
import "../services/exercise_services.dart";

class ExerciseHistory {
  late final List<ExerciseSession> exerciseSessions;

  ExerciseHistory({required this.exerciseSessions});

  void removeSession(ExerciseSession session) {
    exerciseSessions.remove(session);
  }

  void addSession(ExerciseSession session) {
    exerciseSessions.add(session);
  }

  void clearHistory() {
    exerciseSessions.clear();
  }
}
