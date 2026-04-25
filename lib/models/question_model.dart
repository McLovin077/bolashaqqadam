// ignore_for_file: non_constant_identifier_names

enum QuestionChoice { optionA, optionB }

class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.questionText,
    required this.optionA_Text,
    required this.optionB_Text,
    required this.tagA,
    required this.tagB,
    this.axisScoresA = const {},
    this.axisScoresB = const {},
  });

  final String id;
  final String questionText;
  final String optionA_Text;
  final String optionB_Text;
  final String tagA;
  final String tagB;
  final Map<String, double> axisScoresA;
  final Map<String, double> axisScoresB;

  String tagFor(QuestionChoice choice) {
    return choice == QuestionChoice.optionA ? tagA : tagB;
  }

  String textFor(QuestionChoice choice) {
    return choice == QuestionChoice.optionA ? optionA_Text : optionB_Text;
  }

  Map<String, double> axisScoresFor(QuestionChoice choice) {
    return choice == QuestionChoice.optionA ? axisScoresA : axisScoresB;
  }
}
