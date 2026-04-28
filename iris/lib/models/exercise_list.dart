import "exercise.dart";

class ExerciseList {
  final List<Exercise> exerciseList;
  final Map<String, List<Exercise>> exerciseByRegion;

  ExerciseList({required this.exerciseList, required this.exerciseByRegion});

  void addExercise(Exercise exercise) {
    exerciseList.add(exercise);
    for (final String muscleRegion in exercise.muscleRegions) {
      if (exerciseByRegion.containsKey(muscleRegion)) {
        exerciseByRegion[muscleRegion]!.add(exercise);
      } else {
        exerciseByRegion[muscleRegion] = [exercise];
      }
    }
  }

  void removeExercise(Exercise exercise) {
    exerciseList.remove(exercise);
    for (final String muscleRegion in exercise.muscleRegions) {
      exerciseByRegion[muscleRegion]?.remove(exercise);
    }
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
