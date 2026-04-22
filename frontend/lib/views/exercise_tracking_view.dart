import 'package:camera/camera.dart';
import 'package:frontend/viewmodels/app_state_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:frontend/viewmodels/viewmodels_lib.dart';
import 'package:frontend/widgets/exercise_tracking_preview.dart';

class ExerciseTrackingView extends StatefulWidget {
  final ExerciseViewModel exercise;
  const ExerciseTrackingView({super.key, required this.exercise});

  @override
  State<ExerciseTrackingView> createState() => _ExerciseTrackingViewState();
}

class _ExerciseTrackingViewState extends State<ExerciseTrackingView> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Tracking ${widget.exercise.exerciseName}"),
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
      ),
      body: Center(
        child: ExerciseTrackingPreview(camera: appState.frontCamera),
        ),
    );
  }
}
