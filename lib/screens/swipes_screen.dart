import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/question_model.dart';
import '../providers/quiz_provider.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  bool _isResultDialogVisible = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, quizProvider, child) {
        if (quizProvider.isCompleted && !_isResultDialogVisible) {
          _isResultDialogVisible = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showResultDialog(quizProvider);
          });
        }

        final question = quizProvider.currentQuestion;

        return Scaffold(
          appBar: AppBar(title: const Text('Свайпы')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Выбери, что тебе ближе',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    quizProvider.isCompleted
                        ? 'Все вопросы завершены'
                        : 'Вопрос ${quizProvider.currentQuestionIndex + 1} из ${quizProvider.totalQuestions}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: quizProvider.totalQuestions == 0
                          ? 0
                          : quizProvider.currentQuestionIndex /
                                quizProvider.totalQuestions,
                      backgroundColor: Colors.white12,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: question == null
                          ? const SizedBox.expand(
                              key: ValueKey('completed'),
                              child: _CompletedState(),
                            )
                          : SizedBox.expand(
                              key: ValueKey(question.id),
                              child: Dismissible(
                                key: ValueKey(question.id),
                                direction: DismissDirection.horizontal,
                                onDismissed: (direction) {
                                  _handleSwipe(
                                    direction,
                                    question,
                                    quizProvider,
                                  );
                                },
                                background: _SwipeBackground(
                                  color: Colors.greenAccent.withValues(
                                    alpha: 0.18,
                                  ),
                                  alignment: Alignment.centerLeft,
                                  icon: Icons.arrow_forward_rounded,
                                  label: 'Вариант Б',
                                ),
                                secondaryBackground: _SwipeBackground(
                                  color: Colors.deepOrangeAccent.withValues(
                                    alpha: 0.18,
                                  ),
                                  alignment: Alignment.centerRight,
                                  icon: Icons.arrow_back_rounded,
                                  label: 'Вариант А',
                                ),
                                child: _QuestionCard(
                                  question: question,
                                  questionNumber:
                                      quizProvider.currentQuestionIndex + 1,
                                  totalQuestions: quizProvider.totalQuestions,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (question != null)
                    Row(
                      children: [
                        Expanded(
                          child: _OptionButton(
                            label: 'Вариант А',
                            description: question.optionA_Text,
                            icon: Icons.arrow_back_rounded,
                            color: const Color(0xFFEF5350),
                            onPressed: () {
                              quizProvider.answerQuestion(question.tagA);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _OptionButton(
                            label: 'Вариант Б',
                            description: question.optionB_Text,
                            icon: Icons.arrow_forward_rounded,
                            color: const Color(0xFF26A69A),
                            onPressed: () {
                              quizProvider.answerQuestion(question.tagB);
                            },
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleSwipe(
    DismissDirection direction,
    QuestionModel question,
    QuizProvider quizProvider,
  ) {
    if (direction == DismissDirection.startToEnd) {
      quizProvider.answerQuestion(question.tagB);
      return;
    }

    quizProvider.answerQuestion(question.tagA);
  }

  Future<void> _showResultDialog(QuizProvider quizProvider) async {
    final topSkills = quizProvider.topTags.isEmpty
        ? 'пока не определены'
        : quizProvider.topTags.join(', ');

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: const Color(0xFF131A2A),
            title: const Text('Результат'),
            content: Text(
              'Ваши топ-навыки: $topSkills',
              style: const TextStyle(height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.read<QuizProvider>().resetQuiz();
                  setState(() {
                    _isResultDialogVisible = false;
                  });
                },
                child: const Text('Пройти заново'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
  });

  final QuestionModel question;
  final int questionNumber;
  final int totalQuestions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF182235), Color(0xFF111827)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C2A8).withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
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
          Text(
            question.questionText,
            style: theme.textTheme.headlineMedium?.copyWith(height: 1.2),
          ),
          const SizedBox(height: 24),
          _OptionPreview(
            label: 'Вариант А',
            text: question.optionA_Text,
            icon: Icons.arrow_back_rounded,
            alignment: CrossAxisAlignment.start,
          ),
          const SizedBox(height: 14),
          _OptionPreview(
            label: 'Вариант Б',
            text: question.optionB_Text,
            icon: Icons.arrow_forward_rounded,
            alignment: CrossAxisAlignment.end,
            textAlign: TextAlign.right,
          ),
          const Spacer(),
          Text(
            'Свайп влево для варианта А, вправо для варианта Б',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _OptionPreview extends StatelessWidget {
  const _OptionPreview({
    required this.label,
    required this.text,
    required this.icon,
    required this.alignment,
    this.textAlign = TextAlign.left,
  });

  final String label;
  final String text;
  final IconData icon;
  final CrossAxisAlignment alignment;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.arrow_back_rounded) ...[
              Icon(icon, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (icon == Icons.arrow_forward_rounded) ...[
              const SizedBox(width: 6),
              Icon(icon, size: 18, color: Colors.white70),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          text,
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
        ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.14),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: color.withValues(alpha: 0.35)),
          ),
        ),
        onPressed: onPressed,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.color,
    required this.alignment,
    required this.icon,
    required this.label,
  });

  final Color color;
  final Alignment alignment;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedState extends StatelessWidget {
  const _CompletedState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF131A2A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: const Center(
        child: Text(
          'Подводим результаты...',
          style: TextStyle(fontSize: 18, color: Colors.white70),
        ),
      ),
    );
  }
}
