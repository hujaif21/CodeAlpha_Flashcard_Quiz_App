import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_provider.dart';

class StudyScreen extends StatefulWidget {
  final int deckId;
  final String deckTitle;

  const StudyScreen({
    super.key,
    required this.deckId,
    required this.deckTitle,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  bool _showAnswer = false;
  int _currentIndex = 0;
  bool _isClaiming = false; // Added to prevent double-tapping the claim button

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadFlashcards(widget.deckId);
    });
  }

  void _nextCard(int totalCards) {
    if (_currentIndex < totalCards) {
      setState(() {
        _currentIndex++;
        _showAnswer = false;
      });
    }
  }

  void _prevCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showAnswer = false;
      });
    }
  }

  // BOUNTY CLAIM LOGIC
  void _claimBounty() async {
    if (_isClaiming) return;
    setState(() => _isClaiming = true);

    final provider = Provider.of<AppProvider>(context, listen: false);

    // Add 20 coins to the global user ID
    await provider.updateCoins(20);

    // Return to the Decks page
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context, String deckTitle) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
            ),
            const SizedBox(width: 12),
            const Text('Delete this flashcard?', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'This card will be permanently deleted from $deckTitle. This can’t be undone.',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showAddEditModal({int? cardId, String? currentQuestion, String? currentAnswer}) {
    final isEditing = cardId != null;
    final questionCtrl = TextEditingController(text: currentQuestion);
    final answerCtrl = TextEditingController(text: currentAnswer);
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEditing ? 'Edit flashcard' : 'Add flashcard',
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEditing ? 'Make a good question even better.' : 'One question. A new possibility.',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    const Text('Question', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: questionCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'What do you want to remember?',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Answer', style: TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: answerCtrl,
                      maxLines: 4,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        hintText: 'Write a clear, memorable answer...',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isSubmitting ? null : () async {
                                setModalState(() => isSubmitting = true);
                                final provider = Provider.of<AppProvider>(context, listen: false);
                                if (isEditing) {
                                  await provider.editFlashcard(cardId!, widget.deckId, questionCtrl.text, answerCtrl.text);
                                } else {
                                  await provider.addFlashcard(widget.deckId, questionCtrl.text, answerCtrl.text);
                                }
                                if (context.mounted) Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SizedBox(
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.surface,
                                side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              child: const Text('Cancel', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Consumer<AppProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              final cards = provider.currentFlashcards;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TOP BAR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppColors.cardShadow,
                              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 18),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppColors.waveGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddEditModal(),
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            label: const Text('Add Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Text(
                      widget.deckTitle.replaceAll('_', ' '),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (cards.isEmpty)
                      Expanded(child: _buildEmptyDeckState())
                    else if (_currentIndex >= cards.length)
                      Expanded(child: _buildSessionCompleteView()) // Replaced with premium view
                    else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'STUDY SESSION',
                              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                            ),
                            Text(
                              '${_currentIndex + 1} / ${cards.length}',
                              style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_currentIndex + 1) / cards.length,
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            color: AppColors.primary,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 32),

                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 600),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);
                              return AnimatedBuilder(
                                animation: rotateAnim,
                                child: child,
                                builder: (context, widget) {
                                  final isUnder = (ValueKey(_showAnswer) != widget!.key);
                                  final value = isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;

                                  return Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(value),
                                    alignment: Alignment.center,
                                    child: widget,
                                  );
                                },
                              );
                            },
                            child: _showAnswer
                                ? _buildAnswerCard(cards[_currentIndex].answer, cards[_currentIndex].id)
                                : _buildQuestionCard(cards[_currentIndex].question, cards[_currentIndex].id, cards[_currentIndex].answer),
                          ),
                        ),
                        const SizedBox(height: 32),

                        Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: AppColors.cardShadow,
                          ),
                          child: ElevatedButton(
                            onPressed: () => setState(() => _showAnswer = !_showAnswer),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              _showAnswer ? 'Hide Answer' : 'Show Answer',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: OutlinedButton(
                                  onPressed: _currentIndex > 0 ? _prevCard : null,
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.surface,
                                    side: BorderSide(color: AppColors.primary.withOpacity(0.15)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: Text(
                                    'Previous',
                                    style: TextStyle(
                                      color: _currentIndex > 0 ? AppColors.textPrimary : AppColors.textMuted.withOpacity(0.4),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  color: _currentIndex < cards.length ? AppColors.surface : AppColors.surface.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                                ),
                                child: ElevatedButton(
                                  onPressed: () => _nextCard(cards.length),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: const Text(
                                    'Next',
                                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyDeckState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('A fresh start.', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Your next big idea belongs here.', style: TextStyle(color: AppColors.textMuted, fontSize: 15, fontWeight: FontWeight.w600)),
        const Spacer(),
        Center(
          child: Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.backgroundAlt, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: AppColors.primary, size: 40),
              ),
            ),
          ),
        ),
        const Spacer(),
        const Text('No cards yet', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Start with one question.\nBuild a deck worth coming back to.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _showAddEditModal(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: const Text('Add your first card', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          ),
        ),
      ],
    );
  }

  // REPLACED WITH PREMIUM FUNCTIONAL CLAIM UI
  Widget _buildSessionCompleteView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(),

        // GLOWING BOUNTY BADGE
        Container(
          height: 140,
          width: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.goldGradient,
            boxShadow: [
              BoxShadow(color: AppColors.gold.withOpacity(0.5), blurRadius: 40, spreadRadius: 10),
              BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
            ],
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: const Icon(Icons.monetization_on, color: Colors.white, size: 80),
        ),
        const SizedBox(height: 32),

        // CELEBRATION TEXT
        const Text(
          'DECK CONQUERED',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Knowledge Secured.',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),

        // COIN AMOUNT
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 2),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('+', style: TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.w900)),
              const Text(
                '20 BOUNTY',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),

        const Spacer(),

        // CLAIM BUTTON
        GestureDetector(
          onTap: _claimBounty,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.waveGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: _isClaiming
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : const Text(
                'Claim Bounty',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(String text, int cardId, String answer) {
    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('QUICK QUESTION', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.primary, size: 22),
                onPressed: () => _showAddEditModal(cardId: cardId, currentQuestion: text, currentAnswer: answer),
              ),
            ],
          ),
          const Spacer(),
          Text(text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800, height: 1.3, letterSpacing: -0.5)),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildAnswerCard(String text, int cardId) {
    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppColors.waveGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: const Color(0xFF5B21B6), width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ANSWER', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                onPressed: () async {
                  final confirm = await _showDeleteConfirmation(context, widget.deckTitle);
                  if (confirm == true) {
                    await Provider.of<AppProvider>(context, listen: false).deleteFlashcard(cardId, widget.deckId);
                    if (context.mounted) {
                      // FIXED THE SYNTAX ERROR HERE (Added the minus sign)
                      setState(() { _currentIndex = max(0, _currentIndex - 1); _showAnswer = false; });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Card Deleted!')));
                    }
                  }
                },
              ),
            ],
          ),
          const Spacer(),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold, height: 1.4)),
          const Spacer(),
        ],
      ),
    );
  }
}