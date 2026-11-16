import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool hapticsEnabled = true;

  int totalCoins = 0;
  int currentStreak = 0;
  String lastActiveDate = "";
  List<dynamic> leaderboardData = [];
  List<Deck> decks = [];
  List<Flashcard> currentFlashcards = [];
  bool isLoading = false;

  // --- GLOBAL IDENTITY & INVENTORY ---
  String userName = "Code Ninja";
  String userAvatar = "https://api.dicebear.com/7.x/micah/svg?seed=Jasper&backgroundColor=transparent";
  String userTitle = "PRO DEVELOPER";
  String globalUserId = "";

  // ADDED INVENTORY LISTS
  List<String> ownedAvatars = [];
  List<String> ownedTitles = [];

  AppProvider() {
    _initApp();
  }

  Future<void> _initApp() async {
    await _loadLocalProfile();
    loadDecks();
    loadLeaderboard();
  }

  Future<void> _loadLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();

    // 2. GENERATE A UNIQUE USER ID ON FRESH INSTALLS
    globalUserId = prefs.getString('globalUserId') ?? "";
    if (globalUserId.isEmpty) {
      // Creates a unique ID like: USER_1730000000000
      globalUserId = "USER_${DateTime.now().millisecondsSinceEpoch}";
      await prefs.setString('globalUserId', globalUserId);
    }

    userName = prefs.getString('userName') ?? "Code Ninja";
    userAvatar = prefs.getString('userAvatar') ?? "https://api.dicebear.com/7.x/micah/svg?seed=Jasper&backgroundColor=transparent";
    userTitle = prefs.getString('userTitle') ?? "PRO DEVELOPER";
    totalCoins = prefs.getInt('totalCoins') ?? 0;

    ownedAvatars = prefs.getStringList('ownedAvatars') ?? [];
    ownedTitles = prefs.getStringList('ownedTitles') ?? [];

    currentStreak = prefs.getInt('currentStreak') ?? 0;
    lastActiveDate = prefs.getString('lastActiveDate') ?? "";

    // 3. NEW APP CHECK: If totalCoins is 0, give them 40 starter coins so they aren't broke!
    if (totalCoins == 0 && ownedAvatars.isEmpty) {
      totalCoins = 40;
    }

    notifyListeners();
  }
  Future<void> _saveLocalProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
    await prefs.setString('userAvatar', userAvatar);
    await prefs.setString('userTitle', userTitle);
    await prefs.setInt('totalCoins', totalCoins);

    await prefs.setStringList('ownedAvatars', ownedAvatars);
    await prefs.setStringList('ownedTitles', ownedTitles);

    // ---> NEW STREAK SAVE LOGIC
    await prefs.setInt('currentStreak', currentStreak);
    await prefs.setString('lastActiveDate', lastActiveDate);
    await prefs.setBool('hapticsEnabled', hapticsEnabled);
  }

  void _updateDailyStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // Strips out the exact time

    if (lastActiveDate.isEmpty) {
      // Brand new user playing their first game!
      currentStreak = 1;
      lastActiveDate = today.toIso8601String();
    } else {
      final lastActive = DateTime.parse(lastActiveDate);
      final difference = today.difference(lastActive).inDays;

      if (difference == 1) {
        // Exactly one day later, streak continues!
        currentStreak++;
        lastActiveDate = today.toIso8601String();
      } else if (difference > 1) {
        // Missed a day, streak is broken! Reset to 1.
        currentStreak = 1;
        lastActiveDate = today.toIso8601String();
      }
      // If difference == 0, they already played today, so we do nothing.
    }
  }

  void updateProfile(String newName, String newAvatarUrl) {
    userName = newName;
    userAvatar = newAvatarUrl;
    _saveLocalProfile();
    notifyListeners();
  }

  Future<void> loadDecks() async {
    isLoading = true;
    notifyListeners();
    decks = await _apiService.fetchDecks();
    isLoading = false;
    notifyListeners();
  }

  Future<void> loadFlashcards(int deckId) async {
    isLoading = true;
    notifyListeners();
    currentFlashcards = await _apiService.fetchFlashcards(deckId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> addFlashcard(int deckId, String question, String answer) async {
    await _apiService.modifyFlashcard({'action': 'add', 'deckId': deckId, 'question': question, 'answer': answer});
    await loadFlashcards(deckId);
  }

  Future<void> editFlashcard(int cardId, int deckId, String question, String answer) async {
    await _apiService.modifyFlashcard({'action': 'edit', 'id': cardId, 'question': question, 'answer': answer});
    await loadFlashcards(deckId);
  }

  Future<void> deleteFlashcard(int cardId, int deckId) async {
    await _apiService.modifyFlashcard({'action': 'delete', 'id': cardId});
    await loadFlashcards(deckId);
  }

  Future<void> createDeck(String category, String title, String difficulty) async {
    isLoading = true;
    notifyListeners();
    await _apiService.addDeck(category, title, difficulty);
    await loadDecks();
  }

  Future<void> removeDeck(int deckId) async {
    isLoading = true;
    notifyListeners();
    await _apiService.deleteDeck(deckId);
    await loadDecks();
  }

  Future<void> loadLeaderboard() async {
    leaderboardData = await _apiService.fetchLeaderboard();
    final myData = leaderboardData.firstWhere((user) => user['userId'].toString() == globalUserId, orElse: () => {'coins': totalCoins});
    totalCoins = int.tryParse(myData['coins'].toString()) ?? totalCoins;
    _saveLocalProfile();
    notifyListeners();
  }

  Future<void> updateCoins(int earnedCoins) async {
    if (earnedCoins == 0) return;

    try { await _apiService.updateCoins(earnedCoins, globalUserId, userName); } catch (e) { /* Offline */ }
    totalCoins += earnedCoins;

    // ---> ONLY TRIGGER STREAK IF EARNING COINS (Not spending in Vault)
    if (earnedCoins > 0) {
      _updateDailyStreak();
    }

    _saveLocalProfile();
    notifyListeners();
    await loadLeaderboard();
  }

  // FIXED PURCHASE LOGIC TO USE INVENTORY
  Future<bool> purchaseItem(int cost, String type, String value) async {
    bool alreadyOwned = (type == 'avatar' && ownedAvatars.contains(value)) ||
        (type == 'title' && ownedTitles.contains(value));

    // If they already own it, equip it for free
    if (alreadyOwned) {
      if (type == 'avatar') userAvatar = value;
      else if (type == 'title') userTitle = value;
      _saveLocalProfile();
      notifyListeners();
      return true;
    }

    // Normal purchase deduction
    if (totalCoins >= cost) {
      await updateCoins(-cost);

      if (type == 'avatar') {
        userAvatar = value;
        ownedAvatars.add(value); // Add to inventory
      } else if (type == 'title') {
        userTitle = value;
        ownedTitles.add(value); // Add to inventory
      }

      _saveLocalProfile();
      notifyListeners();
      return true;
    }
    return false; // Broke
  }
  void toggleHaptics() {
    hapticsEnabled = !hapticsEnabled;
    _saveLocalProfile();
    notifyListeners();
  }
}