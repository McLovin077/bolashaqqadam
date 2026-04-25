import 'package:flutter/material.dart';

import '../models/question_model.dart';

class QuizProvider extends ChangeNotifier {
  final List<QuestionModel> _questions = const [
    QuestionModel(
      id: 'q1',
      questionText: 'Как тебе комфортнее добиваться результата?',
      optionA_Text: 'Погружаться в детали и искать точное решение',
      optionB_Text: 'Собирать команду и вести всех к цели',
      tagA: 'Аналитика',
      tagB: 'Лидерство',
    ),
    QuestionModel(
      id: 'q2',
      questionText: 'Что тебе интереснее на школьном проекте?',
      optionA_Text: 'Придумать необычную идею и визуал',
      optionB_Text: 'Построить план и довести до дедлайна',
      tagA: 'Креативность',
      tagB: 'Организация',
    ),
    QuestionModel(
      id: 'q3',
      questionText: 'Какой формат задач тебя заряжает сильнее?',
      optionA_Text: 'Разобраться в технологии и быстро собрать прототип',
      optionB_Text: 'Понять людей и сделать полезный сервис для них',
      tagA: 'Технологичность',
      tagB: 'Эмпатия',
    ),
    QuestionModel(
      id: 'q4',
      questionText: 'Когда нужно принять решение, ты чаще...',
      optionA_Text: 'Сравниваешь варианты и выбираешь по аргументам',
      optionB_Text: 'Убеждаешь других и защищаешь свою позицию',
      tagA: 'Стратегия',
      tagB: 'Коммуникация',
    ),
    QuestionModel(
      id: 'q5',
      questionText: 'Что тебе ближе в учебе и внеурочке?',
      optionA_Text: 'Самостоятельно прокачивать навык до высокого уровня',
      optionB_Text: 'Запускать активности, где каждый получает роль',
      tagA: 'Саморазвитие',
      tagB: 'Командность',
    ),
  ];

  final Map<String, int> userTags = {};
  int _currentQuestionIndex = 0;

  List<QuestionModel> get questions => List.unmodifiable(_questions);
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _questions.length;
  bool get isCompleted => _currentQuestionIndex >= _questions.length;

  QuestionModel? get currentQuestion {
    if (isCompleted) {
      return null;
    }

    return _questions[_currentQuestionIndex];
  }

  void answerQuestion(String tag) {
    userTags[tag] = (userTags[tag] ?? 0) + 1;

    if (_currentQuestionIndex < _questions.length) {
      _currentQuestionIndex++;
    }

    notifyListeners();
  }

  List<String> get topTags {
    if (userTags.isEmpty) {
      return [];
    }

    final maxScore = userTags.values.fold<int>(0, (max, score) {
      return score > max ? score : max;
    });

    final result =
        userTags.entries
            .where((entry) => entry.value == maxScore)
            .map((entry) => entry.key)
            .toList()
          ..sort();

    return result;
  }

  void resetQuiz() {
    userTags.clear();
    _currentQuestionIndex = 0;
    notifyListeners();
  }
}
