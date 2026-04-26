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
import 'main_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final liftProvider = context.watch<LiftProvider>();
    final profile = liftProvider.analyticsProfile;
    final careerMatches = _buildCareerMatches(profile);
    final trajectory = _buildTrajectory(profile, careerMatches);

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
                      ),
                      const SizedBox(height: 18),
                      _RadarPanel(profile: profile),
                      const SizedBox(height: 16),
                      _CareerMatchingPanel(matches: careerMatches),
                      const SizedBox(height: 16),
                      _TrajectoryPanel(plan: trajectory),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<LiftProvider>().savePortfolio();
                            context.read<NavigationProvider>().changeTab(2);
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute<void>(
                                builder: (_) => const MainScreen(),
                              ),
                              (route) => false,
                            );
                          },
                          icon: const Icon(LucideIcons.rocket),
                          label: const Text('Перейти к стажировкам (Jasa)'),
                        ),
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

  List<_CareerMatch> _buildCareerMatches(AnalyticsProfileModel profile) {
    final dominantTags = profile.dominantTags.toSet();
    final scores = profile.radarScores;

    final matches = _careerTemplates.map((template) {
      double weightedSum = 0;
      double totalWeight = 0;

      for (final entry in template.axisWeights.entries) {
        weightedSum += ((scores[entry.key] ?? 0) / 10) * entry.value;
        totalWeight += entry.value;
      }

      final weightedScore = totalWeight == 0 ? 0.5 : weightedSum / totalWeight;
      final tagOverlap = dominantTags
          .where((tag) => template.relatedTags.contains(tag))
          .length;
      final tagBonus = template.relatedTags.isEmpty
          ? 0.0
          : (tagOverlap / template.relatedTags.length) * 0.10;
      final archetypeBonus =
          template.preferredArchetypes.contains(profile.archetype)
          ? 0.14
          : 0.04;
      final rawScore = ((weightedScore * 0.78) + tagBonus + archetypeBonus)
          .clamp(0.0, 1.0);
      final percentage = (68 + (rawScore * 31)).round().clamp(72, 99);

      return _CareerMatch(
        title: template.title,
        subtitle: template.subtitle,
        percentage: percentage,
        gapAxis: _lowestRelevantAxis(scores, template.axisWeights),
        strongestAxis: _strongestRelevantAxis(scores, template.axisWeights),
      );
    }).toList()..sort((a, b) => b.percentage.compareTo(a.percentage));

    return matches.take(3).toList();
  }

  _TrajectoryPlan _buildTrajectory(
    AnalyticsProfileModel profile,
    List<_CareerMatch> matches,
  ) {
    final targetCareer = matches.first;
    final missingAxis = targetCareer.gapAxis;
    final strongestAxis = targetCareer.strongestAxis;

    return _TrajectoryPlan(
      title: 'Образовательная траектория',
      description:
          'Чтобы стать ${targetCareer.title}, тебе стоит усилить ${_axisGapLabel(missingAxis)}. '
          'У тебя уже сильная база в ${_axisStrengthLabel(strongestAxis)}, поэтому именно этот следующий апгрейд даст самый быстрый карьерный рост. '
          '${_axisActionHint(missingAxis)}',
    );
  }

  String _lowestRelevantAxis(
    Map<String, double> scores,
    Map<String, double> weights,
  ) {
    final relevantAxes = weights.keys.toList();

    relevantAxes.sort((a, b) {
      final byScore = (scores[a] ?? 0).compareTo(scores[b] ?? 0);
      if (byScore != 0) {
        return byScore;
      }

      return a.compareTo(b);
    });

    return relevantAxes.first;
  }

  String _strongestRelevantAxis(
    Map<String, double> scores,
    Map<String, double> weights,
  ) {
    final relevantAxes = weights.keys.toList();

    relevantAxes.sort((a, b) {
      final byScore = (scores[b] ?? 0).compareTo(scores[a] ?? 0);
      if (byScore != 0) {
        return byScore;
      }

      return a.compareTo(b);
    });

    return relevantAxes.first;
  }

  String _axisGapLabel(String axis) {
    switch (axis) {
      case LiftAxes.communication:
        return 'коммуникацию и уверенную публичную подачу';
      case LiftAxes.logic:
        return 'аналитику и структурирование решений';
      case LiftAxes.creativity:
        return 'креативное исследование и упаковку идей';
      case LiftAxes.organization:
        return 'организацию процессов и проектную дисциплину';
      case LiftAxes.technical:
        return 'технические хард-скиллы и прототипирование';
    }

    return 'ключевой карьерный навык';
  }

  String _axisStrengthLabel(String axis) {
    switch (axis) {
      case LiftAxes.communication:
        return 'коммуникации';
      case LiftAxes.logic:
        return 'логике';
      case LiftAxes.creativity:
        return 'креативности';
      case LiftAxes.organization:
        return 'организации';
      case LiftAxes.technical:
        return 'техничности';
    }

    return 'сильной базе';
  }

  String _axisActionHint(String axis) {
    switch (axis) {
      case LiftAxes.communication:
        return 'Загрузи в Реестр сертификаты по дебатам, TEDx, лидерским программам или выбери в Jasa роли с живой коммуникацией и модерацией.';
      case LiftAxes.logic:
        return 'Загрузи в Реестр сертификаты по математике, аналитике или олимпиадам и откликнись в Jasa на роли, где нужно работать с данными и гипотезами.';
      case LiftAxes.creativity:
        return 'Добавь в Реестр курсы по дизайну, медиа или UX и посмотри в Jasa активности, где можно нарабатывать сторителлинг и исследование пользователей.';
      case LiftAxes.organization:
        return 'Подсвети в Реестре кейсы, где ты управлял(а) проектами, и выбери в Jasa координационные или event-роли, чтобы прокачать delivery.';
      case LiftAxes.technical:
        return 'Загрузи сертификаты по Python, AI или разработке в Реестр и найди в Jasa стажировку, где можно потрогать реальные цифровые инструменты.';
    }

    return 'Используй Реестр и Jasa, чтобы закрыть недостающий навык через сертификаты и практический опыт.';
  }
}

class _AnalyticsHeader extends StatelessWidget {
  const _AnalyticsHeader({required this.onBack});

  final VoidCallback onBack;

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
        const SizedBox(width: 42),
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
      radius: 32,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF101A31).withValues(alpha: 0.94),
          const Color(0xFF0B1221).withValues(alpha: 0.84),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF59A8FF).withValues(alpha: 0.10),
          blurRadius: 26,
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
            profile.aiVerdict,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: profile.dominantTags.map((tag) {
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
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(LucideIcons.barChartBig, color: Color(0xFF59A8FF)),
              const SizedBox(width: 10),
              Text(
                'Радарная диаграмма качеств',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: 1.02,
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                dataSets: [
                  RadarDataSet(
                    dataEntries: entries,
                    fillColor: const Color(0xFF59A8FF).withValues(alpha: 0.18),
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
                  color: Colors.white.withValues(alpha: 0.10),
                ),
                radarBackgroundColor: Colors.transparent,
                titlePositionPercentageOffset: 0.16,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          const SizedBox(height: 14),
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

class _CareerMatchingPanel extends StatelessWidget {
  const _CareerMatchingPanel({required this.matches});

  final List<_CareerMatch> matches;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 32,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF141126).withValues(alpha: 0.94),
          const Color(0xFF0D1421).withValues(alpha: 0.84),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFFC857).withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 18),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.sparkles, color: Color(0xFFFFC857)),
              const SizedBox(width: 10),
              Text(
                'AI-Карьерный Метчинг',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'LIFT сопоставил твой поведенческий профиль с профессиями будущего и показал, где у тебя уже есть сильный потенциал.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 18),
          ...List.generate(matches.length, (index) {
            final match = matches[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == matches.length - 1 ? 0 : 14,
              ),
              child: _CareerMatchCard(match: match),
            );
          }),
        ],
      ),
    );
  }
}

class _CareerMatchCard extends StatelessWidget {
  const _CareerMatchCard({required this.match});

  final _CareerMatch match;

  @override
  Widget build(BuildContext context) {
    final percentageFactor = (match.percentage / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
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
                      match.title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontSize: 19),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      match.subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${match.percentage}%',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF66F0D7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                FractionallySizedBox(
                  widthFactor: percentageFactor,
                  child: Container(
                    height: 10,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF34D1BF), Color(0xFF59A8FF)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _TinySignal(
                text: 'Сильная ось: ${match.strongestAxis}',
                color: const Color(0xFF59A8FF),
              ),
              _TinySignal(
                text: 'Нужно усилить: ${match.gapAxis}',
                color: const Color(0xFFFFC857),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrajectoryPanel extends StatelessWidget {
  const _TrajectoryPanel({required this.plan});

  final _TrajectoryPlan plan;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 32,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF101827).withValues(alpha: 0.94),
          const Color(0xFF0A111B).withValues(alpha: 0.84),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_rounded, color: Color(0xFF7EBBFF)),
              const SizedBox(width: 10),
              Text(plan.title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            plan.description,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.68),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF34D1BF).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF34D1BF).withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  LucideIcons.brainCircuit,
                  size: 18,
                  color: Color(0xFF66F0D7),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'AI-рекомендация: сначала закрой недостающий навык через Реестр, затем закрепи его практикой в Jasa.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.45,
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

class _TinySignal extends StatelessWidget {
  const _TinySignal({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _CareerTemplate {
  const _CareerTemplate({
    required this.title,
    required this.subtitle,
    required this.axisWeights,
    required this.relatedTags,
    required this.preferredArchetypes,
  });

  final String title;
  final String subtitle;
  final Map<String, double> axisWeights;
  final List<String> relatedTags;
  final List<String> preferredArchetypes;
}

class _CareerMatch {
  const _CareerMatch({
    required this.title,
    required this.subtitle,
    required this.percentage,
    required this.gapAxis,
    required this.strongestAxis,
  });

  final String title;
  final String subtitle;
  final int percentage;
  final String gapAxis;
  final String strongestAxis;
}

class _TrajectoryPlan {
  const _TrajectoryPlan({required this.title, required this.description});

  final String title;
  final String description;
}

const List<_CareerTemplate> _careerTemplates = [
  _CareerTemplate(
    title: 'Product Manager',
    subtitle: 'Соединяет продукт, людей, аналитику и delivery в одну систему.',
    axisWeights: {
      LiftAxes.communication: 1.0,
      LiftAxes.organization: 1.0,
      LiftAxes.logic: 0.9,
      LiftAxes.creativity: 0.6,
    },
    relatedTags: ['Коммуникация', 'Организация', 'Лидерство', 'Стратегия'],
    preferredArchetypes: [
      LiftArchetypes.strategicArchitect,
      LiftArchetypes.empatheticLeader,
      LiftArchetypes.creativeVisionary,
    ],
  ),
  _CareerTemplate(
    title: 'AI-Тренер',
    subtitle: 'Обучает модели, объясняет ИИ людям и улучшает качество ответов.',
    axisWeights: {
      LiftAxes.technical: 1.0,
      LiftAxes.communication: 0.9,
      LiftAxes.logic: 0.8,
    },
    relatedTags: [
      'Техничность',
      'Автоматизация',
      'Наставничество',
      'Коммуникация',
    ],
    preferredArchetypes: [
      LiftArchetypes.systemsIntegrator,
      LiftArchetypes.operationalEngineer,
      LiftArchetypes.empatheticLeader,
    ],
  ),
  _CareerTemplate(
    title: 'UX-Исследователь',
    subtitle:
        'Понимает мотивацию пользователей и переводит её в продуктовые решения.',
    axisWeights: {
      LiftAxes.communication: 1.0,
      LiftAxes.creativity: 0.9,
      LiftAxes.logic: 0.8,
    },
    relatedTags: ['UX-мышление', 'Эмпатия', 'Креативность', 'Аналитика'],
    preferredArchetypes: [
      LiftArchetypes.creativeVisionary,
      LiftArchetypes.empatheticLeader,
    ],
  ),
  _CareerTemplate(
    title: 'AI Product Analyst',
    subtitle:
        'Смотрит на данные, гипотезы и продуктовые метрики для роста AI-сервисов.',
    axisWeights: {
      LiftAxes.logic: 1.0,
      LiftAxes.technical: 0.9,
      LiftAxes.organization: 0.5,
    },
    relatedTags: ['Аналитика', 'Логика', 'Техничность', 'Системность'],
    preferredArchetypes: [
      LiftArchetypes.systemsIntegrator,
      LiftArchetypes.strategicArchitect,
    ],
  ),
  _CareerTemplate(
    title: 'Community Architect',
    subtitle: 'Строит сильные сообщества вокруг идей, продуктов и мероприятий.',
    axisWeights: {
      LiftAxes.communication: 1.0,
      LiftAxes.organization: 0.8,
      LiftAxes.creativity: 0.7,
    },
    relatedTags: ['Коммуникация', 'Лидерство', 'Эмпатия', 'Сторителлинг'],
    preferredArchetypes: [
      LiftArchetypes.empatheticLeader,
      LiftArchetypes.creativeVisionary,
    ],
  ),
  _CareerTemplate(
    title: 'Operations Designer',
    subtitle:
        'Проектирует процессы так, чтобы команды работали быстро и без хаоса.',
    axisWeights: {
      LiftAxes.organization: 1.0,
      LiftAxes.logic: 0.9,
      LiftAxes.technical: 0.6,
    },
    relatedTags: ['Организация', 'Системность', 'Дисциплина', 'Стратегия'],
    preferredArchetypes: [
      LiftArchetypes.operationalEngineer,
      LiftArchetypes.strategicArchitect,
    ],
  ),
];
