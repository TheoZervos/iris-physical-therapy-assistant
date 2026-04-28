import "package:flutter/material.dart";
import "viewmodels_lib.dart";

class AppStateViewModel extends ChangeNotifier {
  bool _isInitialized = false;
  late final UserInfoViewModel userInfo;
  late final ExerciseListViewModel allExercises;

  bool get isInitialized => _isInitialized;

  Future<void> loadAppState() async {
    userInfo = UserInfoViewModel();
    allExercises = ExerciseListViewModel();

    try {
      await userInfo.fetchUserInfo();
    } catch (e) {
      debugPrint("User info failed to load: $e");
    }

    try {
      await allExercises.fetchExercises('assets/all_exercises.json');
    } catch (e) {
      debugPrint("Exercises failed to load: $e");
    }

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> saveUserInfoToJson() async {
    await userInfo.saveUserInfoToJson();
    notifyListeners();
  }

  Future<void> addExerciseToFavorites(ExerciseViewModel exercise) async {
    userInfo.favoriteExercises.exerciseList.add(exercise);
    await userInfo.saveUserInfoToJson();
    debugPrint("Added exercise to liked list");
  }
}
