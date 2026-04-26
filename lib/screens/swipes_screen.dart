import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../models/lift_taxonomy.dart';
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
    final isCompleted = liftProvider.isAssessmentCompleted;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 68, child: _SwipeHeader()),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 70,
                      child: _ProgressPanel(
                        currentStep: liftProvider.currentQuestionIndex,
                        totalSteps: liftProvider.totalQuestions,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (isCompleted)
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: _CompletedSwipeState(
                            archetype: liftProvider.archetype,
                            hasAnalysisResult: liftProvider.hasAnalysisResult,
                            onOpenAnalytics: _openAnalytics,
                            onReset: () {
                              context.read<LiftProvider>().resetAssessment();
                            },
                          ),
                        ),
                      )
                    else ...[
                      Expanded(
                        child: CardSwiper(
                          key: ValueKey(liftProvider.assessmentSessionId),
                          controller: _swiperController,
                          cardsCount: liftProvider.questions.length,
                          isLoop: false,
                          numberOfCardsDisplayed: math.min(
                            3,
                            liftProvider.questions.length,
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
                          onSwipe: (previousIndex, currentIndex, direction) {
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
                                final question = liftProvider.questions[index];
                                return _SwipeQuestionCard(
                                  question: question,
                                  questionNumber: index + 1,
                                  totalQuestions: liftProvider.totalQuestions,
                                  horizontalOffsetPercentage:
                                      horizontalOffsetPercentage,
                                );
                              },
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 168,
                        child: _SwipeInsightsZone(
                          question: liftProvider.currentQuestion!,
                          scores: liftProvider.radarScores,
                          isLocked: _isTransitioningToAnalytics,
                          onChooseA: () {
                            _swiperController.swipe(CardSwiperDirection.left);
                          },
                          onChooseB: () {
                            _swiperController.swipe(CardSwiperDirection.right);
                          },
                        ),
                      ),
                    ],
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

    await _openAnalytics();
  }

  Future<void> _openAnalytics() async {
    if (!mounted) {
      return;
    }

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const AnalyticsScreen()),
    );
  }
}

class _SwipeHeader extends StatelessWidget {
  const _SwipeHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(width: 54, height: 54),
        ),
        const Center(child: _LiftupWordmark()),
        Align(
          alignment: Alignment.centerRight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF55F2FF).withValues(alpha: 0.24),
                  blurRadius: 24,
                ),
              ],
            ),
            child: GlassPanel(
              padding: EdgeInsets.zero,
              radius: 20,
              blur: 22,
              color: const Color(0xFF0F1628).withValues(alpha: 0.70),
              borderColor: const Color(0xFF67F8FF).withValues(alpha: 0.30),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showGuide(context),
                  borderRadius: BorderRadius.circular(20),
                  child: const SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(
                      Icons.tips_and_updates_outlined,
                      size: 24,
                      color: Color(0xFF86FBFF),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showGuide(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 112),
          backgroundColor: const Color(0xFF10192B).withValues(alpha: 0.96),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          content: const Text(
            '💡 Короткий гайд: Выбирай инстинктивно. Свайп влево — вариант А, свайп вправо — вариант В.',
          ),
        ),
      );
  }
}

class _LiftupWordmark extends StatelessWidget {
  const _LiftupWordmark();

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w900,
      letterSpacing: 3.2,
      foreground: Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF78DEFF), Color(0xFF6F97FF), Color(0xFF4FE7FF)],
        ).createShader(const Rect.fromLTWH(0, 0, 280, 60)),
      shadows: [
        Shadow(
          color: const Color(0xFF65AFFF).withValues(alpha: 0.34),
          blurRadius: 28,
        ),
        Shadow(
          color: const Color(0xFF42F7FF).withValues(alpha: 0.18),
          blurRadius: 34,
        ),
      ],
    );

    return Text('LIFTUP', style: textStyle);
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
      radius: 30,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      color: const Color(0xFF121A2C).withValues(alpha: 0.88),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Swipe Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'Тест Профиля:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${currentStep.clamp(0, totalSteps)}/$totalSteps',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              children: [
                Container(
                  height: 8,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF37E3C7),
                          Color(0xFF55A2FF),
                          Color(0xFFD55CFF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFFA56BFF,
                          ).withValues(alpha: 0.28),
                          blurRadius: 16,
                        ),
                      ],
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

    return GlassPanel(
      radius: 38,
      blur: 34,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF192C4F).withValues(alpha: 0.95),
          const Color(0xFF0B1224).withValues(alpha: 0.90),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF64A8FF).withValues(alpha: 0.12),
          blurRadius: 30,
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
              color: const Color(0xFF3DE6C5),
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
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$questionNumber / $totalQuestions',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 18,
                    color: Colors.white.withValues(alpha: 0.88),
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
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w900,
                                height: 1.14,
                                fontSize: 27,
                              ),
                        ),
                        const SizedBox(height: 18),
                        _OptionShowcase(question: question),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionShowcase extends StatelessWidget {
  const _OptionShowcase({required this.question});

  final QuestionModel question;

  @override
  Widget build(BuildContext context) {
    final leftLabel = _compactOptionLabel(question.optionA_Text);
    final rightLabel = _compactOptionLabel(question.optionB_Text);

    return Container(
      height: 138,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2B3650).withValues(alpha: 0.92),
            const Color(0xFF1A2238).withValues(alpha: 0.88),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Positioned(
              left: -4,
              bottom: -6,
              child: Text(
                'A',
                style: TextStyle(
                  fontSize: 92,
                  height: 0.8,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFFFB457).withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -6,
              child: Text(
                'B',
                style: TextStyle(
                  fontSize: 90,
                  height: 0.8,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF45E7C6).withValues(alpha: 0.16),
                ),
              ),
            ),
            Positioned(
              left: -38,
              bottom: -48,
              child: Container(
                width: 156,
                height: 156,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFFA54A).withValues(alpha: 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFA54A).withValues(alpha: 0.08),
                      blurRadius: 54,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: -34,
              bottom: -40,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF3DE6C5).withValues(alpha: 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3DE6C5).withValues(alpha: 0.08),
                      blurRadius: 54,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 76,
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'A',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFFFC36B),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'B',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF5EF7DA),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          question.optionA_Text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                height: 1.28,
                              ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question.optionB_Text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                height: 1.28,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _OptionFootnote(
                        icon: _optionIcon(question.optionA_Text),
                        title: leftLabel,
                        alignRight: false,
                      ),
                      const Spacer(),
                      _OptionFootnote(
                        icon: _optionIcon(question.optionB_Text),
                        title: rightLabel,
                        alignRight: true,
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
}

class _OptionFootnote extends StatelessWidget {
  const _OptionFootnote({
    required this.icon,
    required this.title,
    required this.alignRight,
  });

  final IconData icon;
  final String title;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          textAlign: alignRight ? TextAlign.right : TextAlign.left,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
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
        double fontSize = 27;

        while (fontSize >= 15) {
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
          style: resolvedStyle?.copyWith(fontSize: fontSize.clamp(15, 27)),
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
            BoxShadow(color: color.withValues(alpha: 0.34), blurRadius: 22),
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

class _SwipeInsightsZone extends StatelessWidget {
  const _SwipeInsightsZone({
    required this.question,
    required this.scores,
    required this.isLocked,
    required this.onChooseA,
    required this.onChooseB,
  });

  final QuestionModel question;
  final Map<String, double> scores;
  final bool isLocked;
  final VoidCallback onChooseA;
  final VoidCallback onChooseB;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
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
                accentColor: const Color(0xFF3DE6C5),
                title: 'Вариант B',
                subtitle: question.optionB_Text,
                icon: Icons.east_rounded,
                isLocked: isLocked,
                onPressed: onChooseB,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _SwipeRadarPreview(scores: scores),
            ),
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
      radius: 24,
      blur: 26,
      color: accentColor.withValues(alpha: 0.09),
      borderColor: accentColor.withValues(alpha: 0.26),
      boxShadow: [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.22),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLocked ? null : onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: accentColor, size: 17),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
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

class _SwipeRadarPreview extends StatelessWidget {
  const _SwipeRadarPreview({required this.scores});

  final Map<String, double> scores;

  @override
  Widget build(BuildContext context) {
    final labels = [
      LiftAxes.communication,
      LiftAxes.creativity,
      LiftAxes.logic,
      LiftAxes.technical,
      LiftAxes.organization,
    ];

    final entries = labels
        .map((axis) => RadarEntry(value: (scores[axis] ?? 0).clamp(0.7, 10.0)))
        .toList();

    return IgnorePointer(
      child: Transform.scale(
        scale: 1.20,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: RadarChart(
            RadarChartData(
              radarShape: RadarShape.polygon,
              tickCount: 4,
              ticksTextStyle: const TextStyle(color: Colors.transparent),
              tickBorderData: BorderSide(
                color: Colors.white.withValues(alpha: 0.05),
              ),
              gridBorderData: BorderSide(
                color: Colors.white.withValues(alpha: 0.06),
              ),
              radarBorderData: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              radarBackgroundColor: Colors.transparent,
              titlePositionPercentageOffset: 0.16,
              titleTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
              getTitle: (index, angle) {
                return RadarChartTitle(
                  text: _radarLabel(labels[index]),
                  angle: angle,
                );
              },
              dataSets: [
                RadarDataSet(
                  dataEntries: entries,
                  fillColor: const Color(0xFF8D6BFF).withValues(alpha: 0.18),
                  borderColor: const Color(0xFF6FAAFF),
                  borderWidth: 2.0,
                  entryRadius: 0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _radarLabel(String axis) {
    switch (axis) {
      case LiftAxes.communication:
        return 'Лидер';
      case LiftAxes.creativity:
        return 'Креатив';
      case LiftAxes.logic:
        return 'Аналитика';
      case LiftAxes.technical:
        return 'Техника';
      case LiftAxes.organization:
        return 'Структура';
    }

    return axis;
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
      radius: 34,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF0E1730).withValues(alpha: 0.92),
          const Color(0xFF0B111E).withValues(alpha: 0.84),
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
                ? 'Аналитика уже рассчитана. Можно сразу открыть полный разбор профиля.'
                : 'Ответы зафиксированы. Финальный расчет почти завершен.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
              height: 1.55,
            ),
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
      color: const Color(0xFF040712).withValues(alpha: 0.88),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: GlassPanel(
            radius: 34,
            blur: 34,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0D1730).withValues(alpha: 0.95),
                const Color(0xFF09111F).withValues(alpha: 0.92),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _PulseIndicator(),
                const SizedBox(height: 22),
                Text(
                  'AI LIFT анализирует твой карьерный профайл...',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(height: 1.35),
                ),
                const SizedBox(height: 12),
                Text(
                  'Сопоставляем поведенческие паттерны, усиливаем архетип и собираем персональный карьерный вектор.',
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

String _compactOptionLabel(String input) {
  const stopWords = {
    'и',
    'или',
    'в',
    'во',
    'на',
    'по',
    'для',
    'с',
    'со',
    'а',
    'но',
    'что',
    'чтобы',
    'сам',
    'сама',
  };

  final cleanedWords = input
      .split(RegExp(r'\s+'))
      .map((word) => word.replaceAll(RegExp(r'[,.!?:"«»()]+'), ''))
      .where((word) => word.isNotEmpty)
      .where((word) => !stopWords.contains(word.toLowerCase()))
      .toList();

  if (cleanedWords.isEmpty) {
    return 'Выбор';
  }

  final first = cleanedWords.first;
  if (first.length <= 12) {
    return _capitalize(first);
  }

  if (cleanedWords.length > 1) {
    return _capitalize(cleanedWords[1]);
  }

  return _capitalize(first.substring(0, 12));
}

IconData _optionIcon(String input) {
  final lower = input.toLowerCase();

  if (lower.contains('код') ||
      lower.contains('python') ||
      lower.contains('автомат') ||
      lower.contains('система')) {
    return Icons.code_rounded;
  }

  if (lower.contains('дизайн') ||
      lower.contains('креатив') ||
      lower.contains('ролик') ||
      lower.contains('контент')) {
    return Icons.palette_outlined;
  }

  if (lower.contains('команд') ||
      lower.contains('люд') ||
      lower.contains('волонтер') ||
      lower.contains('защит') ||
      lower.contains('модер')) {
    return Icons.verified_user_outlined;
  }

  if (lower.contains('тайминг') ||
      lower.contains('логист') ||
      lower.contains('чек-лист') ||
      lower.contains('процесс')) {
    return Icons.account_tree_outlined;
  }

  if (lower.contains('анализ') ||
      lower.contains('данн') ||
      lower.contains('риски') ||
      lower.contains('метрик')) {
    return Icons.analytics_outlined;
  }

  return Icons.auto_awesome_outlined;
}

String _capitalize(String input) {
  if (input.isEmpty) {
    return input;
  }

  return '${input[0].toUpperCase()}${input.substring(1)}';
}
