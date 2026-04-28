import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import '../core/mapping_constants.dart';
import '../models/tracking_models/tracking_models_lib.dart';

ExerciseTrackingFrame backgroundProcessFrame(Map<String, dynamic> data) {
  final Pose pose = data["pose"];
  final String exerciseId = data["exerciseId"];
  final Map<String, ExerciseSpecifications> exerciseSpecificationsMap =
      data["specs"];
  final Map<String, dynamic> correctionMessageMap = data["corrections"];
  final Map<String, List<int>> jointMap = data["jointMap"];
  final Map<String, List<int>> bodyVectorsMap = data["bodyVecMap"];

  return processFrame(
    pose,
    exerciseId,
    exerciseSpecificationsMap,
    correctionMessageMap,
    jointMap,
    bodyVectorsMap,
  );
}

// BODY POSITION UTIL ---------------------------------------------------------------
ExerciseTrackingFrame processFrame(
  Pose pose,
  String exerciseId,
  Map<String, ExerciseSpecifications> exerciseSpecificationsMap,
  Map<String, dynamic> correctionMessageMap,
  Map<String, List<int>> jointMap,
  Map<String, List<int>> bodyVectorsMap,
) {
  final exerciseSpecs = exerciseSpecificationsMap[exerciseId]!;

  // getting facing information
  var corrections = List<ExerciseCorrection>.empty(growable: true);
  final facing = getFacingDirection(pose);
  String? curSide;
  List<Map<String, double>>? jointAngles;
  bool inPosition = false;

  // ensuring facing the correct direction for exercise
  if (!exerciseSpecs.facingDirection.contains(facing)) {
    corrections.add(
      ExerciseCorrection(message: "facing_wrong_direction", severity: "info"),
    );
  } else {
    // getting current joint angles and bad angles that need correction
    curSide = _getCurSide(pose, facing, exerciseSpecs, bodyVectorsMap);
    jointAngles = _getJointAngles(pose, facing, exerciseSpecs, bodyVectorsMap);
    inPosition =
        allAnglesInStartingPosition(
          exerciseSpecs,
          jointAngles[0],
          pose,
          curSide,
          bodyVectorsMap,
        ) &&
        curSide != "unknown";

    // getting correction messages for not being in starting position
    if (!inPosition) {
      corrections.add(
        ExerciseCorrection(
          message: "not_in_starting_position",
          severity: "info",
        ),
      );
    }

    // getting correction messages for bad angles
    corrections.addAll(
      getCorrections(jointAngles[1], exerciseSpecs.stretchAngles[curSide]!),
    );
    print(corrections);
  }

  // returning frame with all relevant information
  return ExerciseTrackingFrame(
    pose: pose,
    facing: facing,
    curSide: curSide ?? "unknown",
    curAngles: jointAngles != null ? jointAngles[0] : <String, double>{},
    badAngles: jointAngles != null ? jointAngles[1] : <String, double>{},
    corrections: corrections,
    inPosition: inPosition && exerciseSpecs.facingDirection.contains(facing),
  );
}

// PROCESSING UTILS -----------------------------------------------------------------

List<ExerciseCorrection> getCorrections(
  Map<String, double> badAngles,
  Map<String, RangeOfMotion> targetAngles,
) {
  var corrections = List<ExerciseCorrection>.empty(growable: true);

  // for each bad angle, get the corresponding target angle and determine correction
  for (var entry in badAngles.entries) {
    print('Bad: $entry');
    print(targetAngles[entry.key]!.highAngle);
    print(targetAngles[entry.key]!.lowAngle);
    // high angle
    if (entry.value > targetAngles[entry.key]!.highAngle) {
      corrections.add(
        ExerciseCorrection(
          message: "${entry.key}:high_angle",
          severity: "warning",
        ),
      );
    }
    //low angle
    else if (entry.value < targetAngles[entry.key]!.lowAngle) {
      corrections.add(
        ExerciseCorrection(
          message: "${entry.key}:low_angle",
          severity: "warning",
        ),
      );
    }
  }

  if(corrections.isNotEmpty) print(corrections[0].message);
  return corrections;
}

String getFacingDirection(Pose pose) {
  // landmarks for determining facing direction
  final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

  if (leftShoulder == null ||
      rightShoulder == null ||
      leftHip == null ||
      rightHip == null) {
    return "unknown";
  }

  // getting difference in hips and shoulders
  final xHipDiff = leftHip.x - rightHip.x;
  final zHipDiff = leftHip.z - rightHip.z;
  final xShoulderDiff = leftShoulder.x - rightShoulder.x;
  final zShoulderDiff = leftShoulder.z - rightShoulder.z;

  // get the sum of total differences
  final xDiff = xHipDiff + xShoulderDiff;
  final zDiff = zHipDiff + zShoulderDiff;

  // getting direction
  if (xDiff.abs() > zDiff.abs()) {
    return xDiff > 0 ? 'front' : 'back';
  } else {
    return zDiff > 0 ? 'left' : 'right';
  }
}

bool allAnglesInStartingPosition(
  ExerciseSpecifications exerciseSpecs,
  Map<String, double> curAngles,
  Pose pose,
  String curSide,
  Map<String, List<int>> bodyVectorsMap,
) {
  var targetAngles = exerciseSpecs.totalRangeOfMotion[curSide];
  for (var entry in targetAngles!.entries) {
    if (!_angleIsInRom(curAngles[entry.key]!, entry.value)) {
      return false;
    }
  }

  var targetBodyVectors = exerciseSpecs.bodyVecDirections[curSide];
  for (var entry in targetBodyVectors!.entries) {
    if (!_vectorInDirection(pose, entry.key, entry.value, bodyVectorsMap)) {
      return false;
    }
  }

  return true;
}

// PRIVATE PROCESSING HELPERS --------------------------------------------------------------

List<Map<String, double>> _getJointAngles(
  Pose pose,
  String facing,
  ExerciseSpecifications exerciseSpecs,
  Map<String, List<int>> bodyVectorsMap,
) {
  final curFacing = facing;
  final curSide = _getCurSide(pose, curFacing, exerciseSpecs, bodyVectorsMap);

  // getting current joint angles for all joints in exercise specifications
  var jointAngles = exerciseSpecs.joints.asMap().entries.map(
    (entry) => MapEntry(
      "${curSide}_${entry.value}",
      calculateAngle(pose, "${curSide}_${entry.value}"),
    ),
  );

  // getting joint angles that don't meet exercise specifications
  var badAngles = jointAngles.where((entry) {
    final targetRom = exerciseSpecs.stretchAngles[curSide]![entry.key];
    if (targetRom == null) return false;
    return !_angleIsInRom(entry.value, targetRom);
  });

  return [Map.fromEntries(jointAngles), Map.fromEntries(badAngles)];
}

String _getCurSide(
  Pose pose,
  String facingDir,
  ExerciseSpecifications exerciseSpecs,
  Map<String, List<int>> bodyVectorsMap,
) {
  // return side of body closest to camera if facing left/right
  if (facingDir == "right") {
    return "left";
  } else if (facingDir == "left") {
    return "right";
  }

  // determine side based on estimation of which side matches directions closest
  for (var side in exerciseSpecs.bodyVecDirections.entries) {
    bool sideFound = true;
    for (var bodyVec in side.value.entries) {
      var curDir = _getPrimaryVectorDirection(
        pose,
        bodyVec.key,
        bodyVectorsMap,
      );
      if (curDir != bodyVec.value) {
        sideFound = false;
        break;
      }
    }

    // side was found
    if (sideFound) {
      return side.key;
    }
  }

  // side could not be determined, maybe not in position?
  return "unknown";
}

Map<String, Map<String, dynamic>> _getVectorDirections(
  Pose pose,
  String bodyVec,
  Map<String, List<int>> bodyVectorsMap,
) {
  final entry = bodyVectorsMap[bodyVec];
  if (entry == null) {
    throw ArgumentError('Invalid body vector name: $bodyVec');
  }

  // getting body landmarks and determining if they are present
  final [startIndex, endIndex] = entry;
  final start = pose.landmarks[PoseLandmarkType.values[startIndex]];
  final end = pose.landmarks[PoseLandmarkType.values[endIndex]];

  if (start == null || end == null) {
    return {
      'x': {'dir': 'unknown', 'mag': 0.0},
      'y': {'dir': 'unknown', 'mag': 0.0},
    };
  }

  // getting the vector components
  final xVec = end.x - start.x;
  final yVec = end.y - start.y;
  final zVec = end.z - start.z;

  // calculating the likely direction of the vector in each axis
  final directions = {
    'x': {'dir': xVec < 0 ? 'right' : 'left', 'mag': xVec.abs()},
    'y': {'dir': yVec < 0 ? 'down' : 'up', 'mag': yVec.abs()},
    'z': {'dir': zVec < 0 ? 'forward' : 'backward', 'mag': zVec.abs()},
  };
  return directions;
}

String _getPrimaryVectorDirection(
  Pose pose,
  String bodyVec,
  Map<String, List<int>> bodyVectorsMap,
) {
  final directions = _getVectorDirections(pose, bodyVec, bodyVectorsMap);

  String primaryDirection = "unknown";
  double primaryDirectionStrength = 0.0;
  for (var axis in directions.keys) {
    if (directions[axis]!["mag"] > primaryDirectionStrength) {
      primaryDirection = directions[axis]!["dir"];
      primaryDirectionStrength = directions[axis]!["mag"];
    }
  }

  return primaryDirection;
}

bool _angleIsInRom(double curAngle, RangeOfMotion targetAngle) {
  return curAngle >= targetAngle.lowAngle && curAngle <= targetAngle.highAngle;
}

bool _vectorInDirection(
  Pose pose,
  String bodyVec,
  String targetDir,
  Map<String, List<int>> bodyVectorsMap,
) {
  return _getPrimaryVectorDirection(pose, bodyVec, bodyVectorsMap) == targetDir;
}

// MATH UTILS -----------------------------------------------------------------------

double calculateAngle(Pose pose, String joint) {
  final entry = ExerciseTrackingMapping.jointMap[joint];
  if (entry == null) {
    throw ArgumentError('Invalid joint name: $joint');
  }

  final [baseIndex, vertexIndex, endIndex, sideSign] = entry;
  if (pose.landmarks[PoseLandmarkType.values[baseIndex]] == null ||
      pose.landmarks[PoseLandmarkType.values[vertexIndex]] == null ||
      pose.landmarks[PoseLandmarkType.values[endIndex]] == null) {
    return double.nan;
  }

  final base = pose.landmarks[PoseLandmarkType.values[baseIndex]]!;
  final vertex = pose.landmarks[PoseLandmarkType.values[vertexIndex]]!;
  final end = pose.landmarks[PoseLandmarkType.values[endIndex]]!;

  return sideSign * _signedAngle(base, vertex, end);
}

// PRIVATE MATH HELPERS --------------------------------------------------------------

double _signedAngle(PoseLandmark base, PoseLandmark vertex, PoseLandmark end) {
  final v1 = [base.x - vertex.x, base.y - vertex.y];
  final v2 = [end.x - vertex.x, end.y - vertex.y];

  final dot = v1[0] * v2[0] + v1[1] * v2[1];
  final cross = v1[0] * v2[1] - v1[1] * v2[0];
  final angleRad = atan2(cross, dot);

  return angleRad * (180 / pi);
}
