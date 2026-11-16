import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_colors.dart';
import '../providers/app_provider.dart';
import 'arena_screen.dart';
import 'vault_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              // HEADER WITH DYNAMIC NAME, AVATAR, AND EDIT BUTTON
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    return Row(
                      children: [
                        // GAMIFIED AVATAR
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.primary, width: 2),
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 12, spreadRadius: 2)],
                          ),
                          child: ClipOval(
                            child: SvgPicture.network(
                              provider.userAvatar,
                              fit: BoxFit.cover,
                              placeholderBuilder: (context) => const CircularProgressIndicator(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // DYNAMIC NAME & RANK TITLE
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(provider.userName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                child: Text(provider.userTitle.toUpperCase(), style: const TextStyle(color: AppColors.primaryLight, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                              ),
                            ],
                          ),
                        ),

                        // EDIT PROFILE BUTTON
                        GestureDetector(
                          onTap: () {
                            if (provider.hapticsEnabled) HapticFeedback.lightImpact();
                            _showEditProfileModal(context, provider);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.2))),
                            child: const Icon(Icons.edit, color: AppColors.primaryLight, size: 20),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // LIVE STATS DASHBOARD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    int myRank = provider.leaderboardData.indexWhere((u) => u['userId'].toString() == provider.globalUserId);
                    myRank = myRank >= 0 ? myRank + 1 : provider.leaderboardData.length + 1;

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatColumn('Rank', '#$myRank', AppColors.primaryLight),
                          Container(height: 40, width: 1, color: AppColors.primary.withOpacity(0.2)),
                          _buildStatColumn('Coins', '${provider.totalCoins}', AppColors.gold),
                          Container(height: 40, width: 1, color: AppColors.primary.withOpacity(0.2)),
                          _buildStatColumn('Decks', '${provider.decks.length}', AppColors.success),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text('APP CONTROLS', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
              ),
              const SizedBox(height: 12),

              // UPGRADED GEN-Z SETTINGS LIST
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        children: [
                          // Sync Action
                          _buildSettingsTile(
                            icon: Icons.sync,
                            title: 'Force Sync Database',
                            subtitle: 'Pull latest questions and ranks',
                            iconColor: AppColors.primary,
                            onTap: () async {
                              if (provider.hapticsEnabled) HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing with Google Sheets...')));
                              await provider.loadDecks();
                              await provider.loadLeaderboard();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sync Complete!')));
                              }
                            },
                          ),

                          // FULLY FUNCTIONAL SHARE BUTTON
                          _buildSettingsTile(
                              icon: Icons.ios_share_rounded,
                              title: 'Flex Your Stats',
                              subtitle: 'Share your rank with friends',
                              iconColor: AppColors.success,
                              onTap: () {
                                if (provider.hapticsEnabled) HapticFeedback.heavyImpact();

                                int myRank = provider.leaderboardData.indexWhere((u) => u['userId'].toString() == provider.globalUserId);
                                myRank = myRank >= 0 ? myRank + 1 : provider.leaderboardData.length + 1;

                                final String shareText = "I just hit Rank #$myRank with ${provider.totalCoins} Bounty Coins on BrainBounty! 🧠🔥 Can you beat my score?";
                                Share.share(shareText);
                              }
                          ),

                          // FULLY FUNCTIONAL HAPTICS TOGGLE
                          _buildSettingsTile(
                              icon: Icons.vibration_rounded,
                              title: 'Game Feel',
                              subtitle: provider.hapticsEnabled ? 'Crisp haptics are ON' : 'Haptics are OFF',
                              iconColor: provider.hapticsEnabled ? AppColors.primaryLight : AppColors.textMuted,
                              onTap: () {
                                provider.toggleHaptics();
                                if (provider.hapticsEnabled) HapticFeedback.heavyImpact();
                              }
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION BAR
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
          currentIndex: 3, // 3 = Profile
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          onTap: (index) {
            final provider = Provider.of<AppProvider>(context, listen: false);
            if (provider.hapticsEnabled) HapticFeedback.lightImpact();

            if (index == 3) return; // Already here

            if (index == 0) {
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (index == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ArenaScreen()));
            } else if (index == 2) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VaultScreen()));
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

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: valueColor, fontSize: 24, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildSettingsTile({required IconData icon, required String title, required String subtitle, required Color iconColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withOpacity(0.1))),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: iconColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  void _showEditProfileModal(BuildContext context, AppProvider provider) {
    final nameCtrl = TextEditingController(text: provider.userName);
    String selectedAvatarUrl = provider.userAvatar;

    final List<String> avatars = [
      'https://api.dicebear.com/7.x/micah/svg?seed=Jasper&backgroundColor=transparent',
      'https://api.dicebear.com/7.x/micah/svg?seed=Toby&backgroundColor=transparent',
      'https://api.dicebear.com/7.x/micah/svg?seed=Luna&backgroundColor=transparent',
      'https://api.dicebear.com/7.x/micah/svg?seed=Cleo&backgroundColor=transparent',
    ];

    for (String url in provider.ownedAvatars) {
      if (!avatars.contains(url)) avatars.add(url);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Customize Identity', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 24),

                    const Text('CHOOSE YOUR AVATAR', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: avatars.map((url) {
                        bool isSelected = selectedAvatarUrl == url;
                        return GestureDetector(
                          onTap: () {
                            if (provider.hapticsEnabled) HapticFeedback.selectionClick();
                            setModalState(() => selectedAvatarUrl = url);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 70,
                            width: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? AppColors.primary.withOpacity(0.2) : AppColors.surface,
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1), width: isSelected ? 3 : 1),
                            ),
                            child: ClipOval(
                              child: SvgPicture.network(url, fit: BoxFit.cover),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    const Text('GAMER TAG', style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surface,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          if (provider.hapticsEnabled) HapticFeedback.mediumImpact();
                          if (nameCtrl.text.isNotEmpty) {
                            provider.updateProfile(nameCtrl.text.trim(), selectedAvatarUrl);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                        child: const Text('Save Profile', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                      ),
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
}