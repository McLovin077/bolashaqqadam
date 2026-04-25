import 'package:flutter/material.dart';

import '../models/certificate_model.dart';

class CertificateProvider extends ChangeNotifier {
  final List<CertificateModel> _certificates = const [
    CertificateModel(
      id: 'cert_1',
      title: 'Республиканская олимпиада по математике',
      type: 'Олимпиада',
      hrWeight: 10,
    ),
    CertificateModel(
      id: 'cert_2',
      title: 'Городской курс по Python-разработке',
      type: 'Курс',
      hrWeight: 8,
    ),
    CertificateModel(
      id: 'cert_3',
      title: 'Национальный STEM-хакатон',
      type: 'Олимпиада',
      hrWeight: 7,
    ),
    CertificateModel(
      id: 'cert_4',
      title: 'Карьерный вебинар от IT-компании',
      type: 'Вебинар',
      hrWeight: 4,
    ),
    CertificateModel(
      id: 'cert_5',
      title: 'Школьный вебинар по soft skills',
      type: 'Вебинар',
      hrWeight: 1,
    ),
  ];

  List<CertificateModel> get sortedCertificates {
    final sorted = List<CertificateModel>.from(_certificates);
    sorted.sort((a, b) => b.hrWeight.compareTo(a.hrWeight));
    return sorted;
  }
}
