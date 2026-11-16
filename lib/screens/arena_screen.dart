import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_provider.dart';
import 'quiz_setup_screen.dart';
import 'mock_instruction_screen.dart';
import 'vault_screen.dart';
import 'profile_screen.dart';

class ArenaScreen extends StatefulWidget {
  const ArenaScreen({super.key});

  @override
  State<ArenaScreen> createState() => _ArenaScreenState();
}

class _ArenaScreenState extends State<ArenaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER WITH LIVE COINS
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Arena', style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1.0)),
                              SizedBox(height: 24),
                              Text('Make knowledge count.', style: TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                              SizedBox(height: 6),
                              Text('Challenge yourself. Climb the ranks.', style: TextStyle(color: AppColors.textMuted, fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Consumer<AppProvider>(
                          builder: (context, provider, child) {
                            return Row(
                              mainAxisSize: MainAxisSize.min, // Keeps it compact in your app bar
                              children: [
                                // DYNAMIC STREAK CHIP
                                _buildStatChip(Icons.local_fire_department, '${provider.currentStreak}', AppColors.warning),
                                const SizedBox(width: 8),
                                // DYNAMIC COIN CHIP
                                _buildStatChip(Icons.monetization_on, '${provider.totalCoins}', AppColors.gold),
                              ],
                            );
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),

              // GAME MODES & LIVE LEADERBOARD
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGameModeCard(
                        context: context,
                        tag: 'FAST FOCUS. BIG REWARDS.',
                        title: 'Time-Attack Quiz',
                        subtitle: 'Beat the clock, earn multipliers',
                        icon: Icons.bolt,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QuizSetupScreen())),
                      ),
                      const SizedBox(height: 16),
                      _buildGameModeCard(
                        context: context,
                        tag: 'BUILT FOR THE BIG DAY',
                        title: 'Mock Placement',
                        subtitle: 'Full timed test, negative marking',
                        icon: Icons.work_outline,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MockInstructionScreen()),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text('Weekly Leaderboard', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                          Text('Ends in 3 days', style: TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // LIVE LEADERBOARD DATA
                      Consumer<AppProvider>(
                        builder: (context, provider, child) {
                          if (provider.leaderboardData.isEmpty) {
                            return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator(color: AppColors.primary)));
                          }

                          return Column(
                            children: List.generate(provider.leaderboardData.length, (index) {
                              final user = provider.leaderboardData[index];

                              // FIXED: Now uses provider.globalUserId to perfectly identify "You"
                              final isMe = user['userId'].toString() == provider.globalUserId;

                              return _buildLeaderboardRow(
                                  rank: index + 1,
                                  name: isMe ? 'You' : user['name'],
                                  score: user['coins'].toString(),
                                  isUser: isMe
                              );
                            }),
                          );
                        },
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppColors.cardShadow,
          border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.10))),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: 1, // 1 = Arena
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          onTap: (index) {
            if (index == 1) return; // Already here

            if (index == 0) {
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (index == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VaultScreen()));
            } else if (index == 3) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.style), label: 'Decks'),
            BottomNavigationBarItem(icon: Icon(Icons.flash_on), label: 'Arena'),
            BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Vault'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
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

  Widget _buildGameModeCard({required BuildContext context, required String tag, required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5), boxShadow: AppColors.cardShadow),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tag, style: const TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: AppColors.gold, size: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardRow({required int rank, required String name, required String score, required bool isUser}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: isUser ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text(rank.toString(), style: TextStyle(color: rank == 1 ? AppColors.gold : (isUser ? Colors.white : AppColors.textMuted), fontSize: 16, fontWeight: FontWeight.w800))),
          if (isUser) const Icon(Icons.emoji_events, color: Colors.white, size: 20) else CircleAvatar(radius: 12, backgroundColor: AppColors.primaryLight.withOpacity(0.2), child: Icon(Icons.person, size: 14, color: AppColors.primaryLight)),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: TextStyle(color: isUser ? Colors.white : AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700))),
          Text(score, style: TextStyle(color: isUser ? Colors.white : AppColors.gold, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}