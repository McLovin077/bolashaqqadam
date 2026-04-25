class JobModel {
  const JobModel({
    this.id = '',
    required this.companyName,
    required this.title,
    required this.tagsNeeded,
    required this.isJasaVerified,
    this.preferredArchetypes = const [],
    this.axisAffinity = const {},
  });

  final String id;
  final String companyName;
  final String title;
  final List<String> tagsNeeded;
  final bool isJasaVerified;
  final List<String> preferredArchetypes;
  final Map<String, double> axisAffinity;
}
