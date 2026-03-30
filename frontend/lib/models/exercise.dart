class Exercise {
  final String exerciseName;
  final String tutorialLink;
  final String exerciseDescription;
  final List<String> exerciseImages;
  final String exerciseId;
  final List<String> exerciseAliases;
  bool isFavorite;
  final String muscleRegion;

  Exercise({
    required this.exerciseName,
    required this.tutorialLink,
    required this.exerciseDescription,
    required this.exerciseImages,
    required this.exerciseId,
    required this.exerciseAliases,
    required this.isFavorite,
    required this.muscleRegion
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseName: json['exerciseName'] as String,
      tutorialLink: json['tutorialLink'] as String,
      exerciseDescription: json['exerciseDescription'] as String,
      exerciseImages: List<String>.from(json['exerciseImages'] as List),
      exerciseId: json['exerciseId'] as String,
      exerciseAliases: List<String>.from(json['exerciseAliases'] as List),
      isFavorite: json['isFavorite'] as bool,
      muscleRegion: json['muscleRegion'] as String,
    );
  }
}
