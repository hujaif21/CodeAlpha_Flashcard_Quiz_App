import 'package:brainbounty/providers/app_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mock_test_provider.dart';
import 'mock_report_screen.dart';
import '../theme/app_colors.dart';

class MockTestScreen extends StatefulWidget {
  const MockTestScreen({super.key});

  @override
  State<MockTestScreen> createState() => _MockTestScreenState();
}

class _MockTestScreenState extends State<MockTestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<MockTestProvider>(context, listen: false);
      final appData = Provider.of<AppProvider>(context, listen: false);

      if (provider.questions.isEmpty) {
        provider.fetchMockData().then((_) => provider.startTest(appData.globalUserId, appData.userName));
      } else {
        provider.startTest(appData.globalUserId, appData.userName);
      }
    });
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Exit Test?', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: const Text('Your progress will be lost. Are you sure?', style: TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () {
              // 1. Grab global profile data for early exit
              final appData = Provider.of<AppProvider>(context, listen: false);

              // 2. Submit test with real ID and Name
              Provider.of<MockTestProvider>(context, listen: false).submitTest(appData.globalUserId, appData.userName);

              // 3. Refresh leaderboard
              appData.loadLeaderboard();

              Navigator.of(context).pop(true);
            },
            child: const Text('Exit', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: SafeArea(
            child: Consumer<MockTestProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (provider.questions.isEmpty) {
                  return const Center(child: Text("No questions found.", style: TextStyle(color: AppColors.textPrimary)));
                }

                final currentQ = provider.currentQuestion;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TIMER BAR
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppColors.cardShadow,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("TIME REMAINING", style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                                Text(provider.formattedTime, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: provider.timeRemaining / 1800,
                              backgroundColor: AppColors.backgroundAlt,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // QUESTION PALETTE
                      const Text("Question palette", style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 120,
                        child: GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 10,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: provider.questions.length,
                          itemBuilder: (context, index) {
                            final q = provider.questions[index];
                            Color boxColor = AppColors.surface;
                            Color boxTextColor = AppColors.textPrimary;

                            if (index == provider.currentIndex) {
                              boxColor = AppColors.gold;
                              boxTextColor = Colors.white;
                            } else if (q.isFlagged) {
                              boxColor = AppColors.primary;
                              boxTextColor = Colors.white;
                            } else if (q.selectedAnswer != null) {
                              if (q.selectedAnswer == q.correctAnswer) {
                                boxColor = AppColors.success;
                              } else {
                                boxColor = AppColors.danger;
                              }
                              boxTextColor = Colors.white;
                            }

                            return GestureDetector(
                              onTap: () => provider.goToQuestion(index),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: boxColor,
                                  borderRadius: BorderRadius.circular(6),
                                  boxShadow: boxColor == AppColors.surface ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null,
                                ),
                                alignment: Alignment.center,
                                child: Text('${index + 1}', style: TextStyle(color: boxTextColor, fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // QUESTION TEXT
                      Text("${currentQ.section.toUpperCase()} · ${provider.currentIndex + 1} / ${provider.questions.length}",
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(currentQ.question, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // OPTIONS
                      Expanded(
                        child: ListView.builder(
                          itemCount: currentQ.options.length,
                          itemBuilder: (context, index) {
                            String optionLetter = String.fromCharCode(65 + index);
                            bool isSelected = currentQ.selectedAnswer == optionLetter;

                            Color bgColor = AppColors.surface;
                            Color borderColor = Colors.transparent;
                            Color textColor = AppColors.textPrimary;

                            if (currentQ.selectedAnswer != null) {
                              if (optionLetter == currentQ.correctAnswer) {
                                bgColor = AppColors.success.withOpacity(0.15);
                                borderColor = AppColors.success;
                                textColor = AppColors.textPrimary;
                              } else if (isSelected) {
                                bgColor = AppColors.danger.withOpacity(0.15);
                                borderColor = AppColors.danger;
                                textColor = AppColors.textPrimary;
                              }
                            }

                            return GestureDetector(
                              onTap: () {
                                if (currentQ.selectedAnswer == null) {
                                  provider.selectAnswer(optionLetter);
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  border: Border.all(color: borderColor, width: 2),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: AppColors.cardShadow,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.backgroundAlt,
                                      child: Text(optionLetter, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(child: Text(currentQ.options[index], style: TextStyle(color: textColor, fontWeight: FontWeight.w600))),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // RESPONSIVE BOTTOM BUTTONS
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.zero,
                                backgroundColor: AppColors.surface,
                              ),
                              onPressed: provider.toggleFlag,
                              child: const Text("Review", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.zero,
                                backgroundColor: AppColors.surface,
                              ),
                              onPressed: () => provider.selectAnswer(''),
                              child: const Text("Clear", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.waveGradient,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  // ADDED MISSING MINUS SIGN HERE
                                  if (provider.currentIndex < provider.questions.length - 1) {
                                    provider.nextQuestion();
                                  } else {
                                    final appData = Provider.of<AppProvider>(context, listen: false);
                                    provider.submitTest(appData.globalUserId, appData.userName);
                                    appData.loadLeaderboard();
                                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MockReportScreen()));
                                  }
                                },
                                // ADDED MISSING MINUS SIGN HERE
                                child: Text(provider.currentIndex < provider.questions.length - 1 ? "Next" : "Submit", style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}