import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/question_model.dart';
import '../providers/lift_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_panel.dart';
import 'analytics_screen.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  bool _isTransitioningToAnalytics = false;

  @override
  void dispose() {
    unawaited(_swiperController.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final liftProvider = context.watch<LiftProvider>();
    final questions = liftProvider.questions;
    final isCompleted = liftProvider.isAssessmentCompleted;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 112),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SwipeHeader(),
                    const SizedBox(height: 14),
                    _ProgressPanel(
                      currentStep: liftProvider.currentQuestionIndex,
                      totalSteps: liftProvider.totalQuestions,
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      flex: 7,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        child: isCompleted
                            ? _CompletedSwipeState(
                                archetype: liftProvider.archetype,
                                hasAnalysisResult:
                                    liftProvider.hasAnalysisResult,
                                onOpenAnalytics: _openAnalytics,
                                onReset: () {
                                  context
                                      .read<LiftProvider>()
                                      .resetAssessment();
                                },
                              )
                            : CardSwiper(
                                key: ValueKey(liftProvider.assessmentSessionId),
                                controller: _swiperController,
                                cardsCount: questions.length,
                                isLoop: false,
                                numberOfCardsDisplayed: math.min(
                                  3,
                                  questions.length,
                                ),
                                padding: EdgeInsets.zero,
                                scale: 0.92,
                                maxAngle: 18,
                                backCardOffset: const Offset(0, 22),
                                duration: const Duration(milliseconds: 240),
                                allowedSwipeDirection:
                                    const AllowedSwipeDirection.only(
                                      left: true,
                                      right: true,
                                    ),
                                onSwipe:
                                    (previousIndex, currentIndex, direction) {
                                      return _handleSwipe(
                                        direction: direction,
                                        provider: context.read<LiftProvider>(),
                                      );
                                    },
                                cardBuilder:
                                    (
                                      context,
                                      index,
                                      horizontalOffsetPercentage,
                                      verticalOffsetPercentage,
                                    ) {
                                      final question = questions[index];
                                      return _SwipeQuestionCard(
                                        question: question,
                                        questionNumber: index + 1,
                                        totalQuestions: questions.length,
                                        horizontalOffsetPercentage:
                                            horizontalOffsetPercentage,
                                      );
                                    },
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!isCompleted)
                      _SwipeActions(
                        question: liftProvider.currentQuestion!,
                        isLocked: _isTransitioningToAnalytics,
                        onChooseA: () {
                          _swiperController.swipe(CardSwiperDirection.left);
                        },
                        onChooseB: () {
                          _swiperController.swipe(CardSwiperDirection.right);
                        },
                      ),
                  ],
                ),
              ),
              if (_isTransitioningToAnalytics || liftProvider.isAnalyzing)
                const Positioned.fill(child: _LiftAnalysisOverlay()),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _handleSwipe({
    required CardSwiperDirection direction,
    required LiftProvider provider,
  }) async {
    if (_isTransitioningToAnalytics || provider.isAssessmentCompleted) {
      return false;
    }

    HapticFeedback.lightImpact();

    final choice = direction == CardSwiperDirection.left
        ? QuestionChoice.optionA
        : QuestionChoice.optionB;

    provider.answerCurrentQuestion(choice);

    if (provider.isAssessmentCompleted) {
      HapticFeedback.heavyImpact();
      unawaited(_runAnalysisFlow());
    }

    return true;
  }

  Future<void> _runAnalysisFlow() async {
    if (_isTransitioningToAnalytics || !mounted) {
      return;
    }

    setState(() {
      _isTransitioningToAnalytics = true;
    });

    await context.read<LiftProvider>().runLiftAnalysis(
      delay: const Duration(milliseconds: 2800),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isTransitioningToAnalytics = false;
    });

    await _openAnalytics();
  }

  Future<void> _openAnalytics() async {
    if (!mounted) {
      return;
    }

    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AnalyticsScreen()));
  }
}

class _SwipeHeader extends StatelessWidget {
  const _SwipeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassPanel(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          radius: 20,
          color: const Color(0xFF101827).withValues(alpha: 0.68),
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
                'AI-Демистификатор',
                style: TextStyle(
                  color: Color(0xFF66F0D7),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'LIFT читает твой стиль мышления через серию быстрых решений.',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Выбирай instinctively: влево для варианта A, вправо для варианта B.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final progress = totalSteps == 0
        ? 0.0
        : (currentStep / totalSteps).clamp(0.0, 1.0).toDouble();

    return GlassPanel(
      radius: 26,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Swipe Progress',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${currentStep.clamp(0, totalSteps)}/$totalSteps',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(
                  height: 10,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 10,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF34D1BF),
                          Color(0xFF59A8FF),
                          Color(0xFFFF7AC6),
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

class _SwipeQuestionCard extends StatelessWidget {
  const _SwipeQuestionCard({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.horizontalOffsetPercentage,
  });

  final QuestionModel question;
  final int questionNumber;
  final int totalQuestions;
  final int horizontalOffsetPercentage;

  @override
  Widget build(BuildContext context) {
    final dragStrength = (horizontalOffsetPercentage.abs() / 100)
        .clamp(0.0, 1.0)
        .toDouble();
    final isRightBias = horizontalOffsetPercentage > 0;
    final theme = Theme.of(context);

    return GlassPanel(
      radius: 34,
      blur: 30,
      padding: const EdgeInsets.all(24),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF12203E).withValues(alpha: 0.92),
          const Color(0xFF0A1020).withValues(alpha: 0.88),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF59A8FF).withValues(alpha: 0.12),
          blurRadius: 34,
          offset: const Offset(0, 20),
        ),
      ],
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: _DecisionHalo(
              label: 'B',
              color: const Color(0xFF34D1BF),
              opacity: isRightBias ? dragStrength : 0,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: _DecisionHalo(
              label: 'A',
              color: const Color(0xFFFFB457),
              opacity: isRightBias ? 0 : dragStrength,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$questionNumber / $totalQuestions',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    LucideIcons.sparkles,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _AdaptiveQuestionText(
                          text: question.questionText,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _AnswerPreview(
                                accentColor: const Color(0xFFFFB457),
                                label: 'A',
                                text: question.optionA_Text,
                                alignment: CrossAxisAlignment.start,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _AnswerPreview(
                                accentColor: const Color(0xFF34D1BF),
                                label: 'B',
                                text: question.optionB_Text,
                                alignment: CrossAxisAlignment.end,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Свайпай карточку или используй кнопки ниже.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdaptiveQuestionText extends StatelessWidget {
  const _AdaptiveQuestionText({required this.text, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedStyle =
            style ?? Theme.of(context).textTheme.headlineMedium;
        double fontSize = 24;

        while (fontSize >= 14) {
          final painter = TextPainter(
            text: TextSpan(
              text: text,
              style: resolvedStyle?.copyWith(fontSize: fontSize),
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 5,
          )..layout(maxWidth: constraints.maxWidth);

          if (!painter.didExceedMaxLines) {
            break;
          }

          fontSize -= 1;
        }

        return Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
          style: resolvedStyle?.copyWith(fontSize: fontSize.clamp(14, 24)),
        );
      },
    );
  }
}

class _DecisionHalo extends StatelessWidget {
  const _DecisionHalo({
    required this.label,
    required this.color,
    required this.opacity,
  });

  final String label;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 120),
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.16),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 22),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _AnswerPreview extends StatelessWidget {
  const _AnswerPreview({
    required this.accentColor,
    required this.label,
    required this.text,
    required this.alignment,
    this.textAlign = TextAlign.left,
  });

  final Color accentColor;
  final String label;
  final String text;
  final CrossAxisAlignment alignment;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: accentColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          text,
          textAlign: textAlign,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white, height: 1.45),
        ),
      ],
    );
  }
}

class _SwipeActions extends StatelessWidget {
  const _SwipeActions({
    required this.question,
    required this.isLocked,
    required this.onChooseA,
    required this.onChooseB,
  });

  final QuestionModel question;
  final bool isLocked;
  final VoidCallback onChooseA;
  final VoidCallback onChooseB;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionChoiceButton(
            accentColor: const Color(0xFFFFB457),
            title: 'Вариант A',
            subtitle: question.optionA_Text,
            icon: Icons.west_rounded,
            isLocked: isLocked,
            onPressed: onChooseA,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionChoiceButton(
            accentColor: const Color(0xFF34D1BF),
            title: 'Вариант B',
            subtitle: question.optionB_Text,
            icon: Icons.east_rounded,
            isLocked: isLocked,
            onPressed: onChooseB,
          ),
        ),
      ],
    );
  }
}

class _ActionChoiceButton extends StatelessWidget {
  const _ActionChoiceButton({
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isLocked,
    required this.onPressed,
  });

  final Color accentColor;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isLocked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: EdgeInsets.zero,
      radius: 20,
      color: accentColor.withValues(alpha: 0.08),
      borderColor: accentColor.withValues(alpha: 0.22),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(icon, color: accentColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontSize: 12,
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

class _CompletedSwipeState extends StatelessWidget {
  const _CompletedSwipeState({
    required this.archetype,
    required this.hasAnalysisResult,
    required this.onOpenAnalytics,
    required this.onReset,
  });

  final String archetype;
  final bool hasAnalysisResult;
  final VoidCallback onOpenAnalytics;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      key: const ValueKey('completed-swipe-state'),
      radius: 32,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0E1730).withValues(alpha: 0.92),
          const Color(0xFF0B111E).withValues(alpha: 0.82),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF34D1BF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'AI-профиль готов',
              style: TextStyle(
                color: Color(0xFF66F0D7),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          Text(archetype, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(
            hasAnalysisResult
                ? 'Ты уже можешь открыть FULL ANALYTICS, сохранить AI-портфолио и перейти в Jasa.'
                : 'Ответы зафиксированы. Аналитика почти готова.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: hasAnalysisResult ? onOpenAnalytics : null,
              icon: const Icon(LucideIcons.barChartBig),
              label: const Text('Открыть FULL ANALYTICS'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(LucideIcons.refreshCw),
              label: const Text('Пройти заново'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiftAnalysisOverlay extends StatelessWidget {
  const _LiftAnalysisOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF040712).withValues(alpha: 0.86),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: GlassPanel(
            radius: 32,
            blur: 32,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0D1730).withValues(alpha: 0.94),
                const Color(0xFF09111F).withValues(alpha: 0.9),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _PulseIndicator(),
                const SizedBox(height: 22),
                Text(
                  'Нейросеть LIFT анализирует ваш профиль...',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(height: 1.35),
                ),
                const SizedBox(height: 12),
                Text(
                  'Сопоставляем поведенческие паттерны, усиливаем архетип и считаем карьерный вектор.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseIndicator extends StatefulWidget {
  const _PulseIndicator();

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 108,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = _controller.value;
          final scale = 0.86 + (math.sin(t * math.pi * 2) * 0.08);

          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: 1.2 + (t * 0.25),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF59A8FF).withValues(
                      alpha: (0.18 * (1 - t)).clamp(0.0, 0.18).toDouble(),
                    ),
                  ),
                ),
              ),
              Transform.scale(
                scale: scale,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF34D1BF), Color(0xFF59A8FF)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF59A8FF).withValues(alpha: 0.32),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    LucideIcons.brainCircuit,
                    color: Color(0xFF04111A),
                    size: 30,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
