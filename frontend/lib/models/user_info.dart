import 'package:frontend/models/exercise_history.dart';
import 'package:frontend/models/exercise_list.dart';

class UserInfo {
  final ExerciseHistory exerciseHistory;
  final ExerciseList favoriteExercises;
  final String name;

  UserInfo({
    required this.exerciseHistory,
    required this.favoriteExercises,
    required this.name,
  });
}
