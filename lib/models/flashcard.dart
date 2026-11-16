class Flashcard {
  final int id;
  final int deckId;
  final String question;
  final String answer;

  Flashcard({
    required this.id,
    required this.deckId,
    required this.question,
    required this.answer,
  });

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      deckId: map['deckId'] is int ? map['deckId'] : int.tryParse(map['deckId'].toString()) ?? 0,
      question: map['question']?.toString() ?? '',
      answer: map['answer']?.toString() ?? '',
    );
  }
}