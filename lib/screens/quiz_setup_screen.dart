import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_provider.dart';
import 'time_attack_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int? _selectedDeckId;
  String? _selectedDeckTitle;

  // 🛡️ The Official Whitelist: Only these exact categories are allowed in the Arena
  final List<String> _officialCategories = ['python', 'aptitude', 'interview'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);

      // STRICT FILTER: Only allow decks that match the official categories
      final arenaDecks = provider.decks.where((d) =>
          _officialCategories.contains(d.category.toLowerCase())
      ).toList();

      if (arenaDecks.isNotEmpty) {
        setState(() {
          _selectedDeckId = arenaDecks.first.id;
          _selectedDeckTitle = arenaDecks.first.title;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.15))),
                    child: const Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 20),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Find your fast lane.', style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1.0)),
                const SizedBox(height: 8),
                const Text('20 seconds. One question at a time.', style: TextStyle(color: AppColors.textMuted, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 32),

                const Text('SELECT TOURNAMENT DECK', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                  child: Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      // STRICT FILTER: Apply the same whitelist to the dropdown UI
                      final arenaDecks = provider.decks.where((d) =>
                          _officialCategories.contains(d.category.toLowerCase())
                      ).toList();

                      if (arenaDecks.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 12.0), child: Text('No tournament decks available', style: TextStyle(color: AppColors.textMuted)));

                      return DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _selectedDeckId,
                          isExpanded: true,
                          dropdownColor: AppColors.surface,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textMuted),
                          items: arenaDecks.map((deck) {
                            return DropdownMenuItem<int>(
                              value: deck.id,
                              child: Text(deck.title.replaceAll('_', ' '), style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedDeckId = newValue;
                              _selectedDeckTitle = arenaDecks.firstWhere((d) => d.id == newValue).title;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withOpacity(0.1))),
                  child: Row(
                    children: const [
                      Icon(Icons.bolt, color: AppColors.gold),
                      SizedBox(width: 12),
                      Expanded(child: Text('Build a correct streak to unlock up to x3 coins. Wrong answers reset your multiplier.', style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600))),
                    ],
                  ),
                ),
                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _selectedDeckId == null ? null : () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TimeAttackScreen(
                            deckId: _selectedDeckId!,
                            deckTitle: _selectedDeckTitle ?? 'Deck',
                            questionCount: 999,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, disabledBackgroundColor: AppColors.surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                    child: Text(_selectedDeckId == null ? 'No Deck Selected' : 'Start Tournament', style: TextStyle(color: _selectedDeckId == null ? AppColors.textMuted : Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}