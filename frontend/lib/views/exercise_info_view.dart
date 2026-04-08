import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/viewmodels_lib.dart';
import 'package:flutter/services.dart';
import 'package:frontend/widgets/exercise_info.dart';

class ExerciseInfoView extends StatelessWidget {
  final ExerciseViewModel exercise;
  final ExerciseListViewModel favoriteExercises;
  const ExerciseInfoView({super.key, required this.exercise, required this.favoriteExercises});

  Future<List<String>> _loadImages() async {
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestJson);

    return manifestMap.keys
        .where((String key) => key.startsWith(exercise.assetsFolder))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _loadImages(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return const Placeholder();
        }
        return ExerciseInfo(
          images: snapshot.data != null ? snapshot.data! : [],
          exercise: exercise,
          favoriteExercises: favoriteExercises,
        );
      },
    );
  }
}
