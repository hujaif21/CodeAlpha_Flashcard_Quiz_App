import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_provider.dart';
import 'study_screen.dart';
import 'arena_screen.dart';
import 'profile_screen.dart';
import 'vault_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = ['All', 'Python', 'Aptitude', 'Interview', 'My Decks'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.loadDecks();
      // FIX: Load the leaderboard right when the app opens to get your live coins!
      provider.loadLeaderboard();
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
              // TOP BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: AppColors.cardShadow,
                              border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5),
                            ),
                            child: SvgPicture.asset('assets/images/logo.svg', height: 24, width: 24),
                          ),
                          const SizedBox(width: 8),
                          const Flexible(
                            child: Text(
                              'BrainBounty',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // FIX: Wrapped in Consumer to show REAL coins instead of 1,250
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
                ),
              ),

              // HEADER
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YOUR DAILY HEAD START', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                    SizedBox(height: 6),
                    Text('What will you master?', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // SEARCH BAR
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: AppColors.cardShadow),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Search your next challenge',
                      hintStyle: const TextStyle(color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primaryLight),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primaryLight.withOpacity(0.25))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primaryLight.withOpacity(0.25))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // CATEGORY CHIPS
              SizedBox(
                height: 42,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = category),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.waveGradient : null,
                            color: isSelected ? null : AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected ? AppColors.cardShadow : null,
                            border: isSelected ? null : Border.all(color: AppColors.primary.withOpacity(0.15)),
                          ),
                          child: Center(
                            child: Text(
                              category,
                              style: TextStyle(color: isSelected ? Colors.white : AppColors.textMuted, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // DECK LIST
              Expanded(
                child: Consumer<AppProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    }

                    final filteredDecks = provider.decks.where((deck) {
                      final matchesCategory = _selectedCategory == 'All' ||
                          deck.category.toLowerCase() == _selectedCategory.toLowerCase() ||
                          (_selectedCategory == 'My Decks' && deck.category.toLowerCase() == 'my decks');
                      final matchesSearch = deck.title.toLowerCase().contains(_searchQuery.toLowerCase());
                      return matchesCategory && matchesSearch;
                    }).toList();

                    if (filteredDecks.isEmpty) {
                      return Center(
                        child: Text(
                          'No decks found in category "$_selectedCategory". Tap "+" to create one!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w600),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      itemCount: filteredDecks.length,
                      itemBuilder: (context, index) {
                        final deck = filteredDecks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18.0),
                          child: _buildDeckCard(
                            deckId: deck.id,
                            title: deck.title.replaceAll('_', ' '),
                            category: deck.category,
                            difficulty: deck.difficulty,
                            diffColor: deck.difficulty.toLowerCase() == 'hard' ? AppColors.danger : AppColors.success,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      // FLOATING ACTION BUTTON (+) TO CREATE NEW DECK
      floatingActionButton: Container(
        decoration: BoxDecoration(gradient: AppColors.waveGradient, shape: BoxShape.circle, boxShadow: AppColors.cardShadow),
        child: FloatingActionButton(
          onPressed: () => _showAddDeckModal(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
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
          currentIndex: 0, // 0 = Decks
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          onTap: (index) {
            if (index == 0) return; // Already here

            if (index == 1) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ArenaScreen()));
            } else if (index == 2) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const VaultScreen()));
            } else if (index == 3) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
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
        boxShadow: AppColors.cardShadow,
        border: Border.all(color: iconColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 15),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _buildDeckCard({required int deckId, required String title, required String category, required String difficulty, required Color diffColor}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StudyScreen(deckId: deckId, deckTitle: title)),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppColors.cardShadow,
          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.w800))),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.danger, size: 20),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.surface,
                            title: const Text('Delete Deck?', style: TextStyle(color: AppColors.textPrimary)),
                            content: Text('Are you sure you want to delete "$title"?', style: const TextStyle(color: AppColors.textMuted)),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppColors.danger))),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await Provider.of<AppProvider>(context, listen: false).removeDeck(deckId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deck deleted!')));
                          }
                        }
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.backgroundAlt, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 16),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(gradient: AppColors.waveGradient, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.white, size: 13),
                      const SizedBox(width: 5),
                      Text(category.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: diffColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(difficulty, style: TextStyle(color: diffColor, fontSize: 13, fontWeight: FontWeight.w800)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDeckModal(BuildContext context) {
    final titleCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'My Decks');
    String selectedDiff = 'Easy';
    bool isSubmitting = false;

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Create Custom Deck', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Deck Title (e.g. Flutter_State_Management)',
                      labelStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: categoryCtrl,
                    style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Category (Python, Aptitude, Interview, My Decks)',
                      labelStyle: const TextStyle(color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : () async {
                        if (titleCtrl.text.isNotEmpty && categoryCtrl.text.isNotEmpty) {
                          setModalState(() => isSubmitting = true);
                          await Provider.of<AppProvider>(context, listen: false).createDeck(
                            categoryCtrl.text,
                            titleCtrl.text,
                            selectedDiff,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Custom deck created successfully!')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        isSubmitting ? 'Creating...' : 'Save Deck to Sheet',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }
}