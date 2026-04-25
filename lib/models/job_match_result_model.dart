class JobMatchResultModel {
  const JobMatchResultModel({
    required this.percentage,
    required this.matchedTags,
    required this.isPerfectFit,
    required this.isArchetypeAligned,
  });

  final int percentage;
  final List<String> matchedTags;
  final bool isPerfectFit;
  final bool isArchetypeAligned;

  String get label => '$percentage% Match';
}
