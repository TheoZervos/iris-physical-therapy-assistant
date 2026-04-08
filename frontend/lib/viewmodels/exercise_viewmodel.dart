import 'package:flutter/material.dart';
import 'package:frontend/models/exercise.dart';

class ExerciseViewModel extends ChangeNotifier {
  final Exercise exercise;

  ExerciseViewModel(this.exercise);

  get exerciseName => exercise.exerciseName;
  get tutorialLink => exercise.tutorialLink;
  get exerciseDescription => exercise.exerciseDescription;
  get assetsFolder => exercise.assetsFolder;
  get exerciseId => exercise.exerciseId;
  get exerciseAliases => exercise.exerciseAliases;
  get isFavorite => exercise.isFavorite;
  get muscleRegions => exercise.muscleRegions;

  void toggleFavorite() {
    exercise.isFavorite = !exercise.isFavorite;
    notifyListeners();
  }
}
