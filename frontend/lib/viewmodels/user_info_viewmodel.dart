import 'package:flutter/cupertino.dart';
import 'package:frontend/viewmodels/viewmodels_lib.dart';

class UserInfoViewModel extends ChangeNotifier {
  late final ExerciseHistoryViewModel exerciseHistory;
  late final ExerciseListViewModel likedExercises;
  String _name = "";

  Future<void> fetchuserInfo(String folderPath) async {
    final ExerciseHistoryViewModel exerciseHistory = ExerciseHistoryViewModel();
    final ExerciseListViewModel likedExercises = ExerciseListViewModel();
    await exerciseHistory.fetchPastExerciseSessions(
      "$folderPath/exercise_history.json",
    );
    await likedExercises.fetchExercises("$folderPath/liked_exercises.json");
    notifyListeners();
  }

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  String get name => _name;
}
