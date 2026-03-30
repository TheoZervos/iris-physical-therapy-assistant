import "package:frontend/models/exercise.dart";

class ExerciseList {
  final List<Exercise> exerciseList;
  final Map<String, List<Exercise>> exerciseByRegion;

  ExerciseList({required this.exerciseList, required this.exerciseByRegion});

  void addExercise(Exercise exercise) {
    exerciseList.add(exercise);
    if (exerciseByRegion.containsKey(exercise.muscleRegion)) {
      exerciseByRegion[exercise.muscleRegion]!.add(exercise);
    } else {
      exerciseByRegion[exercise.muscleRegion] = [exercise];
    }
  }

  void removeExercise(Exercise exercise) {
    exerciseList.remove(exercise);
    exerciseByRegion[exercise.muscleRegion]?.remove(exercise);
  }

  void clearExercises() {
    exerciseList.clear();
    exerciseByRegion.clear();
  }

  List<Exercise> search(String query) {
    List<Exercise> directResults = exerciseList
        .where((exercise) => exercise.exerciseName.contains(query))
        .toList();

    List<Exercise> indirectResults = exerciseList
        .where(
          (exercise) =>
              exercise.exerciseAliases.any((alias) => alias.contains(query)),
        )
        .toList();

    return directResults + indirectResults;
  }
}
