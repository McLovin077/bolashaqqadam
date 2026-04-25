class CertificateModel {
  const CertificateModel({
    required this.id,
    required this.title,
    required this.type,
    required this.hrWeight,
    this.issuer = '',
    this.isScanned = false,
  });

  final String id;
  final String title;
  final String type;
  final int hrWeight;
  final String issuer;
  final bool isScanned;

  bool get isTopMarketValue => hrWeight > 7;
}
