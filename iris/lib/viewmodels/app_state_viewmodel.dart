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

    // ensure no copies
    for (int i = 0; i < userInfo.favoriteExercises.exerciseList.length; i++) {
      var favorite = userInfo.favoriteExercises.exerciseList[i];
      if (allExercises.exerciseList.contains(favorite)) {
        userInfo.favoriteExercises.exerciseList[i] = allExercises.exerciseList.firstWhere((element) => element == favorite);
      }
    }

    debugPrint(userInfo.toString());

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> saveUserInfoToJson() async {
    debugPrint("Saving user history to history file");
    await userInfo.saveUserInfoToJson();
    notifyListeners();
  }

  bool exerciseIsFavorite(ExerciseViewModel exercise) {
    return userInfo.favoriteExercises.exerciseList.contains(exercise);
  }

  Future<void> addExerciseToFavorites(ExerciseViewModel exercise) async {
    userInfo.favoriteExercises.exerciseList.add(exercise);
    await userInfo.saveUserInfoToJson();
    notifyListeners();
    debugPrint("Added exercise to liked list");
  }

  Future<void> removeExerciseFromFavorites(ExerciseViewModel exercise) async {
    userInfo.favoriteExercises.exerciseList.remove(exercise);
    await userInfo.saveUserInfoToJson();
    notifyListeners();
    debugPrint("Removed exercise from liked list");
  }
}
