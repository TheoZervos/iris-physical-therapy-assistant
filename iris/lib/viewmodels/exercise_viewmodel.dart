import 'package:flutter/material.dart';
import '../models/exercise.dart';

class ExerciseViewModel extends ChangeNotifier {
  final Exercise exercise;

  ExerciseViewModel(this.exercise);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseViewModel &&
      exercise == other.exercise;
  }

  get exerciseName => exercise.exerciseName;
  get tutorialLink => exercise.tutorialLink;
  get exerciseDescription => exercise.exerciseDescription;
  get assetsFolder => exercise.assetsFolder;
  get exerciseId => exercise.exerciseId;
  get exerciseAliases => exercise.exerciseAliases;
  get isFavorite => exercise.isFavorite;
  get muscleRegions => exercise.muscleRegions;
}
