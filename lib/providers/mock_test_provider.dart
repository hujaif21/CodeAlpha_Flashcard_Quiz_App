import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mock_question.dart';

class MockTestProvider extends ChangeNotifier {
  List<MockQuestion> _questions = [];
  bool _isLoading = false;
  int _currentIndex = 0;

  int _timeRemaining = 1800;
  Timer? _timer;

  String _activeUserId = "USER_ID_001";
  String _activeUserName = "Code Ninja";

  final String _scriptUrl = "https://script.google.com/macros/s/AKfycbzUwEextwVCkkFXglqW3eXEomaWfoOqXDpQlIliWl085e01UI6aLpwyOeYAI1rI-QGd/exec";

  List<MockQuestion> get questions => _questions;
  bool get isLoading => _isLoading;
  int get currentIndex => _currentIndex;
  int get timeRemaining => _timeRemaining;
  MockQuestion get currentQuestion => _questions[_currentIndex];

  Future<void> fetchMockData() async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    // 1. INSTANT OFFLINE LOAD: Check local cache first
    final cachedData = prefs.getString('mock_test_cache');
    if (cachedData != null) {
      final List<dynamic> data = json.decode(cachedData);
      _questions = data.map((q) => MockQuestion.fromJson(q)).toList();

      // If we found cached data, stop the loading spinner immediately!
      if (_questions.isNotEmpty) {
        _isLoading = false;
        notifyListeners();
      }
    }

    // 2. BACKGROUND SYNC: Fetch fresh data from Google Sheets
    try {
      // ADDED THE 3 SECOND TIMEOUT HERE!
      final response = await http.get(Uri.parse('$_scriptUrl?action=getMockTest'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        await prefs.setString('mock_test_cache', response.body);
        final List<dynamic> data = json.decode(response.body);
        _questions = data.map((q) => MockQuestion.fromJson(q)).toList();
      }
    } catch (e) {
      debugPrint("App is offline. Using cached Mock Test data.");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ... (keep the rest of your methods like startTest, selectAnswer, etc. exactly the same)
  void startTest(String userId, String userName) {
    _activeUserId = userId;
    _activeUserName = userName;

    _currentIndex = 0;
    _timeRemaining = 1800;

    for (var q in _questions) {
      q.selectedAnswer = null;
      q.isFlagged = false;
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining > 0) {
        _timeRemaining--;
        notifyListeners();
      } else {
        submitTest(_activeUserId, _activeUserName);
      }
    });
    notifyListeners();
  }

  void selectAnswer(String optionIndex) {
    _questions[_currentIndex].selectedAnswer = optionIndex;
    notifyListeners();
  }

  void toggleFlag() {
    _questions[_currentIndex].isFlagged = !_questions[_currentIndex].isFlagged;
    notifyListeners();
  }

  void goToQuestion(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  Map<String, int> calculateFinalScores() {
    int score = 0;
    int correct = 0;
    int wrong = 0;
    int skipped = 0;

    for (var q in _questions) {
      if (q.selectedAnswer == null) {
        skipped++;
      } else {
        if (q.selectedAnswer == q.correctAnswer) {
          score += 4;
          correct++;
        } else {
          score -= 1;
          wrong++;
        }
      }
    }

    return {'score': score, 'correct': correct, 'wrong': wrong, 'skipped': skipped};
  }

  Future<void> submitTest(String userId, String userName) async {
    _timer?.cancel();
    notifyListeners();

    final stats = calculateFinalScores();
    final int earnedCoins = stats['score'] ?? 0;

    if (earnedCoins > 0) {
      try {
        await http.post(
          Uri.parse(_scriptUrl),
          body: json.encode({
            'action': 'updateCoins',
            'userId': userId,
            'userName': userName,
            'coins': earnedCoins
          }),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        debugPrint("Network Error: Could not upload coins.");
      }
    }
  }

  String get formattedTime {
    int minutes = _timeRemaining ~/ 60;
    int seconds = _timeRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}