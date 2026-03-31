class SessionAnalytics {
  final Map<String, dynamic> analytics;

  SessionAnalytics({required this.analytics});

  factory SessionAnalytics.fromJson(Map<String, dynamic> json) {
    return SessionAnalytics(
      analytics: json['analytics'] as Map<String, dynamic>,
    );
  }
}
