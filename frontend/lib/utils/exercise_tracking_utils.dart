import 'dart:math';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:frontend/core/mapping_constants.dart';
import 'package:frontend/models/tracking_models/tracking_models_lib.dart';

// BODY POSITION UTIL ---------------------------------------------------------------
ExerciseTrackingFrame processFrame(Pose pose, String exerciseId) {
  // making sure all necessary landmarks are present to process frame
  final exerciseSpecs = ExerciseTrackingMapping.exerciseSpecificationsMap[exerciseId]!;
  if (!_neededLandmarksPresent(pose, exerciseSpecs.joints)) {
    return ExerciseTrackingFrame(
      pose: pose,
      facing: 'unknown',
      curSide: 'unknown',
      curAngles: {},
      badAngles: {},
      corrections: [
        ExerciseCorrection(
          message: "landmarks_not_visible",
          severity: "info",
        ),
      ],
      inPosition: false,
    );
  }

  // getting facing information
  var corrections = List<ExerciseCorrection>.empty(growable: true);
  final facing = getFacingDirection(pose);

  // ensuring facing the correct direction for exercise
  if (!exerciseSpecs.facingDirection.contains(facing)) {
    corrections.add(
      ExerciseCorrection(
        message: "facing_wrong_direction:$facing",
        severity: "info",
      ),
    );
  }

  // getting current joint angles and bad angles that need correction
  final curSide = _getCurSide(pose, facing, exerciseSpecs);
  final jointAngles = _getJointAngles(pose, exerciseSpecs);
  final inPosition = allAnglesInStartingPosition(pose, exerciseSpecs.totalRangeOfMotion[facing]!);

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
  corrections.addAll(getCorrections(
    jointAngles[1],
    exerciseSpecs.totalRangeOfMotion[facing]!,
  ));

  // returning frame with all relevant information
  return ExerciseTrackingFrame(
    pose: pose,
    facing: facing,
    curSide: curSide,
    curAngles: jointAngles[0],
    badAngles:jointAngles[1],
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

  return corrections;
}

String getFacingDirection(Pose pose) {
  // getting landmarks and ensuring they are present
  final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

  // getting difference in hips and shoulders
  final xHipDiff = leftHip!.x - rightHip!.x;
  final zHipDiff = leftHip.z - rightHip.z;
  final xShoulderDiff = leftShoulder!.x - rightShoulder!.x;
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
  Pose pose, 
  Map<String, RangeOfMotion> targetAngles
) {
  for (var entry in targetAngles.entries) {
    if (!_isInRom(entry.key, pose, entry.value)) {
      return false;
    }
  }
  return true;
}

// PRIVATE PROCESSING HELPERS --------------------------------------------------------------

bool _neededLandmarksPresent(Pose pose, List<String> joints) {
  // landmarks for determining facing direction
  final leftShoulder = pose.landmarks[PoseLandmarkType.leftShoulder];
  final rightShoulder = pose.landmarks[PoseLandmarkType.rightShoulder];
  final leftHip = pose.landmarks[PoseLandmarkType.leftHip];
  final rightHip = pose.landmarks[PoseLandmarkType.rightHip];

  if (leftShoulder == null ||
      rightShoulder == null ||
      leftHip == null ||
      rightHip == null) {
    return false;
  }

  // landmarks for determining joint angles
  for (var joint in joints) {
    final entry = ExerciseTrackingMapping.jointMap[joint];
    if (entry == null) {
      throw ArgumentError('Invalid joint name: $joint');
    }

    final [baseIndex, vertexIndex, endIndex, sideSign] = entry;
    if (pose.landmarks[PoseLandmarkType.values[baseIndex]] == null ||
        pose.landmarks[PoseLandmarkType.values[vertexIndex]] == null ||
        pose.landmarks[PoseLandmarkType.values[endIndex]] == null) {
      return false;
    }
  }
  return true;
}

List<Map<String, double>> _getJointAngles(
  Pose pose,
  ExerciseSpecifications exerciseSpecs,
) {
  final curFacing = getFacingDirection(pose);
  final curSide = _getCurSide(pose, curFacing, exerciseSpecs);

  // getting current joint angles for all joints in exercise specifications
  var jointAngles = exerciseSpecs.joints.asMap().entries.map(
    (entry) => MapEntry(
      "${curSide}_${entry.value}",
      calculateAngle(pose, entry.value),
    ),
  );

  // getting joint angles that don't meet exercise specifications
  var badAngles = jointAngles.where((entry) {
    final targetRom = exerciseSpecs.totalRangeOfMotion[entry.key]?[curFacing];
    if (targetRom == null) return false;
    return !_isInRom(entry.key, pose, targetRom);
  });

  return [Map.fromEntries(jointAngles), Map.fromEntries(badAngles)];
}

String _getCurSide(
  Pose pose,
  String facingDir,
  ExerciseSpecifications exerciseSpecs,
) {
  // return side of body closest to camera if facing left/right
  if (facingDir == "right") {
    return "right";
  } else if (facingDir == "left") {
    return "left";
  }

  // determine side based on estimation of which side matches directions closest
  for (var side in exerciseSpecs.bodyVecDirections.entries) {
    bool sideFound = true;
    for (var bodyVec in side.value.entries) {
      var curDir = _getPrimaryVectorDirection(pose, bodyVec.key);
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
) {
  final entry = ExerciseTrackingMapping.bodyVectorsMap[bodyVec];
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
    'x': {'dir': xVec > 0 ? 'right' : 'left', 'mag': xVec.abs()},
    'y': {'dir': yVec > 0 ? 'down' : 'up', 'mag': yVec.abs()},
    'z': {'dir': zVec > 0 ? 'forward' : 'backward', 'mag': zVec.abs()},
  };
  return directions;
}

String _getPrimaryVectorDirection(Pose pose, String bodyVec) {
  final directions = _getVectorDirections(pose, bodyVec);

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

bool _isInRom(String joint, Pose pose, RangeOfMotion targetRom) {
  final angle = calculateAngle(pose, joint);
  return angle >= targetRom.lowAngle && angle <= targetRom.highAngle;
}

// MATH UTILS -----------------------------------------------------------------------

double calculateAngle(Pose pose, String joint) {
  final entry = ExerciseTrackingMapping.jointMap[joint];
  if (entry == null) {
    throw ArgumentError('Invalid joint name: $joint');
  }

  final [baseIndex, vertexIndex, endIndex, sideSign] = entry;
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
