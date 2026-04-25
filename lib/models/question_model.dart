// ignore_for_file: non_constant_identifier_names

class QuestionModel {
  const QuestionModel({
    required this.id,
    required this.questionText,
    required this.optionA_Text,
    required this.optionB_Text,
    required this.tagA,
    required this.tagB,
  });

  final String id;
  final String questionText;
  final String optionA_Text;
  final String optionB_Text;
  final String tagA;
  final String tagB;
}
