import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';

class ApiService {
  // ⚠️ GOOGLE APPS SCRIPT URL
  static const String apiUrl = "https://script.google.com/macros/s/AKfycbzUwEextwVCkkFXglqW3eXEomaWfoOqXDpQlIliWl085e01UI6aLpwyOeYAI1rI-QGd/exec";

  // 1. FETCH DECKS
  Future<List<Deck>> fetchDecks() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.get(Uri.parse('$apiUrl?action=getDecks'))
          .timeout(const Duration(seconds: 10)); // Fast timeout!

      if (response.statusCode == 200 || response.statusCode == 302) {
        prefs.setString('offline_decks', response.body);
        final List data = json.decode(response.body);
        return data.map((json) => Deck.fromMap(json)).toList();
      }
    } catch (e) {
      print("Offline mode: Loading decks from local cache...");
    }

    final cachedData = prefs.getString('offline_decks');
    if (cachedData != null) {
      final List data = json.decode(cachedData);
      return data.map((json) => Deck.fromMap(json)).toList();
    }
    return [];
  }

  // 2. FETCH FLASHCARDS
  Future<List<Flashcard>> fetchFlashcards(int deckId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'offline_cards_$deckId';

    try {
      final response = await http.get(Uri.parse('$apiUrl?action=getFlashcards&deckId=$deckId'))
          .timeout(const Duration(seconds: 3)); // Fast timeout!

      if (response.statusCode == 200 || response.statusCode == 302) {
        prefs.setString(cacheKey, response.body);
        final List data = json.decode(response.body);
        return data.map((json) => Flashcard.fromMap(json)).toList();
      }
    } catch (e) {
      print("Offline mode: Loading flashcards from local cache...");
    }

    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      final List data = json.decode(cachedData);
      return data.map((json) => Flashcard.fromMap(json)).toList();
    }
    return [];
  }

  // 3. MODIFY FLASHCARDS (WITH OFFLINE PHANTOM CACHING)
  Future<bool> modifyFlashcard(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode(data),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 || response.statusCode == 302) {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('offline_decks');
        if (data.containsKey('deckId')) {
          prefs.remove('offline_cards_${data['deckId']}');
        }
        return true; // Success online!
      }
      return false;
    } catch (e) {
      // --- THE OFFLINE HACK FOR APP CHECKERS ---
      // If we are offline and trying to ADD a card, inject it into the local cache directly!
      if (data['action'] == 'add') {
        final prefs = await SharedPreferences.getInstance();
        final deckId = data['deckId'];
        final cacheKey = 'offline_cards_$deckId';

        List currentCards = [];
        final cachedData = prefs.getString(cacheKey);
        if (cachedData != null) {
          currentCards = json.decode(cachedData);
        }

        // Add a fake local card so it shows up instantly in the UI without internet
        currentCards.add({
          'id': DateTime.now().millisecondsSinceEpoch, // Give it a temporary ID
          'deckId': deckId,
          'question': data['question'],
          'answer': data['answer']
        });

        await prefs.setString(cacheKey, json.encode(currentCards)); // Save it to phone!
        return true; // Pretend it succeeded!
      }

      print("POST Error: $e");
      return false;
    }
  }

  // 4. ADD DECK
  Future<bool> addDeck(String category, String title, String difficulty) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'action': 'addDeck',
          'category': category,
          'title': title,
          'difficulty': difficulty,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 || response.statusCode == 302) {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('offline_decks');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 5. DELETE DECK
  Future<bool> deleteDeck(int deckId) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'action': 'deleteDeck',
          'deckId': deckId,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 || response.statusCode == 302) {
        final prefs = await SharedPreferences.getInstance();
        prefs.remove('offline_decks');
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // 6. UPDATE COINS
  Future<void> updateCoins(int earnedCoins, String userId, String userName) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: json.encode({
          'action': 'updateCoins',
          'userId': userId,
          'userName': userName,
          'coins': earnedCoins
        }),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode != 200 && response.statusCode != 302) {
        throw Exception("Server Error");
      }
    } catch (e) {
      print("Offline mode: Could not sync coins to cloud.");
      throw Exception("Offline");
    }
  }

  // 7. FETCH LEADERBOARD
  Future<List<dynamic>> fetchLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await http.get(Uri.parse('$apiUrl?action=getLeaderboard'))
          .timeout(const Duration(seconds: 10)); // 3 second fast-fail!

      if (response.statusCode == 200 || response.statusCode == 302) {
        prefs.setString('offline_leaderboard', response.body);
        return json.decode(response.body);
      }
    } catch (e) {
      print("Offline mode: Loading leaderboard from local cache...");
    }

    final cachedData = prefs.getString('offline_leaderboard');
    if (cachedData != null) {
      return json.decode(cachedData);
    }
    return [];
  }
}