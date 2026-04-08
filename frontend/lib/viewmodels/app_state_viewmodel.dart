import "package:flutter/material.dart";
import "package:frontend/viewmodels/viewmodels_lib.dart";

class AppStateViewModel extends ChangeNotifier {
  late final UserInfoViewModel userInfo;
  late final ExerciseListViewModel allExercises;

  Future<void> loadAppState(
    String userInfoFolderPath,
    String exerciseListFilePath,
  ) async {
    userInfo = UserInfoViewModel();
    allExercises = ExerciseListViewModel();
    await userInfo.fetchUserInfo(userInfoFolderPath);
    await allExercises.fetchExercises(exerciseListFilePath);
    notifyListeners();
  }
}
