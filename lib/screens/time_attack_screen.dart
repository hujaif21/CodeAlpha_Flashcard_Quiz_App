import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_provider.dart';
import 'quiz_result_screen.dart';

class TimeAttackScreen extends StatefulWidget {
  final int deckId;
  final String deckTitle;
  final int questionCount;

  const TimeAttackScreen({
    super.key,
    required this.deckId,
    required this.deckTitle,
    required this.questionCount,
  });

  @override
  State<TimeAttackScreen> createState() => _TimeAttackScreenState();
}

class _TimeAttackScreenState extends State<TimeAttackScreen> {
  int _currentIndex = 0;
  int _timeLeft = 20;
  Timer? _timer;

  // Game Stats
  int _score = 0;
  int _currentStreak = 0;
  int _highestMultiplier = 1;
  int _coinsEarned = 0;

  List<String> _currentOptions = [];
  bool _hasAnswered = false;
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.loadFlashcards(widget.deckId).then((_) {
        _generateOptions();
        _startTimer();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 20;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    _timer?.cancel();
    setState(() {
      _hasAnswered = true;
      _currentStreak = 0;
    });
    Future.delayed(const Duration(seconds: 2), _nextQuestion);
  }

  void _generateOptions() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final cards = provider.currentFlashcards;

    if (cards.isEmpty) return;

    final currentCard = cards[_currentIndex];
    final correctAnswer = currentCard.answer;

    List<String> wrongAnswers = cards
        .where((c) => c.id != currentCard.id)
        .map((c) => c.answer)
        .toList();

    // FALLBACK: Add dummy answers in case the deck has fewer than 4 cards!
    final dummyAnswers = ["None of the above", "All of the above", "Undefined", "Error", "42", "True", "False"];
    wrongAnswers.addAll(dummyAnswers);
    wrongAnswers.shuffle();

    final options = wrongAnswers.take(3).toList();
    options.add(correctAnswer);
    options.shuffle();

    setState(() {
      _currentOptions = options;
      _hasAnswered = false;
      _selectedAnswer = null;
    });
  }

  void _handleAnswer(String selectedOption) {
    if (_hasAnswered) return;

    _timer?.cancel();
    final provider = Provider.of<AppProvider>(context, listen: false);
    final correctAnswer = provider.currentFlashcards[_currentIndex].answer;
    final isCorrect = selectedOption == correctAnswer;

    setState(() {
      _hasAnswered = true;
      _selectedAnswer = selectedOption;

      if (isCorrect) {
        _score++;
        _currentStreak++;

        int multiplier = 1;
        if (_currentStreak >= 5) multiplier = 3;
        else if (_currentStreak >= 3) multiplier = 2;

        if (multiplier > _highestMultiplier) _highestMultiplier = multiplier;

        // FIXED SYNTAX: (2 * multiplier)
        _coinsEarned += (2 * multiplier);

      } else {
        _currentStreak = 0;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), _nextQuestion);
  }

  void _nextQuestion() async {
    final provider = Provider.of<AppProvider>(context, listen: false);

    int maxQuestions = provider.currentFlashcards.length;
    if (widget.questionCount < maxQuestions) {
      maxQuestions = widget.questionCount;
    }

    if (_currentIndex < maxQuestions - 1) {
      setState(() => _currentIndex++);
      _generateOptions();
      _startTimer();
    } else {
      // 🏆 CALCULATE RANK CLIMB
      int getMyRank() {
        int index = provider.leaderboardData.indexWhere((u) => u['userId'].toString() == '1');
        return index >= 0 ? index + 1 : provider.leaderboardData.length + 1; // Fallback if new
      }

      int oldRank = getMyRank();

      // Save to database (this automatically refreshes the leaderboard data)
      if (_coinsEarned > 0) {
        await provider.updateCoins(_coinsEarned);
      }

      int newRank = getMyRank();
      int ranksClimbed = oldRank - newRank;
      if (ranksClimbed < 0) ranksClimbed = 0; // Prevent negative climbing

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            score: _score,
            total: maxQuestions,
            coins: _coinsEarned,
            highestMultiplier: _highestMultiplier,
            newRank: newRank,
            ranksClimbed: ranksClimbed,
          ),
        ),
      );
    }
  }

  int get _currentMultiplier {
    if (_currentStreak >= 5) return 3;
    if (_currentStreak >= 3) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final cards = provider.currentFlashcards;

    if (provider.isLoading || cards.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    final maxQuestions = min(widget.questionCount, cards.length);
    final currentCard = cards[_currentIndex];

    Color timerColor = AppColors.primary;
    if (_timeLeft <= 5) timerColor = AppColors.danger;
    else if (_timeLeft <= 10) timerColor = AppColors.warning;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Time-attack', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                    Row(
                      children: [
                        _buildStatChip(Icons.local_fire_department, '$_currentStreak', AppColors.warning),
                        const SizedBox(width: 8),
                        _buildStatChip(Icons.monetization_on, '$_coinsEarned', AppColors.gold),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 64,
                          width: 64,
                          child: CircularProgressIndicator(
                            value: _timeLeft / 20,
                            backgroundColor: AppColors.surface,
                            color: timerColor,
                            strokeWidth: 6,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('$_timeLeft', style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                            const Text('SEC', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(widget.deckTitle.toUpperCase(), style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _currentMultiplier > 1 ? AppColors.warning.withOpacity(0.5) : AppColors.primary.withOpacity(0.2)),
                            boxShadow: _currentMultiplier > 1 ? [BoxShadow(color: AppColors.warning.withOpacity(0.2), blurRadius: 8)] : null,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_fire_department, color: _currentMultiplier > 1 ? AppColors.warning : AppColors.primaryLight, size: 16),
                              const SizedBox(width: 4),
                              Text('x$_currentMultiplier', style: TextStyle(color: _currentMultiplier > 1 ? AppColors.warning : AppColors.primaryLight, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_currentIndex + 1} /$maxQuestions', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
                    const Text('20 sec per question', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                  ),
                  child: Text(
                    currentCard.question,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800, height: 1.3),
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: ListView.builder(
                    itemCount: _currentOptions.length,
                    itemBuilder: (context, index) {
                      final option = _currentOptions[index];
                      final isCorrect = option == currentCard.answer;
                      final isSelected = option == _selectedAnswer;

                      Color getBorderColor() {
                        if (!_hasAnswered) return AppColors.primary.withOpacity(0.15);
                        if (isCorrect) return AppColors.success;
                        if (isSelected && !isCorrect) return AppColors.danger;
                        return AppColors.primary.withOpacity(0.15);
                      }

                      Color getBgColor() {
                        if (!_hasAnswered) return AppColors.surface;
                        if (isCorrect) return AppColors.success.withOpacity(0.1);
                        if (isSelected && !isCorrect) return AppColors.danger.withOpacity(0.1);
                        return AppColors.surface.withOpacity(0.5);
                      }

                      List<String> letters = ['A', 'B', 'C', 'D'];

                      return GestureDetector(
                        onTap: () => _handleAnswer(option),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: getBgColor(),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: getBorderColor(), width: isSelected || (isCorrect && _hasAnswered) ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Text(letters[index], style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w800)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    color: _hasAnswered && !isCorrect && !isSelected ? AppColors.textMuted : AppColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (_hasAnswered && isCorrect) const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                              if (_hasAnswered && isSelected && !isCorrect) const Icon(Icons.cancel, color: AppColors.danger, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('A correct streak unlocks higher multipliers.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 15),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}