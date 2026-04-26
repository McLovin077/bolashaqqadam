import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../providers/lift_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_panel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final liftProvider = context.watch<LiftProvider>();
    final hasAiProfile = liftProvider.hasAnalysisResult;
    final aiProfile = hasAiProfile ? liftProvider.analyticsProfile : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'LIFT Profile',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: _StreakChip(streak: appProvider.dailyStreak)),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBackground(child: SizedBox.expand()),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              top: false,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 114),
                children: [
                  _ProfileHeroCard(
                    userName: appProvider.userName,
                    archetype: hasAiProfile
                        ? liftProvider.archetype
                        : 'AI-профиль еще не собран',
                    suggestedCareer: hasAiProfile
                        ? liftProvider.suggestedCareerTitle
                        : 'Пройди AI-аналитику, чтобы открыть карьерный вектор',
                    level: appProvider.overallLiftLevel,
                    hrValue: appProvider.overallHrValue,
                    achievementsCount: appProvider.savedAchievements.length,
                    hasAiProfile: hasAiProfile,
                  ),
                  const SizedBox(height: 16),
                  _AnalyticsCard(
                    profile: aiProfile,
                    hasAiProfile: hasAiProfile,
                    suggestedCareer: hasAiProfile
                        ? liftProvider.suggestedCareerTitle
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _DailyQuizCard(
                    canClaim: appProvider.canClaimDailyQuizBoost,
                    reward: appProvider.dailyQuizReward,
                    onPressed: () => _handleDailyQuiz(context),
                  ),
                  const SizedBox(height: 16),
                  _RegistrySection(achievements: appProvider.savedAchievements),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDailyQuiz(BuildContext context) {
    final appProvider = context.read<AppProvider>();
    final applied = appProvider.completeDailyQuizBoost();
    final axis = appProvider.lastDailyQuizBoostAxis ?? 'навыку';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            applied
                ? 'Ежедневный AI-квиз завершен: +${appProvider.dailyQuizReward} к оси "$axis".'
                : 'Ежедневный AI-квиз уже пройден сегодня. Возвращайся завтра.',
          ),
        ),
      );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.userName,
    required this.archetype,
    required this.suggestedCareer,
    required this.level,
    required this.hrValue,
    required this.achievementsCount,
    required this.hasAiProfile,
  });

  final String userName;
  final String archetype;
  final String suggestedCareer;
  final int level;
  final double hrValue;
  final int achievementsCount;
  final bool hasAiProfile;

  @override
  Widget build(BuildContext context) {
    final progress = ((hrValue % 10) / 10).clamp(0.12, 1.0);

    return GlassPanel(
      radius: 34,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF131E38).withValues(alpha: 0.96),
          const Color(0xFF0A1020).withValues(alpha: 0.88),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF59A8FF).withValues(alpha: 0.12),
          blurRadius: 32,
          offset: const Offset(0, 18),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AvatarBadge(userName: userName),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      archetype,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: hasAiProfile
                            ? const Color(0xFF89C6FF)
                            : Colors.white54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      suggestedCareer,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: hasAiProfile
                            ? const Color(0xFF66F0D7)
                            : Colors.white60,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF34D1BF).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF34D1BF).withValues(alpha: 0.24),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'LVL',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$level',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF66F0D7),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InfoBadge(
                icon: Icons.local_fire_department,
                label: 'RPG profile',
                value: hasAiProfile ? 'AI Ready' : 'Locked',
                color: const Color(0xFFFF9E57),
              ),
              _InfoBadge(
                icon: LucideIcons.badgeCheck,
                label: 'HR-Value',
                value: hrValue.toStringAsFixed(1),
                color: const Color(0xFF7EBBFF),
              ),
              _InfoBadge(
                icon: LucideIcons.folderKanban,
                label: 'Achievements',
                value: '$achievementsCount',
                color: const Color(0xFFB28CFF),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Общий уровень LIFT',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF34D1BF),
                          Color(0xFF59A8FF),
                          Color(0xFF9D68FF),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge({required this.userName});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final parts = userName.trim().split(' ').where((part) => part.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0]).join();

    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF59A8FF), Color(0xFF34D1BF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF59A8FF).withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF08111E),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        alignment: Alignment.center,
        child: Text(
          initials.isEmpty ? 'U' : initials,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white60,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({
    required this.profile,
    required this.hasAiProfile,
    required this.suggestedCareer,
  });

  final AnalyticsProfileModel? profile;
  final bool hasAiProfile;
  final String? suggestedCareer;

  @override
  Widget build(BuildContext context) {
    final scores = hasAiProfile && profile != null
        ? profile!.radarScores
        : {for (final axis in LiftAxes.all) axis: 0.0};
    final entries = LiftAxes.all
        .map((axis) => RadarEntry(value: scores[axis] ?? 0))
        .toList();

    return GlassPanel(
      radius: 32,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF101A31).withValues(alpha: 0.94),
          const Color(0xFF0B1221).withValues(alpha: 0.84),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.brainCircuit, color: Color(0xFF66F0D7)),
              const SizedBox(width: 10),
              Text(
                'Overall Analytics',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            hasAiProfile && profile != null
                ? profile!.aiVerdict
                : 'Сначала заверши AI-аналитику в свайпах. После этого радар заполнится, а LIFT покажет примерную профессию по твоему профилю.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70, height: 1.5),
          ),
          const SizedBox(height: 14),
          if (hasAiProfile && suggestedCareer != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF34D1BF).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'AI Career Match: $suggestedCareer',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF66F0D7),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1.02,
                child: RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    tickCount: 5,
                    ticksTextStyle: const TextStyle(color: Colors.transparent),
                    tickBorderData: BorderSide(
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                    gridBorderData: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    radarBorderData: BorderSide(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                    radarBackgroundColor: Colors.transparent,
                    titlePositionPercentageOffset: 0.18,
                    titleTextStyle: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                    getTitle: (index, angle) {
                      return RadarChartTitle(
                        text: LiftAxes.all[index],
                        angle: angle,
                      );
                    },
                    dataSets: [
                      RadarDataSet(
                        dataEntries: entries,
                        fillColor: hasAiProfile
                            ? const Color(0xFF59A8FF).withValues(alpha: 0.18)
                            : Colors.transparent,
                        borderColor: hasAiProfile
                            ? const Color(0xFF59A8FF)
                            : Colors.white.withValues(alpha: 0.08),
                        borderWidth: hasAiProfile ? 2.6 : 1.2,
                        entryRadius: hasAiProfile ? 3.5 : 0,
                      ),
                    ],
                  ),
                ),
              ),
              if (!hasAiProfile)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1628).withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        LucideIcons.lock,
                        size: 18,
                        color: Color(0xFF7EBBFF),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Радар откроется после AI-аналитики',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (hasAiProfile && profile != null) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: profile!.dominantTags.map((tag) {
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
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _DailyQuizCard extends StatelessWidget {
  const _DailyQuizCard({
    required this.canClaim,
    required this.reward,
    required this.onPressed,
  });

  final bool canClaim;
  final int reward;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 28,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF15172B).withValues(alpha: 0.94),
          const Color(0xFF0C1121).withValues(alpha: 0.84),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final button = _DailyQuizButton(
            canClaim: canClaim,
            onPressed: onPressed,
          );
          final info = _DailyQuizInfo(canClaim: canClaim, reward: reward);

          if (constraints.maxWidth < 360) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info,
                const SizedBox(height: 14),
                SizedBox(width: double.infinity, child: button),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: info),
              const SizedBox(width: 12),
              button,
            ],
          );
        },
      ),
    );
  }
}

class _DailyQuizInfo extends StatelessWidget {
  const _DailyQuizInfo({required this.canClaim, required this.reward});

  final bool canClaim;
  final int reward;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF9D68FF).withValues(alpha: 0.16),
          ),
          alignment: Alignment.center,
          child: const Icon(LucideIcons.swords, color: Color(0xFFCEB2FF)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ежедневный AI-квиз',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                canClaim
                    ? 'Пройди квиз и получи +$reward к самой слабой оси профиля.'
                    : 'Сегодня бонус уже получен. Завтра откроется новый буст.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DailyQuizButton extends StatelessWidget {
  const _DailyQuizButton({required this.canClaim, required this.onPressed});

  final bool canClaim;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(132, 52),
        backgroundColor: canClaim
            ? const Color(0xFF34D1BF)
            : Colors.white.withValues(alpha: 0.10),
        foregroundColor: canClaim ? const Color(0xFF04111A) : Colors.white54,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(canClaim ? 'Запустить' : 'Получено'),
    );
  }
}

class _RegistrySection extends StatelessWidget {
  const _RegistrySection({required this.achievements});

  final List<UserAchievement> achievements;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 32,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF111527).withValues(alpha: 0.94),
          const Color(0xFF0B1020).withValues(alpha: 0.86),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.folderKanban, color: Color(0xFF7EBBFF)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Smart Registry',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Сертификаты, проекты и волонтерство, которые реально усиливают HR-профиль.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          if (achievements.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Text(
                'Пока нет достижений. Добавь первый сертификат или проект, чтобы начать прокачку профиля.',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            )
          else
            ...achievements.map((achievement) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _AchievementCard(achievement: achievement),
              );
            }),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});

  final UserAchievement achievement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: _accentColor(achievement.type).withValues(alpha: 0.14),
                ),
                alignment: Alignment.center,
                child: Text(
                  achievement.typeEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      achievement.organization,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF34D1BF).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'HR-Value ${achievement.aiWeight.toStringAsFixed(1)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF66F0D7),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            achievement.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _SkillPill(
                icon: LucideIcons.calendarDays,
                label: achievement.dateLabel,
                color: const Color(0xFF7EBBFF),
              ),
              _SkillPill(
                icon: LucideIcons.badgeCheck,
                label: achievement.typeLabel,
                color: _accentColor(achievement.type),
              ),
              ...achievement.tags.take(3).map((tag) {
                return _SkillPill(
                  icon: LucideIcons.sparkles,
                  label: tag,
                  color: Colors.white70,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Color _accentColor(AchievementType type) {
    switch (type) {
      case AchievementType.certificate:
        return const Color(0xFF7EBBFF);
      case AchievementType.volunteer:
        return const Color(0xFFFFC857);
      case AchievementType.project:
        return const Color(0xFF34D1BF);
    }
  }
}

class _SkillPill extends StatelessWidget {
  const _SkillPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF9E57).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFFFF9E57).withValues(alpha: 0.24),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 18,
            color: Color(0xFFFF9E57),
          ),
          const SizedBox(width: 6),
          Text(
            '$streak',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
