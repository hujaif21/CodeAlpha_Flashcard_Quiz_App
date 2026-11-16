class MockQuestion {
  final String id;
  final String section;
  final String question;
  final List<String> options;
  final String correctAnswer;

  // State tracking for the UI palette and scoring
  String? selectedAnswer;
  bool isFlagged;

  MockQuestion({
    required this.id,
    required this.section,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.selectedAnswer,
    this.isFlagged = false,
  });

  factory MockQuestion.fromJson(Map<String, dynamic> json) {
    return MockQuestion(
      id: json['QuestionID']?.toString() ?? '',
      section: json['Section']?.toString() ?? '',
      question: json['Question']?.toString() ?? '',
      options: [
        json['OptionA']?.toString() ?? '',
        json['OptionB']?.toString() ?? '',
        json['OptionC']?.toString() ?? '',
        json['OptionD']?.toString() ?? '',
      ],
      correctAnswer: json['CorrectAnswer']?.toString() ?? '',
    );
  }
}