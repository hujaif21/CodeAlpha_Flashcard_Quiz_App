class Deck {
  final int id;
  final String category;
  final String title;
  final String difficulty;

  Deck({
    required this.id,
    required this.category,
    required this.title,
    required this.difficulty,
  });

  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      // Handles type conversion just in case Google Sheets sends a string instead of a number
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()) ?? 0,
      category: map['category']?.toString() ?? 'All',
      title: map['title']?.toString() ?? 'Untitled Deck',
      difficulty: map['difficulty']?.toString() ?? 'Medium',
    );
  }
}