import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/certificate_model.dart';
import '../providers/lift_provider.dart';
import '../widgets/glass_panel.dart';
import '../widgets/lift_backdrop.dart';

class RegistryScreen extends StatefulWidget {
  const RegistryScreen({super.key});

  @override
  State<RegistryScreen> createState() => _RegistryScreenState();
}

class _RegistryScreenState extends State<RegistryScreen> {
  String? _highlightedCertificateId;

  @override
  Widget build(BuildContext context) {
    final certificates = context.watch<LiftProvider>().sortedCertificates;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          LiftBackdrop(
            primaryGlow: const Color(0xFFFFC857),
            secondaryGlow: const Color(0xFF59A8FF),
            tertiaryGlow: const Color(0xFF34D1BF),
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _RegistryHeader(),
                          const SizedBox(height: 18),
                          _RegistryStats(
                            certificatesCount: certificates.length,
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final certificate = certificates[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _CertificateCard(
                            certificate: certificate,
                            isHighlighted:
                                certificate.id == _highlightedCertificateId,
                          ),
                        );
                      }, childCount: certificates.length),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 118,
            child: _ScannerFab(onPressed: _openScannerSheet),
          ),
        ],
      ),
    );
  }

  Future<void> _openScannerSheet() async {
    final certificate = await showModalBottomSheet<CertificateModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ScannerSheet(),
    );

    if (!mounted || certificate == null) {
      return;
    }

    setState(() {
      _highlightedCertificateId = certificate.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Сертификат добавлен: ${certificate.title}')),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1800));

    if (!mounted) {
      return;
    }

    setState(() {
      _highlightedCertificateId = null;
    });
  }
}

class _ScannerFab extends StatelessWidget {
  const _ScannerFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 66,
          height: 66,
          decoration: ShapeDecoration(
            shape: const CircleBorder(),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF34D1BF), Color(0xFF59A8FF)],
            ),
            shadows: [
              BoxShadow(
                color: const Color(0xFF59A8FF).withValues(alpha: 0.24),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(LucideIcons.scanLine, color: Color(0xFF04111A)),
        ),
      ),
    );
  }
}

class _RegistryHeader extends StatelessWidget {
  const _RegistryHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          radius: 20,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.fileBadge, size: 16, color: Color(0xFFFFD777)),
              SizedBox(width: 8),
              Text(
                'SMART-РЕЕСТР',
                style: TextStyle(
                  color: Color(0xFFFFD777),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Твои сертификаты отсортированы по market value для HR и партнёров.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        Text(
          'Сканер распознаёт новые достижения и поднимает самые сильные артефакты наверх.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _RegistryStats extends StatelessWidget {
  const _RegistryStats({required this.certificatesCount});

  final int certificatesCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'В реестре',
            value: '$certificatesCount',
            accentColor: const Color(0xFF59A8FF),
            icon: LucideIcons.layers,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Scan Ready',
            value: 'AI',
            accentColor: const Color(0xFF34D1BF),
            icon: LucideIcons.scanLine,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.accentColor,
    required this.icon,
  });

  final String title;
  final String value;
  final Color accentColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 26,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({
    required this.certificate,
    required this.isHighlighted,
  });

  final CertificateModel certificate;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColorForType(certificate.type);
    final topGlowColor = certificate.isTopMarketValue
        ? const Color(0xFFFFC857)
        : accentColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()
        ..translateByDouble(0.0, isHighlighted ? -4.0 : 0.0, 0.0, 1.0),
      child: GlassPanel(
        radius: 30,
        borderColor: topGlowColor.withValues(
          alpha: certificate.isTopMarketValue ? 0.32 : 0.18,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF121B30).withValues(alpha: 0.92),
            const Color(0xFF0B101E).withValues(alpha: 0.82),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: topGlowColor.withValues(
              alpha: certificate.isTopMarketValue ? 0.22 : 0.1,
            ),
            blurRadius: certificate.isTopMarketValue ? 36 : 24,
            offset: const Offset(0, 18),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _iconForType(certificate.type),
                    color: accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 19,
                          height: 1.28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        certificate.issuer,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetaBadge(
                  icon: _chipIconForType(certificate.type),
                  label: certificate.type,
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                ),
                _MetaBadge(
                  icon: LucideIcons.sparkles,
                  label: 'HR ${certificate.hrWeight}',
                  foregroundColor: topGlowColor,
                  backgroundColor: topGlowColor.withValues(alpha: 0.14),
                ),
                if (certificate.isScanned)
                  _MetaBadge(
                    icon: LucideIcons.scanLine,
                    label: 'AI scanned',
                    foregroundColor: const Color(0xFF59A8FF),
                    backgroundColor: const Color(
                      0xFF59A8FF,
                    ).withValues(alpha: 0.14),
                  ),
              ],
            ),
            if (certificate.isTopMarketValue) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFC857).withValues(alpha: 0.18),
                      const Color(0xFFFFA95C).withValues(alpha: 0.12),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFFFFC857).withValues(alpha: 0.26),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.badgeCheck,
                      size: 16,
                      color: Color(0xFFFFD777),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Top 10% Market Value',
                      style: TextStyle(
                        color: Color(0xFFFFD777),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
        return Icons.ondemand_video_rounded;
      case 'Проект':
        return Icons.auto_awesome_rounded;
      case 'Волонтерство':
        return Icons.volunteer_activism_rounded;
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
      case 'Проект':
        return Icons.auto_graph_rounded;
      case 'Волонтерство':
        return Icons.favorite_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  Color _accentColorForType(String type) {
    switch (type) {
      case 'Олимпиада':
        return const Color(0xFFFFC857);
      case 'Курс':
        return const Color(0xFF59A8FF);
      case 'Вебинар':
        return const Color(0xFF9E7BFF);
      case 'Проект':
        return const Color(0xFF34D1BF);
      case 'Волонтерство':
        return const Color(0xFFFF7AC6);
      default:
        return const Color(0xFF7EE1FF);
    }
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({
    required this.icon,
    required this.label,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final Color foregroundColor;
  final Color backgroundColor;

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

class _ScannerSheet extends StatefulWidget {
  const _ScannerSheet();

  @override
  State<_ScannerSheet> createState() => _ScannerSheetState();
}

class _ScannerSheetState extends State<_ScannerSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lineController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startDiscovery();
    });
  }

  @override
  void dispose() {
    _lineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
      child: GlassPanel(
        radius: 34,
        blur: 30,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F1830).withValues(alpha: 0.96),
            const Color(0xFF08101C).withValues(alpha: 0.92),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'LIFT Scanner',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                const Icon(LucideIcons.scanLine, color: Color(0xFF66F0D7)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ищем сертификат в кадре и оцениваем его HR-ценность.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 22),
            AspectRatio(
              aspectRatio: 0.9,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF59A8FF).withValues(alpha: 0.16),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.02),
                      const Color(0xFF59A8FF).withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(
                                0xFF34D1BF,
                              ).withValues(alpha: 0.38),
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedBuilder(
                      animation: _lineController,
                      builder: (context, child) {
                        return Align(
                          alignment: Alignment(
                            0,
                            -0.78 + (_lineController.value * 1.56),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 36),
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                gradient: const LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    Color(0xFF34D1BF),
                                    Color(0xFF59A8FF),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF34D1BF,
                                    ).withValues(alpha: 0.35),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        LucideIcons.fileBadge2,
                        size: 42,
                        color: Color(0xFF7EBBFF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF34D1BF),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Сканирование документа... AI распознаёт issuer, тип и ценность.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startDiscovery() async {
    final certificate = await context
        .read<LiftProvider>()
        .simulateScannerDiscovery();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(certificate);
  }
}
