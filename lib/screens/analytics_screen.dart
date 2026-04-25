import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/analytics_profile_model.dart';
import '../models/lift_taxonomy.dart';
import '../providers/lift_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/glass_panel.dart';
import '../widgets/lift_backdrop.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final liftProvider = context.watch<LiftProvider>();
    final profile = liftProvider.analyticsProfile;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LiftBackdrop(
        primaryGlow: const Color(0xFF4C8DFF),
        secondaryGlow: const Color(0xFF34D1BF),
        tertiaryGlow: const Color(0xFFFFC857),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _AnalyticsHeader(
                        onBack: () => Navigator.of(context).maybePop(),
                        onReset: () {
                          context.read<LiftProvider>().resetAssessment();
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(height: 18),
                      _ProfileHero(profile: profile),
                      const SizedBox(height: 16),
                      _RadarPanel(profile: profile),
                      const SizedBox(height: 16),
                      _VerdictPanel(profile: profile),
                      const SizedBox(height: 18),
                      _AnalyticsActions(
                        isSaved: liftProvider.isPortfolioSaved,
                        onSave: () {
                          context.read<LiftProvider>().savePortfolio();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('AI-портфолио сохранено в профиль'),
                            ),
                          );
                        },
                        onGoToJasa: () {
                          final lift = context.read<LiftProvider>();
                          lift.savePortfolio();
                          context.read<NavigationProvider>().changeTab(2);
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader({required this.onBack, required this.onReset});

  final VoidCallback onBack;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _HeaderIconButton(icon: LucideIcons.arrowLeft, onPressed: onBack),
        const Spacer(),
        Text(
          'FULL ANALYTICS',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        _HeaderIconButton(icon: LucideIcons.refreshCw, onPressed: onReset),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(12),
      radius: 18,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.profile});

  final AnalyticsProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 32,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0F1B35).withValues(alpha: 0.92),
          const Color(0xFF0C1326).withValues(alpha: 0.88),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF34D1BF).withValues(alpha: 0.12),
          blurRadius: 30,
          offset: const Offset(0, 18),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF34D1BF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  LucideIcons.brainCircuit,
                  size: 16,
                  color: Color(0xFF66F0D7),
                ),
                SizedBox(width: 8),
                Text(
                  'Твой профиль',
                  style: TextStyle(
                    color: Color(0xFF66F0D7),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            profile.archetype,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              height: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'LIFT увидел в тебе сочетание сильных паттернов поведения, которые уже сейчас формируют карьерный архетип.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: profile.dominantTags.map<Widget>((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _RadarPanel extends StatelessWidget {
  const _RadarPanel({required this.profile});

  final AnalyticsProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final scores = profile.radarScores;
    final entries = LiftAxes.all
        .map((axis) => RadarEntry(value: scores[axis] ?? 0))
        .toList();

    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.barChartBig, color: Color(0xFF59A8FF)),
              const SizedBox(width: 10),
              Text('Radar DNA', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: 1.08,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                dataSets: [
                  RadarDataSet(
                    dataEntries: entries,
                    fillColor: const Color(0xFF59A8FF).withValues(alpha: 0.16),
                    borderColor: const Color(0xFF59A8FF),
                    borderWidth: 2.4,
                    entryRadius: 3.8,
                  ),
                ],
                titleTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
                getTitle: (index, angle) {
                  return RadarChartTitle(
                    text: LiftAxes.all[index],
                    angle: angle,
                  );
                },
                tickCount: 5,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                tickBorderData: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                gridBorderData: BorderSide(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                radarBorderData: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                radarBackgroundColor: Colors.transparent,
                titlePositionPercentageOffset: 0.18,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...LiftAxes.all.map((axis) {
            final value = scores[axis] ?? 0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _AxisMeter(axis: axis, value: value),
            );
          }),
        ],
      ),
    );
  }
}

class _AxisMeter extends StatelessWidget {
  const _AxisMeter({required this.axis, required this.value});

  final String axis;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                axis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ),
            Text(
              value.toStringAsFixed(1),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: (value / 10).clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.06),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF59A8FF)),
          ),
        ),
      ],
    );
  }
}

class _VerdictPanel extends StatelessWidget {
  const _VerdictPanel({required this.profile});

  final AnalyticsProfileModel profile;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF151127).withValues(alpha: 0.92),
          const Color(0xFF101827).withValues(alpha: 0.82),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, color: Color(0xFFFFC857)),
              const SizedBox(width: 10),
              Text('AI-Вердикт', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile.aiVerdict,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.7),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsActions extends StatelessWidget {
  const _AnalyticsActions({
    required this.isSaved,
    required this.onSave,
    required this.onGoToJasa,
  });

  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onGoToJasa;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSave,
            icon: Icon(isSaved ? LucideIcons.checkCircle2 : LucideIcons.save),
            label: Text(
              isSaved ? 'AI-портфолио сохранено' : 'Сохранить AI-портфолио',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF34D1BF),
              foregroundColor: const Color(0xFF04111A),
              elevation: 0,
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onGoToJasa,
            icon: const Icon(LucideIcons.rocket),
            label: const Text('Сохранить AI-портфолио и перейти в Jasa'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              minimumSize: const Size.fromHeight(58),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
