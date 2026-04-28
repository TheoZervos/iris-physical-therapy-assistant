import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/tracking_models/formatted_tracking_feedback.dart';

class ExerciseTrackingPreview extends StatefulWidget {
  final CameraDescription camera;
  final CameraController cameraController;

  const ExerciseTrackingPreview({
    super.key,
    required this.camera,
    required this.cameraController,
  });

  @override
  State<ExerciseTrackingPreview> createState() =>
      _ExerciseTrackingPreviewState();
}

class _ExerciseTrackingPreviewState extends State<ExerciseTrackingPreview> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        spacing: 20,
        children: [CameraView(cameraController: widget.cameraController)],
      ),
    );
  }
}

class CameraView extends StatelessWidget {
  final CameraController cameraController;

  const CameraView({super.key, required this.cameraController});

  @override
  Widget build(BuildContext context) {
    if (!cameraController.value.isInitialized) return Container();
    final screenSize = MediaQuery.sizeOf(context);

    return SizedBox(
      height: 0.8*screenSize.height,
      child: AspectRatio(
        aspectRatio: 1 / cameraController.value.aspectRatio,
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(30),
          child: AspectRatio(
            aspectRatio: cameraController.value.aspectRatio,
            child: cameraController.value.isInitialized
                ? CameraPreview(cameraController)
                : // uninitialized camera,
                  CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
