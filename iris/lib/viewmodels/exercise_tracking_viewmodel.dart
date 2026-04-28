import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../core/mapping_constants.dart';
import '../models/models_lib.dart';
import '../models/tracking_models/exercise_specifications.dart';
import '../services/body_tracker_service.dart';
import 'app_state_viewmodel.dart';
import '../models/tracking_models/formatted_tracking_feedback.dart';
import '../service_locator.dart';

class ExerciseTrackingViewModel extends ChangeNotifier {
  BodyTrackerService? _trackingService;
  late final Stream<FormattedTrackingFeedback> trackingStream;
  final Exercise exercise;
  final CameraController cameraController;
  late final AppStateViewModel appState;
  final Map<String, ExerciseSpecifications> specs;
  final Map<String, dynamic> corrections;
  final Map<String, List<int>> jointMap;
  final Map<String, List<int>> bodyVecMap;

  ExerciseTrackingViewModel({
    required this.exercise,
    required this.cameraController,
    required this.specs,
    required this.corrections,
    required this.jointMap,
    required this.bodyVecMap,
  }) {
    appState = getIt<AppStateViewModel>();

    _trackingService = BodyTrackerService(
      camera: cameraController.description,
      cameraController: cameraController,
      specs: specs,
      corrections: corrections,
      jointMap: jointMap,
      bodyVecMap: bodyVecMap,
    );

    trackingStream = _createTrackingStream();
  }

  // start and track the exercise
  Stream<FormattedTrackingFeedback> _createTrackingStream() async* {
    final start = DateTime.now();
    await for (final frame in _trackingService!.startExerciseTracking(
      exercise.exerciseId,
    )) {
      final now = DateTime.now();
      final timestamp = now.difference(start);

      // getting correction messages
      final hasCorrections = frame.corrections.isNotEmpty;
      String correctionMessage;
      if (hasCorrections) {
        var correctionKeys = frame.corrections[0].message.split(":");
        print(correctionKeys);
        correctionMessage = correctionKeys.length > 1
            ? ExerciseTrackingMapping.correctionMessageMap[exercise
                  .exerciseId][correctionKeys[0]][correctionKeys[1]]
            : ExerciseTrackingMapping.correctionMessageMap[exercise
                  .exerciseId][correctionKeys[0]];
      } else {
        correctionMessage = "You're doing great! Keep it up!";
      }

      final feedback = FormattedTrackingFeedback(
        exerciseId: exercise.exerciseId,
        correctionMessage: correctionMessage,
        severity: frame.corrections.isNotEmpty
            ? frame.corrections[0].severity
            : "good",
        timestamp: timestamp,
      );
      yield feedback;
    }

    // tracking is over
    final now = DateTime.now();
    final sessionLength = now.difference(start);

    // saving the session to the user's exercise history
    appState.userInfo.exerciseHistory.exerciseHistory.exerciseSessions.add(
      ExerciseSession(
        sessionExercise: exercise,
        date: now,
        sessionLength: sessionLength,
        analytics: SessionAnalytics(analytics: {}),
      ),
    );

    //saving the updated history to the json file
    await appState.saveUserInfoToJson();
    notifyListeners();
  }

  Future<void> endExercise() async {
    if (_trackingService != null) {
      await _trackingService!.endExerciseTrackingStream();
    }
    notifyListeners();
  }
}
