import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/job_match_result_model.dart';
import '../models/job_model.dart';
import '../providers/lift_provider.dart';
import '../widgets/glass_panel.dart';
import '../widgets/lift_backdrop.dart';
import '../widgets/match_score_ring.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final liftProvider = context.watch<LiftProvider>();
    final jobs = liftProvider.jobs;
    final matches = liftProvider.jobMatches;
    final hasProfile = liftProvider.answerHistory.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LiftBackdrop(
        primaryGlow: const Color(0xFF59A8FF),
        secondaryGlow: const Color(0xFF34D1BF),
        tertiaryGlow: const Color(0xFFFFC857),
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
                      _JobsHeader(
                        archetype: liftProvider.archetype,
                        hasProfile: hasProfile,
                      ),
                      const SizedBox(height: 18),
                      if (!hasProfile) const _ProfileHint(),
                      if (!hasProfile) const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final job = jobs[index];
                    final match =
                        matches[job.id] ??
                        const JobMatchResultModel(
                          percentage: 50,
                          matchedTags: [],
                          isPerfectFit: false,
                          isArchetypeAligned: false,
                        );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _JobCard(
                        job: job,
                        match: match,
                        isApplied: liftProvider.isJobApplied(job.id),
                      ),
                    );
                  }, childCount: jobs.length),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobsHeader extends StatelessWidget {
  const _JobsHeader({required this.archetype, required this.hasProfile});

  final String archetype;
  final bool hasProfile;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 32,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF111D37).withValues(alpha: 0.94),
          const Color(0xFF0A1020).withValues(alpha: 0.82),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF59A8FF).withValues(alpha: 0.1),
          blurRadius: 26,
          offset: const Offset(0, 18),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF59A8FF).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.badgeCheck,
                  color: Color(0xFF7EBBFF),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Powered by Jasa',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Подбор не только в IT: реальные проекты, медиа, ивенты и аналитика.',
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
            'JASA MARKETPLACE',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            hasProfile
                ? 'Матчи персонализированы под твой архетип: $archetype.'
                : 'Пройди AI-свайпы, чтобы получить более точный match score по вакансиям.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _ProfileHint extends StatelessWidget {
  const _ProfileHint();

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 24,
      child: Row(
        children: [
          const Icon(LucideIcons.sparkles, color: Color(0xFFFFC857)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Сейчас маркетплейс показывает базовые совпадения. После FULL ANALYTICS проценты станут умнее.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({
    required this.job,
    required this.match,
    required this.isApplied,
  });

  final JobModel job;
  final JobMatchResultModel match;
  final bool isApplied;

  @override
  Widget build(BuildContext context) {
    final matchedTags = match.matchedTags.toSet();

    return GlassPanel(
      radius: 30,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF131D32).withValues(alpha: 0.92),
          const Color(0xFF0B101D).withValues(alpha: 0.82),
        ],
      ),
      borderColor:
          (match.isPerfectFit
                  ? const Color(0xFF51E6A9)
                  : const Color(0xFF59A8FF))
              .withValues(alpha: match.isPerfectFit ? 0.24 : 0.14),
      boxShadow: [
        BoxShadow(
          color:
              (match.isPerfectFit
                      ? const Color(0xFF51E6A9)
                      : const Color(0xFF59A8FF))
                  .withValues(alpha: 0.12),
          blurRadius: 28,
          offset: const Offset(0, 18),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 21,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            job.companyName,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                        ),
                        if (job.isJasaVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            LucideIcons.badgeCheck,
                            size: 18,
                            color: Color(0xFF59A8FF),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MatchScoreRing(percentage: match.percentage),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: job.tagsNeeded.map((tag) {
              final isMatched = matchedTags.contains(tag);
              final color = isMatched ? const Color(0xFF34D1BF) : Colors.white;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isMatched
                      ? const Color(0xFF34D1BF).withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isMatched
                        ? const Color(0xFF34D1BF).withValues(alpha: 0.22)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  tag,
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (match.isPerfectFit)
                _SignalBadge(
                  text: 'Perfect for you',
                  color: const Color(0xFF51E6A9),
                ),
              if (match.isArchetypeAligned)
                _SignalBadge(
                  text: 'Archetype aligned',
                  color: const Color(0xFF59A8FF),
                ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: isApplied
                ? SizedBox(
                    key: const ValueKey('applied'),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF51E6A9),
                        disabledBackgroundColor: const Color(0xFF51E6A9),
                        disabledForegroundColor: const Color(0xFF04111A),
                      ),
                      icon: const Icon(LucideIcons.checkCircle2),
                      label: const Text('Успешно отправлено'),
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('apply'),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<LiftProvider>().applyToJob(job.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Портфолио успешно отправлено в Jasa!',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.rocket),
                      label: const Text('Откликнуться AI-портфолио'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SignalBadge extends StatelessWidget {
  const _SignalBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
