import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/certificate_model.dart';
import '../providers/certificate_provider.dart';

class RegistryScreen extends StatelessWidget {
  const RegistryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Реестр')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Загрузка фото временно недоступна в демо-версии'),
            ),
          );
        },
        child: const Icon(Icons.add_rounded),
      ),
      body: SafeArea(
        child: Consumer<CertificateProvider>(
          builder: (context, certificateProvider, child) {
            final certificates = certificateProvider.sortedCertificates;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text(
                    'Smart-реестр достижений',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    'Сертификаты автоматически ранжируются по HR-ценности.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: certificates.length,
                    itemBuilder: (context, index) {
                      final certificate = certificates[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _CertificateCard(certificate: certificate),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.certificate});

  final CertificateModel certificate;

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColorForType(certificate.type);
    final iconData = _iconForType(certificate.type);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF172033), Color(0xFF0F1627)],
        ),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.14),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(iconData, color: accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    certificate.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _InfoChip(
                        icon: _chipIconForType(certificate.type),
                        label: certificate.type,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        foregroundColor: Colors.white,
                      ),
                      _InfoChip(
                        icon: Icons.local_fire_department_rounded,
                        label: 'HR-ценность ${certificate.hrWeight}',
                        backgroundColor: accentColor.withValues(alpha: 0.16),
                        foregroundColor: accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Олимпиада':
        return Icons.emoji_events_rounded;
      case 'Курс':
        return Icons.school_rounded;
      case 'Вебинар':
        return Icons.videocam_rounded;
      default:
        return Icons.workspace_premium_rounded;
    }
  }

  IconData _chipIconForType(String type) {
    switch (type) {
      case 'Олимпиада':
        return Icons.military_tech_rounded;
      case 'Курс':
        return Icons.menu_book_rounded;
      case 'Вебинар':
        return Icons.live_tv_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  Color _accentColorForType(String type) {
    switch (type) {
      case 'Олимпиада':
        return const Color(0xFFFFC857);
      case 'Курс':
        return const Color(0xFF5AC8FA);
      case 'Вебинар':
        return const Color(0xFF8E7CFF);
      default:
        return const Color(0xFF00C2A8);
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
