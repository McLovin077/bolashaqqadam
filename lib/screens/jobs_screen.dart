import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../models/mock_data.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_panel.dart';
import '../widgets/match_score_ring.dart';

class JobsScreen extends StatelessWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _JobsHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  physics: const BouncingScrollPhysics(),
                  itemCount: mockJobs.length,
                  itemBuilder: (context, index) {
                    final job = mockJobs[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _JobCard(
                        job: job,
                        onApply: () => _showApplicationBottomSheet(
                          hostContext: context,
                          job: job,
                        ),
                      ),
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
}

class _JobsHeader extends StatelessWidget {
  const _JobsHeader();

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
            const Color(0xFF111D37).withValues(alpha: 0.94),
            const Color(0xFF0A1020).withValues(alpha: 0.82),
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
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF59A8FF).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    LucideIcons.briefcase,
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
                        'Подбор стажировок и проектов на основе AI-профиля.',
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
              'Откликайся через AI-портфолио: мини-интервью, мгновенный Cover Letter и отправка HR в один поток.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.onApply});

  final JobOffer job;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final isPerfectMatch = job.matchPercentage >= 90;

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
          (isPerfectMatch ? const Color(0xFF51E6A9) : const Color(0xFF59A8FF))
              .withValues(alpha: isPerfectMatch ? 0.24 : 0.16),
      boxShadow: [
        BoxShadow(
          color:
              (isPerfectMatch
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
                            job.company,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: Colors.white70),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          LucideIcons.badgeCheck,
                          size: 18,
                          color: Color(0xFF59A8FF),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MatchScoreRing(percentage: job.matchPercentage),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: job.requiredSkills.map((skill) {
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
                  skill,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          if (isPerfectMatch)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF51E6A9).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFF51E6A9).withValues(alpha: 0.22),
                ),
              ),
              child: const Text(
                'Perfect match for your AI-profile',
                style: TextStyle(
                  color: Color(0xFF51E6A9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          if (isPerfectMatch) const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(LucideIcons.rocket),
              label: const Text('Откликнуться AI-портфолио'),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showApplicationBottomSheet({
  required BuildContext hostContext,
  required JobOffer job,
}) {
  final question = mockQuestions[job.id.hashCode.abs() % mockQuestions.length];
  var stage = _ApplicationStage.interview;
  var selectedAnswer = '';
  var generatedLetter = '';

  return showModalBottomSheet<void>(
    context: hostContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (sheetContext) {
      final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
      final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.80;

      return StatefulBuilder(
        builder: (modalContext, setModalState) {
          Future<void> handleAnswer(String answer) async {
            setModalState(() {
              selectedAnswer = answer;
              stage = _ApplicationStage.generating;
            });

            await Future<void>.delayed(const Duration(seconds: 2));

            if (!sheetContext.mounted) {
              return;
            }

            generatedLetter =
                'Мой AI-профиль показывает высокое совпадение. '
                'Я успешно прошел AI-тест на кризис-менеджмент. '
                'Готов к работе на позиции ${job.title} в ${job.company}! '
                'Дополнительно мой ответ "$selectedAnswer" показал, что я умею действовать быстро и сохранять фокус на результате.';

            setModalState(() {
              stage = _ApplicationStage.letterReady;
            });
          }

          void sendToHr() {
            setModalState(() {
              stage = _ApplicationStage.sent;
            });

            ScaffoldMessenger.of(hostContext).showSnackBar(
              const SnackBar(
                content: Text('Отклик и Cover Letter отправлены HR'),
              ),
            );
          }

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
                                  job.title,
                                  style: Theme.of(modalContext)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(fontSize: 22),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${job.company} • ${job.matchPercentage}% match',
                                  style: Theme.of(modalContext)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          child: switch (stage) {
                            _ApplicationStage.interview => _InterviewStep(
                              key: const ValueKey('interview'),
                              question: question,
                              onSelectA: () => handleAnswer(question.optionA),
                              onSelectB: () => handleAnswer(question.optionB),
                            ),
                            _ApplicationStage.generating =>
                              const _GeneratingStep(
                                key: ValueKey('generating'),
                              ),
                            _ApplicationStage.letterReady ||
                            _ApplicationStage.sent => _LetterStep(
                              key: const ValueKey('letter'),
                              letterText: generatedLetter,
                              isSent: stage == _ApplicationStage.sent,
                              onSend: sendToHr,
                            ),
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

class _InterviewStep extends StatelessWidget {
  const _InterviewStep({
    super.key,
    required this.question,
    required this.onSelectA,
    required this.onSelectB,
  });

  final InterviewQuestion question;
  final VoidCallback onSelectA;
  final VoidCallback onSelectB;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
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
                  child: Text(
                    question.questionText,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _InterviewOptionButton(label: question.optionA, onTap: onSelectA),
          const SizedBox(height: 12),
          _InterviewOptionButton(label: question.optionB, onTap: onSelectB),
        ],
      ),
    );
  }
}

class _InterviewOptionButton extends StatelessWidget {
  const _InterviewOptionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        alignment: Alignment.centerLeft,
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.10)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.45),
      ),
    );
  }
}

class _GeneratingStep extends StatelessWidget {
  const _GeneratingStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 52,
              height: 52,
              child: CircularProgressIndicator(strokeWidth: 3.4),
            ),
            const SizedBox(height: 20),
            Text(
              'AI генерирует Cover Letter...',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Анализируем ответ, match score и тональность отклика для HR.',
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

class _LetterStep extends StatelessWidget {
  const _LetterStep({
    super.key,
    required this.letterText,
    required this.isSent,
    required this.onSend,
  });

  final String letterText;
  final bool isSent;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
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
              'AI Cover Letter Ready',
              style: TextStyle(
                color: Color(0xFF66F0D7),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          GlassPanel(
            radius: 24,
            padding: const EdgeInsets.all(18),
            color: Colors.white.withValues(alpha: 0.04),
            child: Text(
              letterText,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white, height: 1.7),
            ),
          ),
          const SizedBox(height: 18),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: isSent
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
                      label: const Text('Успешно'),
                    ),
                  )
                : SizedBox(
                    key: const ValueKey('send'),
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onSend,
                      icon: const Icon(LucideIcons.send),
                      label: const Text('Отправить HR'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

enum _ApplicationStage { interview, generating, letterReady, sent }
