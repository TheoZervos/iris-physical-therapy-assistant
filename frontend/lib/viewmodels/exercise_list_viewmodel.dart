import "package:flutter/cupertino.dart";
import "package:frontend/models/models_lib.dart";
import "package:frontend/viewmodels/viewmodels_lib.dart";
import "package:frontend/services/exercise_services.dart";

class ExerciseListViewModel extends ChangeNotifier {
  late final ExerciseList exerciseList;
  final Map<String, dynamic> filters = {"filters": {}};

  Future<void> fetchExercises(String jsonFilePath) async {
    final results = await ExerciseService().fetchExercises(jsonFilePath);

    // empty exercise list
    if (results['exercises'].isEmpty) {
      exerciseList = ExerciseList(exerciseList: [], exerciseByRegion: {});
      notifyListeners();
      return;
    }

    // building list of exercises
    List<Exercise> exercises = results['exercises'];

    // building muscle regions list
    Map<String, List<Exercise>> exercisesByMuscleRegion = {};
    for (final Exercise exercise in exercises) {
      for (final String muscleGroup in exercise.muscleRegions) {
        if (!exercisesByMuscleRegion.containsKey(muscleGroup)) {
          exercisesByMuscleRegion[muscleGroup] = [];
        }
        exercisesByMuscleRegion[muscleGroup]!.add(exercise);
      }
    }

    // creating exercise list object
    exerciseList = ExerciseList(
      exerciseList: exercises,
      exerciseByRegion: exercisesByMuscleRegion,
    );
    notifyListeners();
  }

  List<ExerciseViewModel> search(String searchQuery) {
    List<Exercise> exercises = exerciseList.search(searchQuery);
    return exercises.map((e) => ExerciseViewModel(exercise: e)).toList();
  }

  // private void applyFilters() {}
  // void addFilter(filter) {}
  // void removeFilter(filter) {}

  void clearFilters() {
    filters['filters'].clear();
    notifyListeners();
  }
}
