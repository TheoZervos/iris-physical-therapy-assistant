class Exercise {
  final String exerciseName;
  final String tutorialLink;
  final String exerciseDescription;
  final String assetsFolder;
  final String exerciseId;
  final List<String> exerciseAliases;
  bool isFavorite;
  final List<String> muscleRegions;

  Exercise({
    required this.exerciseName,
    required this.tutorialLink,
    required this.exerciseDescription,
    required this.assetsFolder,
    required this.exerciseId,
    required this.exerciseAliases,
    required this.isFavorite,
    required this.muscleRegions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      exerciseName: json['exerciseName'] as String,
      tutorialLink: json['tutorialLink'] as String,
      exerciseDescription: json['exerciseDescription'] as String,
      assetsFolder: json['assetsFolder'] as String,
      exerciseId: json['exerciseId'] as String,
      exerciseAliases: List<String>.from(json['exerciseAliases'] as List),
      isFavorite: json['isFavorite'] as bool,
      muscleRegions: List<String>.from(json['muscleRegions'] as List),
    );
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    print(isFavorite);
  }
}
