import 'package:flutter/material.dart';
import 'mock_test_screen.dart';
import '../theme/app_colors.dart';

class MockInstructionScreen extends StatelessWidget {
  const MockInstructionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mock placement', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          Chip(
            backgroundColor: AppColors.surface,
            side: BorderSide.none,
            label: const Text('🔥 7', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Chip(
            backgroundColor: AppColors.surface,
            side: BorderSide.none,
            label: const Text('🪙 1,250', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        height: double.infinity, // Ensures your gradient fills the entire background
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          // 1. ADDED SingleChildScrollView to fix the 27-pixel overflow
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your next opportunity starts with practice.",
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Graduate aptitude · Practice test 01",
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // STATS BOX (Floating 3D Card)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatWidget(value: "30 min", label: "Duration"),
                        _StatWidget(value: "30", label: "Questions"),
                        _StatWidget(value: "3", label: "Sections"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // MARKING SCHEME BOX
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("MARKING SCHEME", style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(children: const [Text("+4", style: TextStyle(color: AppColors.success, fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(width: 8), Text("Correct", style: TextStyle(color: AppColors.textPrimary))]),
                            Row(children: const [Text("-1", style: TextStyle(color: AppColors.danger, fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(width: 8), Text("Wrong", style: TextStyle(color: AppColors.textPrimary))]),
                            Row(children: const [Text("0", style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)), SizedBox(width: 8), Text("Skipped", style: TextStyle(color: AppColors.textPrimary))]),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // CHECKLIST
                  const Text("Before you begin", style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const _ChecklistItem(text: "The timer continues until you submit."),
                  const _ChecklistItem(text: "Flag questions and come back to them."),
                  const _ChecklistItem(text: "Unanswered questions earn zero marks."),
                  const _ChecklistItem(text: "Submit once. Your answers are final."),

                  // 2. REPLACED Spacer() with SizedBox to prevent ScrollView crashes
                  const SizedBox(height: 32),

                  // BUTTONS
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
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MockTestScreen()));
                      },
                      child: const Text("Begin Test", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back to Arena", style: TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20), // Extra padding at the very bottom
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatWidget extends StatelessWidget {
  final String value;
  final String label;
  const _StatWidget({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
      ],
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;
  const _ChecklistItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14))),
        ],
      ),
    );
  }
}