import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_panel.dart';

class RegistryScreen extends StatefulWidget {
  const RegistryScreen({super.key});

  @override
  State<RegistryScreen> createState() => _RegistryScreenState();
}

class _RegistryScreenState extends State<RegistryScreen>
    with SingleTickerProviderStateMixin {
  String? _highlightedAchievementId;

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final achievements = appProvider.filteredAchievements;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBackground(child: SizedBox.expand()),
            ),
          ),
          SafeArea(
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
                          achievementsCount:
                              appProvider.savedAchievements.length,
                          smartRating: appProvider.smartRating,
                        ),
                        const SizedBox(height: 18),
                        _RegistryFilters(
                          selected: appProvider.achievementFilter,
                          onSelected: appProvider.setAchievementFilter,
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: achievements.isEmpty
                      ? SliverToBoxAdapter(
                          child: _EmptyRegistryState(onScan: _openScannerSheet),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final achievement = achievements[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: _AchievementCard(
                                achievement: achievement,
                                isHighlighted:
                                    achievement.id == _highlightedAchievementId,
                              ),
                            );
                          }, childCount: achievements.length),
                        ),
                ),
              ],
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
    final achievement = await showModalBottomSheet<UserAchievement>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ScannerSheet(),
    );

    if (!mounted || achievement == null) {
      return;
    }

    setState(() {
      _highlightedAchievementId = achievement.id;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Добавлено в реестр: ${achievement.title}')),
    );

    await Future<void>.delayed(const Duration(milliseconds: 1800));

    if (!mounted) {
      return;
    }

    setState(() {
      _highlightedAchievementId = null;
    });
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
          'Сканируй сертификаты, проекты и волонтерство, чтобы прокачивать LIFT-профиль.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        Text(
          'AI-сканер распознает тип достижения, считает HR-Value и сразу добавляет сигнал в карьерный профиль.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _RegistryStats extends StatelessWidget {
  const _RegistryStats({
    required this.achievementsCount,
    required this.smartRating,
  });

  final int achievementsCount;
  final double smartRating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'В реестре',
            value: '$achievementsCount',
            accentColor: const Color(0xFF59A8FF),
            icon: LucideIcons.layers,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Smart Rating',
            value: smartRating.toStringAsFixed(1),
            accentColor: const Color(0xFF34D1BF),
            icon: LucideIcons.sparkles,
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

class _RegistryFilters extends StatelessWidget {
  const _RegistryFilters({required this.selected, required this.onSelected});

  final AchievementFilter selected;
  final ValueChanged<AchievementFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: AchievementFilter.values.map((filter) {
        final isSelected = filter == selected;

        return InkWell(
          onTap: () => onSelected(filter),
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF59A8FF).withValues(alpha: 0.16)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF59A8FF).withValues(alpha: 0.24)
                    : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Text(
              filter.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isSelected ? const Color(0xFFBFE1FF) : Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _EmptyRegistryState extends StatelessWidget {
  const _EmptyRegistryState({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 30,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF121B30).withValues(alpha: 0.92),
          const Color(0xFF0B101E).withValues(alpha: 0.82),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF59A8FF).withValues(alpha: 0.14),
            ),
            alignment: Alignment.center,
            child: const Icon(
              LucideIcons.scanLine,
              size: 30,
              color: Color(0xFF7EBBFF),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Реестр пока пуст',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Запусти AI-сканер и добавь первое достижение. Оно сразу усилит профиль и оценку от LIFT.',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onScan,
              icon: const Icon(LucideIcons.scanLine),
              label: const Text('Открыть AI-сканер'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.achievement,
    required this.isHighlighted,
  });

  final UserAchievement achievement;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final accentColor = _accentColor(achievement.type);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      transform: Matrix4.identity()
        ..translateByDouble(0.0, isHighlighted ? -4.0 : 0.0, 0.0, 1.0),
      child: GlassPanel(
        radius: 30,
        borderColor: accentColor.withValues(alpha: isHighlighted ? 0.30 : 0.16),
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
            color: accentColor.withValues(alpha: isHighlighted ? 0.22 : 0.10),
            blurRadius: isHighlighted ? 34 : 24,
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
                  child: Text(
                    achievement.typeEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 19,
                          height: 1.28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement.organization,
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
            Text(
              achievement.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetaBadge(
                  icon: _chipIcon(achievement.type),
                  label: achievement.typeLabel,
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                ),
                _MetaBadge(
                  icon: LucideIcons.sparkles,
                  label: 'HR ${achievement.aiWeight.toStringAsFixed(1)}',
                  foregroundColor: accentColor,
                  backgroundColor: accentColor.withValues(alpha: 0.14),
                ),
                if (achievement.dateLabel.isNotEmpty)
                  _MetaBadge(
                    icon: LucideIcons.calendarDays,
                    label: achievement.dateLabel,
                    foregroundColor: const Color(0xFF7EBBFF),
                    backgroundColor: const Color(
                      0xFF59A8FF,
                    ).withValues(alpha: 0.14),
                  ),
              ],
            ),
            if (achievement.tags.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: achievement.tags.take(4).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      tag,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _accentColor(AchievementType type) {
    switch (type) {
      case AchievementType.certificate:
        return const Color(0xFF59A8FF);
      case AchievementType.volunteer:
        return const Color(0xFFFFC857);
      case AchievementType.project:
        return const Color(0xFF34D1BF);
    }
  }

  IconData _chipIcon(AchievementType type) {
    switch (type) {
      case AchievementType.certificate:
        return LucideIcons.fileBadge;
      case AchievementType.volunteer:
        return LucideIcons.heartHandshake;
      case AchievementType.project:
        return LucideIcons.folderKanban;
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
              'AI распознает достижение, оценивает его HR-Value и добавляет в реестр.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 22),
            AspectRatio(
              aspectRatio: 0.95,
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
                    'Сканирование документа... AI распознает тип, дату и ценность достижения.',
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
    final achievement = await context
        .read<AppProvider>()
        .simulateAchievementScan();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop(achievement);
  }
}
