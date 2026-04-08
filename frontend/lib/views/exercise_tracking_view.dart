import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/viewmodels_lib.dart';
import 'package:frontend/views/views_lib.dart';

class ExerciseTrackingView extends StatefulWidget {
  final ExerciseViewModel exercise;
  const ExerciseTrackingView({super.key, required this.exercise});

  @override
  State<ExerciseTrackingView> createState() => _ExerciseTrackingViewState();
}

class _ExerciseTrackingViewState extends State<ExerciseTrackingView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exercise Tracking"),
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
      body: Center(
        child: Text("Tracking ${widget.exercise.exerciseName}"),
      ),
    );
  }
}