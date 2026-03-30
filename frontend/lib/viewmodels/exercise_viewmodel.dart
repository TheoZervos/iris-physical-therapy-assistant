import 'package:frontend/models/exercise.dart';

class ExerciseViewModel {
  final Exercise exercise;

  ExerciseViewModel({required this.exercise});

  String get exerciseName => exercise.exerciseName;
  String get tutorialLink => exercise.tutorialLink;
  String get exerciseDescription => exercise.exerciseDescription;
  List<String> get exerciseImages => exercise.exerciseImages;
  String get exerciseId => exercise.exerciseId;
  List<String> get exerciseAliases => exercise.exerciseAliases;
  String get muscleRegion => exercise.muscleRegion;
  bool get isFavorite => exercise.isFavorite;

  void toggleExerciseFavorite() {
    exercise.isFavorite = !exercise.isFavorite;
  }
}
