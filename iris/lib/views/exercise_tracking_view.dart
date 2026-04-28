import 'package:camera/camera.dart';
import '../main.dart';
import '../models/tracking_models/exercise_specifications.dart';
import '../service_locator.dart';
import 'views_lib.dart';
import '../widgets/exercise_feedback_overlay.dart';
import 'package:flutter/material.dart';
import '../viewmodels/viewmodels_lib.dart';
import '../widgets/exercise_tracking_preview.dart';
import '../models/tracking_models/formatted_tracking_feedback.dart';
import 'package:provider/provider.dart';

class ExerciseTrackingView extends StatefulWidget {
  final ExerciseViewModel exercise;
  final Map<String, ExerciseSpecifications> specs;
  final Map<String, dynamic> corrections;
  final Map<String, List<int>> jointMap;
  final Map<String, List<int>> bodyVecMap;

  const ExerciseTrackingView({
    super.key,
    required this.exercise,
    required this.specs,
    required this.corrections,
    required this.jointMap,
    required this.bodyVecMap,
  });

  @override
  State<ExerciseTrackingView> createState() => _ExerciseTrackingViewState();
}

class _ExerciseTrackingViewState extends State<ExerciseTrackingView> {
  CameraController? _controller;
  ExerciseTrackingViewModel? _tracker;

  late final Future<void> _initFuture;

  final appState = getIt<AppStateViewModel>();

  @override
  void initState() {
    super.initState();
    _initFuture = _initAll();
  }

  Future<void> _initAll() async {
    final cameras = await availableCameras();

    final front = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      front,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    await controller.initialize();

    final tracker = ExerciseTrackingViewModel(
      exercise: widget.exercise.exercise,
      cameraController: controller,
      specs: widget.specs,
      corrections: widget.corrections,
      bodyVecMap: widget.bodyVecMap,
      jointMap: widget.jointMap,
    );

    if (!mounted) return;

    setState(() {
      _controller = controller;
      _tracker = tracker;
    });
  }

  @override
  void dispose() {
    _tracker?.endExercise();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || _tracker == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text("Tracking ${widget.exercise.exerciseName}")),
      body: Column(
        children: [
          SafeArea(
            minimum: EdgeInsets.all(20),
            child: Stack(
              children: [
                Center(
                  child: ExerciseTrackingPreview(
                    camera: _controller!.description,
                    cameraController: _controller!,
                  ),
                ),

                StreamBuilder<FormattedTrackingFeedback>(
                  stream: _tracker!.trackingStream,
                  builder: (context, snapshot) {
                    return Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ExerciseFeedbackOverlay(dataSnapshot: snapshot)
                    );
                  },
                ),
              ],
            ),
          ),
          Center(
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Colors.lightBlue,
              child: Text("End Exercise", style: TextStyle(fontSize: 40)),
              onPressed: () {
                appState.saveUserInfoToJson();
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ),
        ],
      ),
    );
  }
}
