import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/models_lib.dart';
import 'package:flutter/services.dart';
import '../viewmodels/viewmodels_lib.dart';

class ExerciseService {
  Future<Map<String, dynamic>> fetchExercises(String jsonFilePath) async {
    final String fileContents = await rootBundle.loadString(jsonFilePath);
    final Map<String, dynamic> json = jsonDecode(fileContents);

    try {
      // nothing in file
      if (json == null || json.isEmpty) {
        return {'exercises': [], 'exercisesByMuscleRegion': {}};
      }

      // getting exercises
      final List<Exercise> exercises = (json['exercises'] ?? [])
          .map<Exercise>((exerciseData) => Exercise.fromJson(exerciseData))
          .toList();
      final Map<String, List<ExerciseViewModel>> muscleGroupedExercises = {};

      // grouping exercises by muscle region
      if (exercises.isNotEmpty) {
        for (final Map<String, dynamic> exerciseData
            in (json['exercises'] ?? [])) {
          final ExerciseViewModel exercise = ExerciseViewModel(
            Exercise.fromJson(exerciseData),
          );
          final List<String> muscleGroups = exercise.muscleRegions;

          for (final String muscleGroup in muscleGroups) {
            if (!muscleGroupedExercises.containsKey(muscleGroup)) {
              muscleGroupedExercises[muscleGroup] = [];
            }
            muscleGroupedExercises[muscleGroup]!.add(exercise);
          }
        }
      }

      return {
        'exercises': exercises,
        'exercisesByMuscleRegion': muscleGroupedExercises,
      };
    } catch (e) {
      debugPrint('Error parsing exercises: $e');
      return {'exercises': [], 'exercisesByMuscleRegion': {}};
    }
  }

  Future<Map<String, dynamic>> fetchFavoriteExercises() async {
    try {
      final path = await _getLocalPath();
      final localFile = File("$path/favorite_exercises.json");

      if (!await localFile.exists()) {
        debugPrint("Liked exercises file not found, returning empty list.");
        return {'exercises': [], 'exercisesByMuscleRegion': {}};
      }

      final String fileContents = await localFile.readAsString();
      final Map<String, dynamic> json = jsonDecode(fileContents);

      // nothing in file
      if (json == null || json.isEmpty) {
        return {'exercises': [], 'exercisesByMuscleRegion': {}};
      }

      // getting exercises
      final List<Exercise> exercises = (json['exercises'] ?? [])
          .map<Exercise>((exerciseData) => Exercise.fromJson(exerciseData))
          .toList();
      final Map<String, List<ExerciseViewModel>> muscleGroupedExercises = {};

      // grouping exercises by muscle region
      if (exercises.isNotEmpty) {
        for (final Map<String, dynamic> exerciseData
            in (json['exercises'] ?? [])) {
          final ExerciseViewModel exercise = ExerciseViewModel(
            Exercise.fromJson(exerciseData),
          );
          final List<String> muscleGroups = exercise.muscleRegions;

          for (final String muscleGroup in muscleGroups) {
            if (!muscleGroupedExercises.containsKey(muscleGroup)) {
              muscleGroupedExercises[muscleGroup] = [];
            }
            muscleGroupedExercises[muscleGroup]!.add(exercise);
          }
        }
      }

      return {
        'exercises': exercises,
        'exercisesByMuscleRegion': muscleGroupedExercises,
      };
    } catch (e) {
      debugPrint('Error parsing exercises: $e');
      return {'exercises': [], 'exercisesByMuscleRegion': {}};
    }
  }

  Future<List<ExerciseSession>> fetchExerciseSessionHistory() async {
    try {
      final path = await _getLocalPath();
      final localFile = File('$path/exercise_history.json');

      // no file
      if (!await localFile.exists()) {
        debugPrint("History file not found, returning empty list.");
        return [];
      }

      final String fileContents = await localFile.readAsString();
      final Map<String, dynamic> json = jsonDecode(fileContents);

      // nothing in file
      if (json == null || json.isEmpty) {
        return [];
      }

      return (json['exerciseSessions'] ?? [])
          .map<ExerciseSession>(
            (sessionData) => ExerciseSession.fromJson(sessionData),
          )
          .toList();
    } catch (e) {
      debugPrint('Error parsing exercise session history: $e');
      return [];
    }
  }

  Future<void> saveUserData(
    List<ExerciseViewModel> exercises,
    Map<String, List<ExerciseViewModel>> exercisesByMuscleRegion,
    List<ExerciseSession> exerciseSessions,
  ) async {
    try {
      final path = await _getLocalPath();
      final favoritesFile = File('$path/favorite_exercises.json');
      final historyFile = File('$path/exercise_history.json');

      //saving favorites
      final contents = jsonEncode({
        'exercises': exercises.map((e) => e.exercise.toJson()).toList(),
        'exercisesByMuscleRegion': exercisesByMuscleRegion.map(
          (muscle, exercises) => MapEntry(
            muscle,
            exercises.map((e) => e.exercise.toJson()).toList(),
          ),
        ),
      });
      await favoritesFile.writeAsString(contents);

      //saving history
      final historyContents = jsonEncode({
        'exerciseSessions': exerciseSessions.map((s) => s.toJson()).toList(),
      });
      await historyFile.writeAsString(historyContents);
    } catch (e) {
      debugPrint('Error accessing local files: $e');
      return;
    }
  }

  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
