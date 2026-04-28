import 'package:flutter/material.dart';
import 'viewmodels_lib.dart';
import '../services/exercise_services.dart';
import 'package:path_provider/path_provider.dart';

class UserInfoViewModel extends ChangeNotifier {
  late final ExerciseHistoryViewModel exerciseHistory;
  late final ExerciseListViewModel favoriteExercises;
  String _name = "";

  Future<void> fetchUserInfo() async {
    final localPath = await getApplicationDocumentsDirectory();
    exerciseHistory = ExerciseHistoryViewModel();
    favoriteExercises = ExerciseListViewModel();
    try {
      await exerciseHistory.fetchPastExerciseSessions(
        "${localPath.path}/exercise_history.json",
      );
    } catch (e) {
      debugPrint("Could not load exercise history");
    }

    try {
      await favoriteExercises.fetchLikedExercises(
        "${localPath.path}/favorite_exercises.json",
      );
    } catch (e) {
      debugPrint("Could not load liked exercises");
    }
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
