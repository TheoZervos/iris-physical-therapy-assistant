import 'dart:convert';
import 'package:frontend/models/models_lib.dart';
import 'package:flutter/services.dart';

class ExerciseService {
  Future<Map<String, dynamic>> fetchExercises(String jsonFilePath) async {
    final String fileContents = await rootBundle.loadString(jsonFilePath);
    final Map<String, dynamic> json = jsonDecode(fileContents);

    final Map<String, List<Exercise>> muscleGroupedExercises = {};

    for (final Map<String, dynamic> exerciseData in json['exercises']) {
      final Exercise exercise = Exercise.fromJson(exerciseData);
      final String muscleGroup = exercise.muscleRegion;

      if (!muscleGroupedExercises.containsKey(muscleGroup)) {
        muscleGroupedExercises[muscleGroup] = [];
      }
      muscleGroupedExercises[muscleGroup]!.add(exercise);
    }

    return {
      'exercises': json['exercises'],
      'exercisesByMuscleRegion': muscleGroupedExercises
    };
  }

  Future<List<ExerciseSession>> fetchExerciseSessionHistory(String jsonFilePath) async {
    final String fileContents = await rootBundle.loadString(jsonFilePath);
    final Map<String, dynamic> json = jsonDecode(fileContents);
    return json['exerciseSessions'].map<ExerciseSession>((sessionData) => ExerciseSession.fromJson(sessionData)).toList();
  }

  Future<void> saveExerciseSessionHistory(List<ExerciseSession> sessions, String jsonFilePath) async {
    // open file
    // write sessions to file
      // format session to json 
  }
}