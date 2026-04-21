import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:frontend/viewmodels/viewmodels_lib.dart";

class AppStateViewModel extends ChangeNotifier {
  bool _isInitialized = false;
  late final UserInfoViewModel userInfo;
  late final ExerciseListViewModel allExercises;
  static late final CameraDescription frontCamera;

  bool get isInitialized => _isInitialized;

  Future<void> loadAppState() async {
    userInfo = UserInfoViewModel();
    allExercises = ExerciseListViewModel();
    await userInfo.fetchUserInfo();
    await allExercises.fetchExercises('assets/all_exercises.json');
    await availableCameras().then((cameras) {
      frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    });
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
  }
}
