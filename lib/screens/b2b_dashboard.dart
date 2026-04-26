import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/mock_data.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/match_score_ring.dart';

class B2BDashboardScreen extends StatefulWidget {
  const B2BDashboardScreen({super.key});

  @override
  State<B2BDashboardScreen> createState() => _B2BDashboardScreenState();
}

class _B2BDashboardScreenState extends State<B2BDashboardScreen> {
  late List<AnonymousCandidate> _candidates;

  @override
  void initState() {
    super.initState();
    _candidates = List<AnonymousCandidate>.from(mockCandidates);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              const _B2BHeader(),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 720;
                    final crossAxisCount = isWide ? 2 : 1;
                    final childAspectRatio = isWide ? 1.18 : 1.0;

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: _candidates.length,
                      itemBuilder: (context, index) {
                        final candidate = _candidates[index];

                        return _CandidateCard(
                          candidate: candidate,
                          onUnlock: () => _unlockCandidate(index),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _unlockCandidate(int index) {
    final candidate = _candidates[index];
    if (candidate.isUnlocked) {
      return;
    }

    setState(() {
      _candidates[index] = candidate.copyWith(isUnlocked: true);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Контакты ${candidate.displayName.toLowerCase()} успешно открыты',
        ),
      ),
    );
  }
}

class _B2BHeader extends StatelessWidget {
  const _B2BHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: GlassPanel(
        radius: 32,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF141B33).withValues(alpha: 0.95),
            const Color(0xFF0A1020).withValues(alpha: 0.86),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF59A8FF).withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF59A8FF), Color(0xFF34D1BF)],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    LucideIcons.shieldCheck,
                    color: Color(0xFF04111A),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Биржа талантов',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Анонимный найм без фото и имен: только архетип, сигналы и реальный match со стеком компании.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'B2B DASHBOARD',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _SignalChip(
                  label: 'Anti-bias hiring',
                  color: Color(0xFF59A8FF),
                ),
                _SignalChip(
                  label: 'LIFT-coin monetization',
                  color: Color(0xFFFFC857),
                ),
                _SignalChip(
                  label: 'AI talent marketplace',
                  color: Color(0xFF51E6A9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({required this.candidate, required this.onUnlock});

  final AnonymousCandidate candidate;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final isUnlocked = candidate.isUnlocked;

    return GlassPanel(
      radius: 30,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF131D32).withValues(alpha: 0.94),
          const Color(0xFF0B101D).withValues(alpha: 0.84),
        ],
      ),
      borderColor:
          (isUnlocked ? const Color(0xFF51E6A9) : const Color(0xFF59A8FF))
              .withValues(alpha: isUnlocked ? 0.26 : 0.16),
      boxShadow: [
        BoxShadow(
          color:
              (isUnlocked ? const Color(0xFF51E6A9) : const Color(0xFF59A8FF))
                  .withValues(alpha: 0.12),
          blurRadius: 30,
          offset: const Offset(0, 18),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CandidateOrb(archetype: candidate.archetype),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Анонимный кандидат #${candidate.id}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Архетип: ${candidate.archetype}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MatchScoreRing(percentage: candidate.matchPercentage),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.analytics_outlined,
                  size: 18,
                  color: Color(0xFF7EBBFF),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Match с вашим стеком: ${candidate.matchPercentage}%',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: candidate.topSkills.map((skill) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                child: Text(
                  skill,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
          const Spacer(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: isUnlocked
                ? Container(
                    key: const ValueKey('unlocked'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF51E6A9).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF51E6A9).withValues(alpha: 0.24),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.checkCircle2,
                          color: Color(0xFF51E6A9),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Контакты открыты: ${candidate.contactEmail}',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFF9BF0C7),
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('locked'),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onUnlock,
                      icon: const Icon(LucideIcons.unlock),
                      label: const Text(
                        'Разблокировать контакты (Списать 1 LIFT-coin)',
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CandidateOrb extends StatelessWidget {
  const _CandidateOrb({required this.archetype});

  final String archetype;

  @override
  Widget build(BuildContext context) {
    final colors = _colorsForArchetype(archetype);

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Icon(_iconForArchetype(archetype), color: Colors.white, size: 28),
        ],
      ),
    );
  }

  List<Color> _colorsForArchetype(String value) {
    if (value.toLowerCase().contains('лидер')) {
      return const [Color(0xFFFFC857), Color(0xFFFF7A59)];
    }

    if (value.toLowerCase().contains('систем')) {
      return const [Color(0xFF59A8FF), Color(0xFF4567FF)];
    }

    if (value.toLowerCase().contains('эмпат')) {
      return const [Color(0xFF34D1BF), Color(0xFF59A8FF)];
    }

    return const [Color(0xFFFF7AC6), Color(0xFF7D5CFF)];
  }

  IconData _iconForArchetype(String value) {
    if (value.toLowerCase().contains('лидер')) {
      return LucideIcons.crown;
    }

    if (value.toLowerCase().contains('систем')) {
      return LucideIcons.cpu;
    }

    if (value.toLowerCase().contains('эмпат')) {
      return LucideIcons.heartHandshake;
    }

    return LucideIcons.sparkles;
  }
}

class _SignalChip extends StatelessWidget {
  const _SignalChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
