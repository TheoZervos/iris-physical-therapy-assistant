import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:frontend/models/tracking_models/exercise_correction.dart';
import 'package:frontend/models/tracking_models/exercise_specifications.dart';
import 'package:frontend/models/tracking_models/exercise_tracking_frame.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:frontend/utils/exercise_tracking_utils.dart';

class BodyTrackerService {
  final CameraDescription camera;
  CameraImage? _latestImage;
  DateTime _lastProcess = DateTime.now();
  bool _isProcessing = false;
  bool _isStreaming = false;
  late final CameraController cameraController;
  late final StreamController<ExerciseTrackingFrame> _streamController;
  late final PoseDetector poseDetector;

  final Map<String, ExerciseSpecifications> specs;
  final Map<String, dynamic> corrections;
  final Map<String, List<int>> jointMap;
  final Map<String, List<int>> bodyVecMap;

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  BodyTrackerService({
    required this.cameraController,
    required this.camera,
    required this.specs,
    required this.corrections,
    required this.jointMap,
    required this.bodyVecMap,
  }) {
    // set up stream controller
    _streamController = StreamController<ExerciseTrackingFrame>();

    // set up pose detector
    final options = PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    );
    poseDetector = PoseDetector(options: options);
  }

  // Get the input image from the camera image
  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final camera = cameraController.description;
    final sensorOrientation = camera.sensorOrientation;

    var rotationCompensation =
        _orientations[cameraController.value.deviceOrientation];
    if (rotationCompensation == null) return null;

    rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
    var rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        Platform.isAndroid && format != InputImageFormat.nv21) {
      debugPrint("Image format is not nv21");
      return null;
    }

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  // start the exercise tracking stream
  Stream<ExerciseTrackingFrame> startExerciseTracking(String exerciseId) {
    if (_isStreaming) {
      return _streamController.stream;
    }

    _startStreamTracking(exerciseId);
    return _streamController.stream;
  }

  // process exercise stream
  void _startStreamTracking(String exerciseId) {
    if (_isStreaming) return;
    _isStreaming = true;

    cameraController.startImageStream((CameraImage image) async {
      _latestImage = image;

      if (_isProcessing) return;
      _isProcessing = true;

      _processFrame(exerciseId);
    });
  }

  // process each frame
  Future<void> _processFrame(String exerciseId) async {
    if (DateTime.now().difference(_lastProcess) < Duration(milliseconds: 10)) {
      _isProcessing = false;
      return;
    }

    _lastProcess = DateTime.now();

    try {
      final image = _latestImage;
      if (image == null) return;

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
          corrections: [ExerciseCorrection(message: "landmarks_not_visible", severity: "info")],
        );
      } else {
        // only process the first pose detected
        // frame = processFrame(poses.first, exerciseId);
        frame = await compute(backgroundProcessFrame, {
          "pose": poses.first,
          "exerciseId": exerciseId,
          "specs": specs,
          "corrections": corrections,
          "jointMap": jointMap,
          "bodyVecMap": bodyVecMap,
        });
      }

      if (!_streamController.isClosed) {
        _streamController.add(frame);
      } else {
        _streamController.close();
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> endExerciseTrackingStream() async {
    await poseDetector.close();
    if (!_streamController.isClosed) {
      await _streamController.close();
    }
  }
}
