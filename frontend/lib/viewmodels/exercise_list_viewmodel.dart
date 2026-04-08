import "package:flutter/material.dart";
import 'package:frontend/viewmodels/exercise_viewmodel.dart';
import "package:frontend/services/exercise_services.dart";

class ExerciseListViewModel extends ChangeNotifier {
  late final List<ExerciseViewModel> exerciseList;
  late final Map<String, List<ExerciseViewModel>> exerciseByRegion;
  final Map<String, dynamic> filters = {"filters": {}};

  Future<void> fetchExercises(String jsonFilePath) async {
    final results = await ExerciseService().fetchExercises(jsonFilePath);

    // empty exercise list
    if (results['exercises'].isEmpty) {
      exerciseList = <ExerciseViewModel>[];
      exerciseByRegion = <String, List<ExerciseViewModel>>{};
      notifyListeners();
      return;
    }

    // creating exercise list object
    exerciseList = results['exercises']
        .map<ExerciseViewModel>((exercise) => ExerciseViewModel(exercise))
        .toList();
    exerciseByRegion = results['exercisesByMuscleRegion'];
    notifyListeners();
    return;
  }

  void addExercise(ExerciseViewModel exercise) {
    exerciseList.add(exercise);
    for (final String muscleRegion in exercise.muscleRegions) {
      if (exerciseByRegion.containsKey(muscleRegion)) {
        exerciseByRegion[muscleRegion]!.add(exercise);
      } else {
        exerciseByRegion[muscleRegion] = [exercise];
      }
    }
    notifyListeners();
  }

  void removeExercise(ExerciseViewModel exercise) {
    exerciseList.remove(exercise);
    for (final String muscleRegion in exercise.muscleRegions) {
      exerciseByRegion[muscleRegion]?.remove(exercise);
    }
    notifyListeners();
  }

  void clearExercises() {
    exerciseList.clear();
    exerciseByRegion.clear();
    notifyListeners();
  }

  List<ExerciseViewModel> search(String query) {
    List<ExerciseViewModel> directResults = exerciseList
        .where((exercise) => exercise.exerciseName.contains(query))
        .toList();

    List<ExerciseViewModel> indirectResults = exerciseList
        .where(
          (exercise) =>
              exercise.exerciseAliases.any((alias) => alias.contains(query)),
        )
        .toList();
    notifyListeners();
    return directResults + indirectResults;
  }

  // private void applyFilters() {}
  // void addFilter(filter) {}
  // void removeFilter(filter) {}

  void clearFilters() {
    filters['filters'].clear();
    notifyListeners();
  }
}
