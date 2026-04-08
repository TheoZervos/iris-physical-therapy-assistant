import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/viewmodels_lib.dart';

class UserInfoViewModel extends ChangeNotifier {
  late final ExerciseHistoryViewModel exerciseHistory;
  late final ExerciseListViewModel favoriteExercises;
  String _name = "";

  Future<void> fetchUserInfo(String folderPath) async {
    exerciseHistory = ExerciseHistoryViewModel();
    favoriteExercises = ExerciseListViewModel();
    await exerciseHistory.fetchPastExerciseSessions(
      "$folderPath/exercise_history.json",
    );
    await favoriteExercises.fetchExercises(
      "$folderPath/favorite_exercises.json",
    );
    notifyListeners();
  }

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  String get name => _name;
}
