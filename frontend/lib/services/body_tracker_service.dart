import 'dart:async';

import 'package:frontend/models/tracking_models/exercise_tracking_frame.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:frontend/utils/exercise_tracking_utils.dart';

class BodyTrackerService {
  late final CameraDescription camera;
  late final CameraController _controller;
  late final PoseDetector poseDetector;
  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  BodyTrackerService({required this.camera}) {
    // setup camera controller
    _controller = CameraController(
      camera,
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );

    // set up pose detector
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    );
    poseDetector = PoseDetector(options: options);
  }

  // Get the input image from the camera image
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final sensorOrientation = camera.sensorOrientation;
    var rotationCompensation =
        _orientations[_controller!.value.deviceOrientation];
    if (rotationCompensation == null) return null;

    // front-facing
    rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    InputImageRotation? rotation = InputImageRotationValue.fromRawValue(
      rotationCompensation!,
    );
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null || format != InputImageFormat.nv21) return null;

    // restricted image format, only one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // start the exercise tracking stream
  Stream<ExerciseTrackingFrame> startExerciseTracking(String exerciseId) {
    final streamController = StreamController<ExerciseTrackingFrame>();
    _startStreamTracking(streamController, exerciseId);
    return streamController.stream;
  }

  // process exercise stream
  Stream<ExerciseTrackingFrame> _startStreamTracking(
    StreamController<ExerciseTrackingFrame> streamController,
    String exerciseId,
  ) async* {
    await _controller.initialize();

    await _controller.startImageStream((CameraImage image) async {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final poses = await poseDetector.processImage(inputImage);
      ExerciseTrackingFrame frame;
      if (poses.isEmpty) {
        frame = ExerciseTrackingFrame(
          pose: Pose(landmarks: {}),
          facing: 'unknown',
          curSide: 'unknown',
          curAngles: {},
          badAngles: {},
          inPosition: false,
          corrections: [],
        );
      } else {
        // only process the first pose detected
        frame = processFrame(poses.first, exerciseId);
      }

      if (!streamController.isClosed) {
        streamController.add(frame);
      } else {
        streamController.close();
      }
    });
  }
}
