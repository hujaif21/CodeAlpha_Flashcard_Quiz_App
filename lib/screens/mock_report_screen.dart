import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mock_test_provider.dart';
import '../theme/app_colors.dart';
import 'arena_screen.dart';

class MockReportScreen extends StatelessWidget {
  const MockReportScreen({super.key});


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MockTestProvider>(context, listen: false);
    final stats = provider.calculateFinalScores();

    final int score = stats['score'] ?? 0;
    final int correct = stats['correct'] ?? 0;
    final int wrong = stats['wrong'] ?? 0;
    final int skipped = stats['skipped'] ?? 0;
    final int totalQuestions = correct + wrong + skipped;
    final double accuracy = totalQuestions > 0 ? (correct / (correct + wrong)) * 100 : 0;
    final int earnedCoins = score > 0 ? score : 0; // Prevent negative coins

    int quantCorrect = 0, logicalCorrect = 0, verbalCorrect = 0;
    for (var q in provider.questions) {
      if (q.selectedAnswer == q.correctAnswer) {
        if (q.section.toLowerCase() == 'quantitative') quantCorrect++;
        if (q.section.toLowerCase() == 'logical') logicalCorrect++;
        if (q.section.toLowerCase() == 'verbal') verbalCorrect++;
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Placement report', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("A clearer path forward.", style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text("Graduate aptitude · Test 01", style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
                const SizedBox(height: 24),

                // MAIN SCORE CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn("$score / 120", "Score"),
                      _buildStatColumn("+$earnedCoins", "Coins Earned", AppColors.gold), // Now shows actual coins!
                      _buildStatColumn("${accuracy.toInt()}%", "Accuracy"),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // SECTION-WISE SCORE CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Section-wise score", style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _buildSectionBar("Quantitative", quantCorrect, 10),
                      const SizedBox(height: 16),
                      _buildSectionBar("Logical", logicalCorrect, 10),
                      const SizedBox(height: 16),
                      _buildSectionBar("Verbal", verbalCorrect, 10),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // BREAKDOWN BOX
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatColumn("$correct", "Correct", AppColors.success),
                      _buildStatColumn("$wrong", "Wrong", AppColors.danger),
                      _buildStatColumn("$skipped", "Skipped", AppColors.primary),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // BACK TO ARENA BUTTON
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.waveGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const ArenaScreen()),
                            (route) => route.isFirst, // Keeps your Home/Decks screen safely at the bottom
                      );
                    },
                    child: const Text("Back to Arena", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20), // Bottom padding
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, [Color? valueColor]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(value, style: TextStyle(color: valueColor ?? AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSectionBar(String title, int score, int maxScore) {
    double progress = maxScore > 0 ? score / maxScore : 0;
    int totalMarks = score * 4;

    return Row(
      children: [
        SizedBox(width: 90, child: Text(title, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600))),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(color: AppColors.backgroundAlt, borderRadius: BorderRadius.circular(4)),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(width: 30, child: Text("$totalMarks", style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.right)),
      ],
    );
  }
}