import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_provider.dart';
import 'arena_screen.dart'; // ADDED THIS IMPORT

class QuizResultScreen extends StatelessWidget {
final int score;
final int total;
final int coins;
final int highestMultiplier;
final int newRank;
final int ranksClimbed;

const QuizResultScreen({
super.key,
required this.score,
required this.total,
required this.coins,
required this.highestMultiplier,
required this.newRank,
required this.ranksClimbed,
});

@override
Widget build(BuildContext context) {
double accuracy = total > 0 ? (score / total) * 100 : 0;

return Scaffold(
backgroundColor: AppColors.background,
body: Container(
decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
child: SafeArea(
child: SingleChildScrollView(
padding: const EdgeInsets.all(24.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
const Text('Quiz result', style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
  Consumer<AppProvider>(
    builder: (context, provider, child) {
      return Row(
        children: [
          // DYNAMIC STREAK CHIP!
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
const SizedBox(height: 32),

const Text('Fast thinking. Real progress.', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
const SizedBox(height: 24),

Container(
width: double.infinity,
padding: const EdgeInsets.symmetric(vertical: 40),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(24),
border: Border.all(color: AppColors.primary.withOpacity(0.15)),
),
child: Column(
children: [
Stack(
alignment: Alignment.center,
children: [
SizedBox(
height: 160,
width: 160,
child: TweenAnimationBuilder<double>(
tween: Tween<double>(begin: 0, end: total > 0 ? score / total : 0),
duration: const Duration(milliseconds: 1500),
curve: Curves.easeOutCubic,
builder: (context, value, _) {
return CircularProgressIndicator(
value: value,
backgroundColor: AppColors.backgroundAlt,
color: AppColors.gold,
strokeWidth: 12,
strokeCap: StrokeCap.round,
);
},
),
),
Column(
mainAxisSize: MainAxisSize.min,
children: [
Text('$score / $total', style: const TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w800)),
const Text('CORRECT ANSWERS', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
],
),
],
),
const SizedBox(height: 32),
Row(
mainAxisAlignment: MainAxisAlignment.center,
children: [
const Icon(Icons.monetization_on, color: AppColors.gold, size: 24),
const SizedBox(width: 8),
Text('$coins', style: const TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.w800)),
const SizedBox(width: 8),
const Text('coins earned', style: TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w600)),
],
),
],
),
),
const SizedBox(height: 16),

Container(
padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
decoration: BoxDecoration(
color: AppColors.surface,
borderRadius: BorderRadius.circular(24),
border: Border.all(color: AppColors.primary.withOpacity(0.15)),
),
child: Row(
mainAxisAlignment: MainAxisAlignment.spaceEvenly,
children: [
_buildStatColumn('x$highestMultiplier', 'Best multiplier', AppColors.warning),
_buildStatColumn('${accuracy.toInt()}%', 'Accuracy', AppColors.textPrimary),
// Dynamic Rank Climb!
_buildStatColumn(ranksClimbed > 0 ? '↑ $ranksClimbed' : '-', 'Ranks climbed', AppColors.success),
],
),
),

const SizedBox(height: 32),
// Dynamic Current Rank!
Center(child: Text('Your weekly rank is now #$newRank.', style: const TextStyle(color: AppColors.textMuted, fontSize: 16))),
const SizedBox(height: 32),

SizedBox(
width: double.infinity,
height: 56,
child: ElevatedButton(
onPressed: () => Navigator.pop(context), // Pops back to the Time-Attack Quiz if they want to play again
style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
child: const Text('Play Again', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
),
),
const SizedBox(height: 16),

// FIXED THE ROUTING HERE
Center(
child: TextButton(
onPressed: () {
Navigator.pushAndRemoveUntil(
context,
MaterialPageRoute(builder: (context) => const ArenaScreen()),
(route) => route.isFirst, // Keeps your Home/Decks screen safely at the bottom
);
},
child: const Text('Back to Arena', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
),
),
const SizedBox(height: 24),
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

Widget _buildStatColumn(String top, String bottom, Color topColor) {
return Column(
children: [
Text(top, style: TextStyle(color: topColor, fontSize: 22, fontWeight: FontWeight.w800)),
const SizedBox(height: 4),
Text(bottom, style: const TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
],
);
}
}