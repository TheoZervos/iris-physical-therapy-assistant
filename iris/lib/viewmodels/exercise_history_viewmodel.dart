import "package:flutter/material.dart";
import "../models/exercise_history.dart";
import "../models/exercise_session.dart";
import "../services/exercise_services.dart";

class ExerciseHistoryViewModel extends ChangeNotifier {
  late final ExerciseHistory exerciseHistory;

  Future<void> fetchPastExerciseSessions(String jsonFilePath) async {
    final List<ExerciseSession> sessionHistory = await ExerciseService()
        .fetchExerciseSessionHistory(jsonFilePath);

    exerciseHistory = ExerciseHistory(exerciseSessions: sessionHistory);
    notifyListeners();
  }

  void removeSession(ExerciseSession session) {
    exerciseHistory.removeSession(session);
    notifyListeners();
  }

  void addSession(ExerciseSession session) {
    exerciseHistory.addSession(session);
    notifyListeners();
  }

  void clearHistory() {
    exerciseHistory.clearHistory();
    notifyListeners();
  }
}
