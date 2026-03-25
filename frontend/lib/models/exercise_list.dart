import 'package:frontend/models/exercise.dart';

class ExerciseList {
  final List<Exercise> exercises;
  final Map<String, List<Exercise>> exercisesByMuscleRegion;
  final List<String> filters;

  ExerciseList({
    this.exercises = const [],
    this.exercisesByMuscleRegion = const {},
    this.filters = const [],
  });
}
