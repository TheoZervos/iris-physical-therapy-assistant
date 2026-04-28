import "package:flutter/material.dart";
import "../models/exercise_history.dart";
import "../models/exercise_session.dart";
import "../services/exercise_services.dart";

class ExerciseHistoryViewModel extends ChangeNotifier {
  late final ExerciseHistory exerciseHistory;

  Future<void> fetchPastExerciseSessions() async {
    List<ExerciseSession> results;
    try {
      results = await ExerciseService().fetchExerciseSessionHistory();
    } catch (e) {
      debugPrint("Error reading exercise history: $e");
      exerciseHistory = ExerciseHistory(exerciseSessions: <ExerciseSession>[]);
      notifyListeners();
      return;
    }

    // empty exercise list
    if (results.isEmpty) {
      debugPrint("Empty exercise history file");
      exerciseHistory = ExerciseHistory(exerciseSessions: <ExerciseSession>[]);
      notifyListeners();
      return;
    }

    exerciseHistory = ExerciseHistory(exerciseSessions: results);
    notifyListeners();
    return;
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
