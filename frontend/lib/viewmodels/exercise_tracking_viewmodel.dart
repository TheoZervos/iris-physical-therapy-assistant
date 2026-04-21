import 'package:flutter/material.dart';
import 'package:frontend/core/mapping_constants.dart';
import 'package:frontend/models/models_lib.dart';
import 'package:frontend/services/body_tracker_service.dart';
import 'package:frontend/viewmodels/app_state_viewmodel.dart';
import 'package:frontend/models/tracking_models/formatted_tracking_feedback.dart';

class ExerciseTrackingViewModel extends ChangeNotifier {
  late final BodyTrackerService _trackingService;
  final Exercise exercise;
  final AppStateViewModel appState;

  ExerciseTrackingViewModel({required this.exercise, required this.appState}) {
    _trackingService = BodyTrackerService(
      camera: AppStateViewModel.frontCamera,
    );
  }

  Stream<FormattedTrackingFeedback> get trackingStream async* {
    final start = DateTime.now();

    await for (final frame in _trackingService.startExerciseTracking(
      exercise.exerciseId,
    )) {
      final now = DateTime.now();
      final timestamp = now.difference(start);
      final feedback = FormattedTrackingFeedback(
        exerciseId: exercise.exerciseId,
        correctionMessage: ExerciseTrackingMapping
            .correctionMessageMap[frame.corrections[0].message]!,
        severity: frame.corrections[0].severity,
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
}
