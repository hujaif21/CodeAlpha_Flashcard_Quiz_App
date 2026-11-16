import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_provider.dart';
import 'arena_screen.dart';
import 'profile_screen.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  int _selectedTabIndex = 0; // 0 for Avatars, 1 for Titles

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
              // HEADER
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('The Vault', style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0)),
                        SizedBox(height: 4),
                        Text('Unlock your legacy.', style: TextStyle(color: AppColors.textMuted, fontSize: 16, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    Consumer<AppProvider>(
                      builder: (context, provider, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))],
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text('${provider.totalCoins}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // CUSTOM TAB BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary.withOpacity(0.1))),
                  child: Row(
                    children: [
                      _buildTabButton(0, 'Exclusive Avatars', Icons.face),
                      _buildTabButton(1, 'Flex Titles', Icons.military_tech),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // VAULT INVENTORY
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: _selectedTabIndex == 0 ? _buildAvatarsSection() : _buildTitlesSection(),
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
          currentIndex: 2, // 2 = Vault
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          onTap: (index) {
            if (index == 2) return; // Already here

            if (index == 0) {
              Navigator.popUntil(context, (route) => route.isFirst);
            } else if (index == 1) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ArenaScreen()));
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

  // --- TAB CONTROLLER ---
  Widget _buildTabButton(int index, String text, IconData icon) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.waveGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.textMuted, size: 18),
              const SizedBox(width: 8),
              Text(text, style: TextStyle(color: isSelected ? Colors.white : AppColors.textMuted, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  // --- AESTHETIC STICKERS STORE ---
  Widget _buildAvatarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FEATURED MYTHIC AVATAR
        _buildFeaturedItem(
          title: "Main Character Energy",
          rarity: "MYTHIC",
          price: 15000,
          avatarUrl: 'https://api.dicebear.com/7.x/micah/svg?seed=Zeus&baseColor=f9c9b6&clothing=hoodie&clothingColor=9287ff',
          gradient: AppColors.waveGradient,
        ),
        const SizedBox(height: 24),
        const Text("TRENDING DROP", style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 12),

        // GRID OF PREMIUM GEN-Z STICKERS
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75,
          children: [
            _buildGridItem("Midnight Aura", "EPIC", 5000, 'https://api.dicebear.com/7.x/micah/svg?seed=Shadow&clothing=jacket'),
            _buildGridItem("Starboy / Girl", "EPIC", 5000, 'https://api.dicebear.com/7.x/lorelei/svg?seed=Nova&backgroundColor=transparent'),
            _buildGridItem("Lowkey Chill", "RARE", 2500, 'https://api.dicebear.com/7.x/micah/svg?seed=Oliver&clothing=sweater'),
            _buildGridItem("Y2K Vibes", "RARE", 2500, 'https://api.dicebear.com/7.x/lorelei/svg?seed=Chloe&backgroundColor=transparent'),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // --- GEN-Z TITLES STORE ---
  Widget _buildTitlesSection() {
    return Column(
      children: [
        _buildTitleItem("Infinite Aura", "MYTHIC", 10000, AppColors.primary),
        _buildTitleItem("Academic Weapon", "EPIC", 7500, AppColors.gold),
        _buildTitleItem("Built Different", "EPIC", 5000, AppColors.danger),
        _buildTitleItem("Brain Rot Immune", "RARE", 2000, AppColors.success),
      ],
    );
  }

  // --- WIDGET BUILDERS ---
  Widget _buildFeaturedItem({required String title, required String rarity, required int price, required String avatarUrl, required Gradient gradient}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.25), blurRadius: 20, spreadRadius: 0)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(gradient: AppColors.goldGradient, borderRadius: BorderRadius.circular(12)),
            child: Text(rarity, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.0)),
          ),
          const SizedBox(height: 16),
          Container(
            height: 120, width: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient, border: Border.all(color: Colors.white, width: 4), boxShadow: AppColors.cardShadow),
            child: ClipOval(child: SvgPicture.network(avatarUrl, fit: BoxFit.cover)),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          _buildBuyButton(price, 'avatar', avatarUrl),
        ],
      ),
    );
  }

  Widget _buildGridItem(String title, String rarity, int price, String avatarUrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.primary.withOpacity(0.1)), boxShadow: AppColors.cardShadow),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(rarity, style: TextStyle(color: rarity == 'EPIC' ? AppColors.primary : AppColors.success, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
          Container(
            height: 70, width: 70,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.backgroundAlt, border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2)),
            child: ClipOval(child: SvgPicture.network(avatarUrl, fit: BoxFit.cover)),
          ),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w800)),
          _buildBuyButton(price, 'avatar', avatarUrl, isSmall: true),
        ],
      ),
    );
  }

  Widget _buildTitleItem(String title, String rarity, int price, Color themeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: themeColor.withOpacity(0.3)), boxShadow: AppColors.cardShadow),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rarity, style: TextStyle(color: themeColor, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: themeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(title, style: TextStyle(color: themeColor, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.0)),
              ),
            ],
          ),
          _buildBuyButton(price, 'title', title, isSmall: true),
        ],
      ),
    );
  }

  // --- FULLY UPDATED INVENTORY BUTTON ---
  Widget _buildBuyButton(int price, String itemType, String itemValue, {bool isSmall = false}) {
    return Consumer<AppProvider>(
        builder: (context, provider, child) {

          bool isEquipped = (itemType == 'avatar' && provider.userAvatar == itemValue) ||
              (itemType == 'title' && provider.userTitle == itemValue);

          bool isOwned = (itemType == 'avatar' && provider.ownedAvatars.contains(itemValue)) ||
              (itemType == 'title' && provider.ownedTitles.contains(itemValue));

          return GestureDetector(
            onTap: isEquipped ? null : () async {
              // INSTANT EQUIP (If Already Owned)
              if (isOwned) {
                await provider.purchaseItem(0, itemType, itemValue);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Equipped!', style: TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
                return;
              }

              // NORMAL PURCHASE
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.primary))
              );

              bool success = await provider.purchaseItem(price, itemType, itemValue);
              if (context.mounted) Navigator.pop(context);

              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Purchased and Equipped!', style: TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                ));
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Not enough coins! Keep grinding.', style: TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                ));
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 24, vertical: isSmall ? 8 : 12),
              decoration: BoxDecoration(
                // Green if equipped, Blue/Light Purple if owned, Deep Purple if locked
                  color: isEquipped ? AppColors.success : (isOwned ? AppColors.primaryLight : AppColors.primary),
                  borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
                  boxShadow: isEquipped ? null : [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isEquipped && !isOwned) Icon(Icons.monetization_on, color: AppColors.gold, size: isSmall ? 14 : 18),
                  if (!isEquipped && !isOwned) const SizedBox(width: 4),
                  Text(
                    // Smart text rendering
                      isEquipped ? 'Equipped' : (isOwned ? 'Equip' : price.toString()),
                      style: TextStyle(color: Colors.white, fontSize: isSmall ? 13 : 16, fontWeight: FontWeight.w900)
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}