import "package:flutter/cupertino.dart";
import "package:frontend/models/models_lib.dart";
import "package:frontend/viewmodels/viewmodels_lib.dart";
import "package:frontend/services/exercise_services.dart";

class ExerciseListViewModel extends ChangeNotifier {
  late final ExerciseList exerciseList;
  final Map<String, dynamic> filters = {"filters": {}};

  Future<void> fetchExercises(String jsonFilePath) async {
    final results = await ExerciseService().fetchExercises(jsonFilePath);
    final exercisesByMuscleRegion =
        results['exercisesByMuscleRegion'] as Map<String, List<Exercise>>;
    exerciseList = ExerciseList(
      exerciseList: results['exercises'] as List<Exercise>,
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
