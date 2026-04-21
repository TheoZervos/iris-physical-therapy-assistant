import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/viewmodels_lib.dart';
import 'package:frontend/services/exercise_services.dart';
import 'package:path_provider/path_provider.dart';

class UserInfoViewModel extends ChangeNotifier {
  late final ExerciseHistoryViewModel exerciseHistory;
  late final ExerciseListViewModel favoriteExercises;
  String _name = "";

  Future<void> fetchUserInfo() async {
    final localPath = await getApplicationDocumentsDirectory();
    exerciseHistory = ExerciseHistoryViewModel();
    favoriteExercises = ExerciseListViewModel();
    await exerciseHistory.fetchPastExerciseSessions(
      "${localPath.path}/exercise_history.json",
    );
    await favoriteExercises.fetchLikedExercises(
      "${localPath.path}/favorite_exercises.json",
    );
    notifyListeners();
  }

  Future<void> saveUserInfoToJson() async {
    await ExerciseService().saveUserData(
      favoriteExercises.exerciseList,
      favoriteExercises.exerciseByRegion,
      exerciseHistory.exerciseHistory.exerciseSessions,
    );
    notifyListeners();
  }

  void setName(String newName) {
    _name = newName;
    notifyListeners();
  }

  String get name => _name;
}
