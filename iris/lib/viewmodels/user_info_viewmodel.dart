import 'package:flutter/material.dart';
import 'viewmodels_lib.dart';
import '../services/exercise_services.dart';
import 'package:path_provider/path_provider.dart';

class UserInfoViewModel extends ChangeNotifier {
  late final ExerciseHistoryViewModel exerciseHistory;
  late final ExerciseListViewModel favoriteExercises;

  Future<void> fetchUserInfo() async {
    exerciseHistory = ExerciseHistoryViewModel();
    favoriteExercises = ExerciseListViewModel();
    try {
      await exerciseHistory.fetchPastExerciseSessions();
    } catch (e) {
      debugPrint("Could not load exercise history");
    }

    try {
      await favoriteExercises.fetchLikedExercises();
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
}
