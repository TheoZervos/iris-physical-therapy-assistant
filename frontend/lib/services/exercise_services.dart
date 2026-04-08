import 'dart:convert';
import 'package:frontend/models/models_lib.dart';
import 'package:flutter/services.dart';
import 'package:frontend/viewmodels/viewmodels_lib.dart';

class ExerciseService {
  Future<Map<String, dynamic>> fetchExercises(String jsonFilePath) async {
    final String fileContents = await rootBundle.loadString(jsonFilePath);
    final Map<String, dynamic> json = jsonDecode(fileContents);

    // nothing in file
    if (json.isEmpty) {
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
        final ExerciseViewModel exercise = ExerciseViewModel(Exercise.fromJson(exerciseData));
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
  }

  Future<List<ExerciseSession>> fetchExerciseSessionHistory(
    String jsonFilePath,
  ) async {
    final String fileContents = await rootBundle.loadString(jsonFilePath);
    final Map<String, dynamic> json = jsonDecode(fileContents);

    return (json['exerciseSessions'] ?? [])
        .map<ExerciseSession>(
          (sessionData) => ExerciseSession.fromJson(sessionData),
        )
        .toList();
  }

  Future<void> saveExerciseSessionHistory(
    List<ExerciseSession> sessions,
    String jsonFilePath,
  ) async {
    // open file
    // write sessions to file
    // format session to json
  }
}
