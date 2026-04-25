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
                        _showApplicationFlowSheet(
                          context: context,
                          job: job,
                          match: match,
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

Future<void> _showApplicationFlowSheet({
  required BuildContext context,
  required JobModel job,
  required JobMatchResultModel match,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => _ApplicationFlowSheet(job: job, match: match),
  );
}

enum _InterviewStage { mockInterview, generatingLetter, coverLetter, sent }

class _ApplicationFlowSheet extends StatefulWidget {
  const _ApplicationFlowSheet({required this.job, required this.match});

  final JobModel job;
  final JobMatchResultModel match;

  @override
  State<_ApplicationFlowSheet> createState() => _ApplicationFlowSheetState();
}

class _ApplicationFlowSheetState extends State<_ApplicationFlowSheet> {
  _InterviewStage _stage = _InterviewStage.mockInterview;
  _InterviewOption? _selectedOption;

  String get _coverLetter {
    final archetype = context.read<LiftProvider>().archetype;
    final crisisLine =
        _selectedOption?.coverLetterLine ??
        'умею быстро адаптироваться и держать фокус на результате';

    return 'Здравствуйте! Мой AI-профиль (Архетип: $archetype) показывает '
        '${widget.match.percentage}% совпадения с вашей вакансией. '
        'Я $crisisLine, что подтвердил мини-кейс перед откликом. '
        'Готов(а) быстро подключиться к задачам и усилить вашу команду на позиции '
        '${widget.job.title}.';
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 24, 12, bottomInset + 16),
      child: GlassPanel(
        radius: 34,
        blur: 28,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.job.title,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${widget.job.companyName} • ${widget.match.label}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _buildStageContent(context),
              ),
              if (_stage == _InterviewStage.coverLetter ||
                  _stage == _InterviewStage.sent) ...[
                const SizedBox(height: 18),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _stage == _InterviewStage.sent
                      ? SizedBox(
                          key: const ValueKey('sent'),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF51E6A9),
                              disabledBackgroundColor: const Color(0xFF51E6A9),
                              disabledForegroundColor: const Color(0xFF04111A),
                            ),
                            icon: const Icon(LucideIcons.checkCircle2),
                            label: const Text('HR получил отклик'),
                          ),
                        )
                      : SizedBox(
                          key: const ValueKey('send'),
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _sendToHr,
                            icon: const Icon(LucideIcons.send),
                            label: const Text('Отправить HR'),
                          ),
                        ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStageContent(BuildContext context) {
    switch (_stage) {
      case _InterviewStage.mockInterview:
        return _MockInterviewView(
          key: const ValueKey('mockInterview'),
          title:
              'Привет! Перед откликом на позицию ${widget.job.title} давай проверим смекалку.',
          question: 'Мини-кейс: дедлайн горит, а дизайнер пропал. Что делаешь?',
          onSelected: _handleInterviewOption,
        );
      case _InterviewStage.generatingLetter:
        return const _GeneratingLetterView(key: ValueKey('generatingLetter'));
      case _InterviewStage.coverLetter:
      case _InterviewStage.sent:
        return _CoverLetterView(
          key: const ValueKey('coverLetter'),
          coverLetter: _coverLetter,
          answerLabel: _selectedOption?.label ?? '',
        );
    }
  }

  Future<void> _handleInterviewOption(_InterviewOption option) async {
    setState(() {
      _selectedOption = option;
      _stage = _InterviewStage.generatingLetter;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1600));

    if (!mounted) {
      return;
    }

    setState(() {
      _stage = _InterviewStage.coverLetter;
    });
  }

  void _sendToHr() {
    context.read<LiftProvider>().applyToJob(widget.job.id);

    setState(() {
      _stage = _InterviewStage.sent;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('AI-письмо и профиль отправлены HR в Jasa!'),
      ),
    );
  }
}

class _MockInterviewView extends StatelessWidget {
  const _MockInterviewView({
    super.key,
    required this.title,
    required this.question,
    required this.onSelected,
  });

  final String title;
  final String question;
  final ValueChanged<_InterviewOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF59A8FF).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
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
              child: GlassPanel(
                radius: 24,
                padding: const EdgeInsets.all(16),
                color: Colors.white.withValues(alpha: 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      question,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                        height: 1.55,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._interviewOptions.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              onPressed: () => onSelected(option),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                alignment: Alignment.centerLeft,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                option.label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  height: 1.45,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _GeneratingLetterView extends StatelessWidget {
  const _GeneratingLetterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      key: key,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 46,
              height: 46,
              child: CircularProgressIndicator(strokeWidth: 3.2),
            ),
            const SizedBox(height: 18),
            Text(
              'ИИ генерирует сопроводительное письмо...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Собираем архетип, match score и ответ на кризисный кейс в сильный отклик.',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverLetterView extends StatelessWidget {
  const _CoverLetterView({
    super.key,
    required this.coverLetter,
    required this.answerLabel,
  });

  final String coverLetter;
  final String answerLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _FlowChip(
              icon: LucideIcons.sparkles,
              label: 'AI Cover Letter',
              color: const Color(0xFF34D1BF),
            ),
            if (answerLabel.isNotEmpty)
              _FlowChip(
                icon: LucideIcons.messageSquare,
                label: answerLabel,
                color: const Color(0xFF59A8FF),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GlassPanel(
          radius: 24,
          padding: const EdgeInsets.all(18),
          color: Colors.white.withValues(alpha: 0.04),
          child: _TypewriterText(text: coverLetter),
        ),
      ],
    );
  }
}

class _TypewriterText extends StatelessWidget {
  const _TypewriterText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: text.length),
      duration: Duration(milliseconds: 22 * text.length),
      builder: (context, value, child) {
        final safeValue = value.clamp(0, text.length);

        return Text(
          text.substring(0, safeValue),
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.7),
        );
      },
    );
  }
}

class _FlowChip extends StatelessWidget {
  const _FlowChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
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

class _InterviewOption {
  const _InterviewOption({required this.label, required this.coverLetterLine});

  final String label;
  final String coverLetterLine;
}

const List<_InterviewOption> _interviewOptions = [
  _InterviewOption(
    label: 'Сделаю сам(а) базовый дизайн и быстро соберу рабочий MVP-вариант',
    coverLetterLine:
        'умею брать ответственность на себя и быстро закрывать критические задачи своими руками',
  ),
  _InterviewOption(
    label: 'Найду замену, передоговорюсь по приоритетам и сохраню темп команды',
    coverLetterLine:
        'умею сохранять темп команды, быстро находить решения и договариваться в кризисных ситуациях',
  ),
];
