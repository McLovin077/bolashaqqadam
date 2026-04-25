class AnalyticsProfileModel {
  const AnalyticsProfileModel({
    required this.archetype,
    required this.aiVerdict,
    required this.dominantTags,
    required this.radarScores,
  });

  final String archetype;
  final String aiVerdict;
  final List<String> dominantTags;
  final Map<String, double> radarScores;
}
