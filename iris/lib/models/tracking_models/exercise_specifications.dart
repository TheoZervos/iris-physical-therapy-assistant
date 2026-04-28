import 'range_of_motion.dart';

class ExerciseSpecifications {
  final String id;
  final List<String> joints;
  final Map<String, Map<String, RangeOfMotion>> totalRangeOfMotion;
  final Map<String, Map<String, String>> bodyVecDirections;
  final Map<String, Map<String, RangeOfMotion>> stretchAngles;
  final String facingDirection;

  ExerciseSpecifications({
    required this.id,
    required this.joints,
    required this.totalRangeOfMotion,
    required this.bodyVecDirections,
    required this.stretchAngles,
    required this.facingDirection,
  });

  factory ExerciseSpecifications.fromJson(Map<String, dynamic> json) {
    return ExerciseSpecifications(
      id: json['id'] as String,
      joints: List<String>.from(json['joints'] ?? []),
      
      totalRangeOfMotion: (json['total_rom'] as Map<String, dynamic>).map(
        (side, jointsMap) => MapEntry(
          side,
          (jointsMap as Map<String, dynamic>).map(
            (jointName, romJson) => MapEntry(
              jointName,
              RangeOfMotion.fromJson(romJson as Map<String, dynamic>),
            ),
          ),
        ),
      ),

      bodyVecDirections: (json['body_vec_directions'] as Map<String, dynamic>).map(
        (side, vecMap) => MapEntry(
          side,
          (vecMap as Map<String, dynamic>).map(
            (part, direction) => MapEntry(part, direction as String),
          ),
        ),
      ),

      stretchAngles: (json['stretch_angles'] as Map<String, dynamic>).map(
        (side, jointsMap) => MapEntry(
          side,
          (jointsMap as Map<String, dynamic>).map(
            (jointName, romJson) => MapEntry(
              jointName,
              RangeOfMotion.fromJson(romJson as Map<String, dynamic>),
            ),
          ),
        ),
      ),

      facingDirection: json['facing_dir'] as String,
    );
  }
}