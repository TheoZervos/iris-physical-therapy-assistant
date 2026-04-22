import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:frontend/models/tracking_models/exercise_specifications.dart';

class ExerciseTrackingMapping {
  ExerciseTrackingMapping._(); // Private constructor to prevent instantiation

  static late final Map<String, String> exerciseMap;
  static Future<void> loadExerciseMap(String jsonFilePath) async {
    try {
      final String jsonString = await rootBundle.loadString(jsonFilePath);
      final Map<String, dynamic> data = json.decode(jsonString);
      final tempMap = <String, String>{};
      if (data["exercises"] != null) {
        for (var exercise in data["exercises"]) {
          tempMap[exercise["id"].toString()] = exercise["name"].toString();
        }
      }
      exerciseMap = tempMap;
    } catch (e) {
      print("Error loading exercise map: $e");
      exerciseMap = {};
    }
  }

  static final Map<int, String> landmarkIndexMap = {
    0: "nose",
    1: "left_eye_inner",
    2: "left_eye",
    3: "left_eye_outer",
    4: "right_eye_inner",
    5: "right_eye",
    6: "right_eye_outer",
    7: "left_ear",
    8: "right_ear",
    9: "mouth_left",
    10: "mouth_right",
    11: "left_shoulder",
    12: "right_shoulder",
    13: "left_elbow",
    14: "right_elbow",
    15: "left_wrist",
    16: "right_wrist",
    17: "left_pinky",
    18: "right_pinky",
    19: "left_index",
    20: "right_index",
    21: "left_thumb",
    22: "right_thumb",
    23: "left_hip",
    24: "right_hip",
    25: "left_knee",
    26: "right_knee",
    27: "left_ankle",
    28: "right_ankle",
    29: "left_heel",
    30: "right_heel",
    31: "left_foot_index",
    32: "right_foot_index",
  };

  // ──────────────────────────────────────────────────────────────────
  // Joint map:  joint_name  →  (base_idx, vertex_idx, end_idx, side_sign)
  //
  // *base*     = the reference limb endpoint (e.g. shoulder for elbow angle)
  // *vertex*   = the joint centre (e.g. elbow)
  // *end*      = the moving limb endpoint (e.g. wrist)
  // *side_sign* = +1 for left-side joints, -1 for right-side joints.
  //
  // MediaPipe landmark coordinates have x increasing to the right of the
  // *image frame*, which means the cross-product sign is geometrically
  // flipped between the left and right sides of the body.  Multiplying
  // by side_sign corrects this so that the same physical movement (e.g.
  // bending the elbow forward) produces the same signed angle on both
  // sides.
  // ──────────────────────────────────────────────────────────────────
  static final Map<String, List<int>> jointMap = {
    // Arms
    "right_elbow": [
      12,
      14,
      16,
      -1,
    ], // right_shoulder → right_elbow → right_wrist
    "left_elbow": [11, 13, 15, 1], // left_shoulder  → left_elbow  → left_wrist
    // Shoulders
    "right_shoulder": [
      11,
      12,
      14,
      -1,
    ], // left_shoulder → right_shoulder → right_elbow
    "left_shoulder": [
      12,
      11,
      13,
      1,
    ], // right_shoulder  → left_shoulder  → left_elbow
    // Knees
    "right_knee": [24, 26, 28, -1], // right_hip → right_knee → right_ankle
    "left_knee": [23, 25, 27, 1], // left_hip  → left_knee  → left_ankle
    // Hips
    // "Right Hip":      [12, 24, 26, -1],  // right_shoulder → right_hip → right_knee
    // "Left Hip":       [11, 23, 25, 1],  // left_shoulder  → left_hip  → left_knee
  };

  static final Map<String, List<int>> bodyVectorsMap = {
    // Arms
    "right_forearm": [14, 16],
    "left_forearm": [13, 15],
    "right_bicep": [12, 14],
    "left_bicep": [11, 13],
    // Legs
    "right_quad": [24, 26],
    "left_quad": [23, 25],
    "right_calf": [26, 28],
    "left_calf": [25, 27],
  };

  static late final Map<String, ExerciseSpecifications>
  exerciseSpecificationsMap;

  static Future<void> loadExerciseSpecifications(String jsonFilePath) async {
    try {
      final String jsonString = await rootBundle.loadString(jsonFilePath);
      final data = json.decode(jsonString);

      final tempMap = <String, ExerciseSpecifications>{};

      data.forEach((id, specs) {
        tempMap[id] = ExerciseSpecifications.fromJson(
          specs as Map<String, dynamic>,
        );
      });

      exerciseSpecificationsMap = tempMap;
      print(exerciseSpecificationsMap);
    } catch (e) {
      print("Error loading exercise specifications: $e");
      exerciseSpecificationsMap = {};
    }
  }

  static late final Map<String, dynamic> correctionMessageMap;

  static Future<void> loadCorrectionMessages(String jsonFilePath) async {
    try {
      final String jsonString = await rootBundle.loadString(jsonFilePath);
      final data = json.decode(jsonString);
      correctionMessageMap = Map<String, dynamic>.from(data as Map);
    } catch (e) {
      print("Error loading correction messages: $e");
      correctionMessageMap = {};
    }
  }
}
