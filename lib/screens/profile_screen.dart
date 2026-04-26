import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../models/mock_data.dart';
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
    final baseProfile = hasAiProfile ? liftProvider.analyticsProfile : null;
    final mergedScores = hasAiProfile && baseProfile != null
        ? appProvider.composeLiftRadar(baseProfile.radarScores)
        : {for (final axis in LiftAxes.all) axis: 0.0};

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
          SafeArea(
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
                  hasAiProfile: hasAiProfile,
                  hrValue: appProvider.overallHrValue,
                  achievementsCount: appProvider.savedAchievements.length,
                  currentLevel: appProvider.currentLevel,
                  currentXP: appProvider.currentXP,
                  xpToNextLevel: appProvider.xpToNextLevel,
                  xpNeededForNextLevel: appProvider.xpNeededForNextLevel,
                ),
                const SizedBox(height: 16),
                _AnalyticsCard(
                  profile: baseProfile,
                  hasAiProfile: hasAiProfile,
                  mergedScores: mergedScores,
                ),
                const SizedBox(height: 16),
                _DailyQuizCard(
                  canClaim: appProvider.canClaimDailyQuizBoost,
                  hasActiveSession: appProvider.hasActiveDailyQuizSession,
                  isFinished: appProvider.isDailyQuizFinished,
                  rewardXp: appProvider.dailyQuizXpReward,
                  onPressed: () => _openDailyQuiz(context),
                ),
                const SizedBox(height: 16),
                _RegistrySection(achievements: appProvider.savedAchievements),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openDailyQuiz(BuildContext context) async {
    final appProvider = context.read<AppProvider>();

    if (!appProvider.canClaimDailyQuizBoost &&
        !appProvider.hasActiveDailyQuizSession) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Ежедневный AI-квиз уже пройден. Возвращайся завтра.',
            ),
          ),
        );
      return;
    }

    appProvider.startDailyQuizSession();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (_) => const _DailyQuizSheet(),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.userName,
    required this.archetype,
    required this.suggestedCareer,
    required this.hasAiProfile,
    required this.hrValue,
    required this.achievementsCount,
    required this.currentLevel,
    required this.currentXP,
    required this.xpToNextLevel,
    required this.xpNeededForNextLevel,
  });

  final String userName;
  final String archetype;
  final String suggestedCareer;
  final bool hasAiProfile;
  final double hrValue;
  final int achievementsCount;
  final int currentLevel;
  final int currentXP;
  final int xpToNextLevel;
  final int xpNeededForNextLevel;

  @override
  Widget build(BuildContext context) {
    final progress = xpToNextLevel == 0
        ? 0.0
        : (currentXP / xpToNextLevel).clamp(0.0, 1.0).toDouble();

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
          const SizedBox(height: 20),
          Text(
            'Твой LIFT Rank: $currentLevel Уровень',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: ShaderMask(
              shaderCallback: (bounds) {
                return const LinearGradient(
                  colors: [
                    Color(0xFF34D1BF),
                    Color(0xFF59A8FF),
                    Color(0xFFAF5CFF),
                  ],
                ).createShader(bounds);
              },
              blendMode: BlendMode.srcATop,
              child: LinearProgressIndicator(
                minHeight: 12,
                value: progress,
                backgroundColor: Colors.white.withValues(alpha: 0.06),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$currentXP / $xpToNextLevel XP. Тебе нужно еще $xpNeededForNextLevel XP, чтобы получить новый уровень.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white60,
              height: 1.4,
            ),
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
    required this.mergedScores,
  });

  final AnalyticsProfileModel? profile;
  final bool hasAiProfile;
  final Map<String, double> mergedScores;

  @override
  Widget build(BuildContext context) {
    final entries = LiftAxes.all
        .map((axis) => RadarEntry(value: mergedScores[axis] ?? 0))
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
                : 'Сначала заверши AI-аналитику в свайпах. После этого радар откроется и начнет усиливаться достижениями и ежедневным AI-квизом.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70, height: 1.5),
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
                    titlePositionPercentageOffset: 0.16,
                    titleTextStyle: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                    getTitle: (index, angle) {
                      return RadarChartTitle(
                        text: _friendlyAxisName(LiftAxes.all[index]),
                        angle: angle,
                      );
                    },
                    dataSets: [
                      RadarDataSet(
                        dataEntries: entries,
                        fillColor: hasAiProfile
                            ? const Color(0xFF59A8FF).withValues(alpha: 0.20)
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
            const SizedBox(height: 14),
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

  String _friendlyAxisName(String axis) {
    switch (axis) {
      case LiftAxes.communication:
        return 'Лидерство';
      case LiftAxes.logic:
        return 'Аналитика';
      case LiftAxes.creativity:
        return 'Творчество';
      case LiftAxes.organization:
        return 'Системность';
      case LiftAxes.technical:
        return 'Техничность';
    }
    return axis;
  }
}

class _DailyQuizCard extends StatelessWidget {
  const _DailyQuizCard({
    required this.canClaim,
    required this.hasActiveSession,
    required this.isFinished,
    required this.rewardXp,
    required this.onPressed,
  });

  final bool canClaim;
  final bool hasActiveSession;
  final bool isFinished;
  final int rewardXp;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isEnabled = canClaim || hasActiveSession;
    final buttonLabel = hasActiveSession
        ? 'Продолжить AI-квиз'
        : 'Пройти ежедневный AI-квиз (+$rewardXp XP)';

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      canClaim
                          ? '3 коротких AI-вопроса, +30 XP к рангу и буст навыков в профиле.'
                          : 'Сегодня бонус уже забран. Новый AI-квиз откроется завтра.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isEnabled ? onPressed : null,
              icon: Icon(
                isFinished && !canClaim
                    ? LucideIcons.checkCircle2
                    : LucideIcons.sparkles,
              ),
              label: Text(isEnabled ? buttonLabel : 'Квиз уже пройден'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyQuizSheet extends StatelessWidget {
  const _DailyQuizSheet();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.92;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 24, 12, bottomInset + 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: GlassPanel(
          radius: 34,
          blur: 30,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF121E39).withValues(alpha: 0.96),
              const Color(0xFF0A1020).withValues(alpha: 0.90),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF59A8FF).withValues(alpha: 0.14),
              blurRadius: 32,
              offset: const Offset(0, 20),
            ),
          ],
          child: SafeArea(
            top: false,
            child: Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                final question = appProvider.currentDailyQuizQuestion;
                final isFinished = appProvider.isDailyQuizFinished;
                final questionNumber = (appProvider.quizStep + 1).clamp(
                  1,
                  dailyQuizQuestions.length,
                );
                final progress = dailyQuizQuestions.isEmpty
                    ? 0.0
                    : (questionNumber / dailyQuizQuestions.length)
                          .clamp(0.0, 1.0)
                          .toDouble();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Ежедневный AI-квиз',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (!isFinished) ...[
                      Row(
                        children: [
                          Text(
                            'Вопрос $questionNumber / ${dailyQuizQuestions.length}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          Text(
                            '+${appProvider.dailyQuizXpReward} XP',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: const Color(0xFF66F0D7),
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return const LinearGradient(
                              colors: [
                                Color(0xFF34D1BF),
                                Color(0xFF59A8FF),
                                Color(0xFFAF5CFF),
                              ],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.srcATop,
                          child: LinearProgressIndicator(
                            minHeight: 10,
                            value: progress,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.06,
                            ),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GlassPanel(
                                radius: 26,
                                color: Colors.white.withValues(alpha: 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF59A8FF,
                                            ).withValues(alpha: 0.14),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            LucideIcons.bot,
                                            color: Color(0xFF7EBBFF),
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            'AI-сценарий дня',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w800,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      question?.questionText ?? '',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            height: 1.25,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 18),
                              _QuizAnswerButton(
                                accentColor: const Color(0xFFFFB457),
                                title: 'Вариант А',
                                text: question?.optionA ?? '',
                                onTap: () => context
                                    .read<AppProvider>()
                                    .submitQuizAnswer(0),
                              ),
                              const SizedBox(height: 12),
                              _QuizAnswerButton(
                                accentColor: const Color(0xFF34D1BF),
                                title: 'Вариант Б',
                                text: question?.optionB ?? '',
                                onTap: () => context
                                    .read<AppProvider>()
                                    .submitQuizAnswer(1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(
                                    0xFF51E6A9,
                                  ).withValues(alpha: 0.16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF51E6A9,
                                      ).withValues(alpha: 0.24),
                                      blurRadius: 28,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  LucideIcons.checkCircle2,
                                  size: 42,
                                  color: Color(0xFF51E6A9),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Квиз пройден!',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '+${appProvider.dailyQuizXpReward} XP и твой Радар обновлен',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Colors.white70,
                                      height: 1.5,
                                    ),
                              ),
                              const SizedBox(height: 22),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const Icon(LucideIcons.check),
                                  label: const Text('Закрыть'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizAnswerButton extends StatelessWidget {
  const _QuizAnswerButton({
    required this.accentColor,
    required this.title,
    required this.text,
    required this.onTap,
  });

  final Color accentColor;
  final String title;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      radius: 22,
      color: accentColor.withValues(alpha: 0.08),
      borderColor: accentColor.withValues(alpha: 0.20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accentColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            'Сертификаты, проекты и волонтерство, которые усиливают твой HR-профиль и влияют на общую оценку.',
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
                'Пока нет достижений. Добавь первый сертификат или проект в Реестре, чтобы начать прокачку профиля.',
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
