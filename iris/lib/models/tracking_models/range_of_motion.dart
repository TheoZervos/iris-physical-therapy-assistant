class RangeOfMotion {
  final double lowAngle;
  final double highAngle;

  RangeOfMotion({required this.lowAngle, required this.highAngle});

  factory RangeOfMotion.fromJson(Map<String, dynamic> json) {
    return RangeOfMotion(
      lowAngle: (json["low_angle"] as num).toDouble(),
      highAngle: (json["high_angle"] as num).toDouble(),
    );
  }
}
