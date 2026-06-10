import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:community_survey/core/widgets/glowing_button.dart';
import 'package:google_fonts/google_fonts.dart';

class RedeemItem {
  final String id;
  final String title;
  final String description;
  final int pointsCost;
  final IconData icon;
  final Color color;

  RedeemItem({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.icon,
    required this.color,
  });
}

class RedeemRewardsPage extends ConsumerStatefulWidget {
  const RedeemRewardsPage({super.key});

  @override
  ConsumerState<RedeemRewardsPage> createState() => _RedeemRewardsPageState();
}

class _RedeemRewardsPageState extends ConsumerState<RedeemRewardsPage> {
  final List<RedeemItem> _items = [
    RedeemItem(
      id: 'v_10',
      title: '₹10 Cash Voucher',
      description: 'Instant credit to your linked UPI wallet.',
      pointsCost: 10,
      icon: Icons.monetization_on,
      color: Colors.green,
    ),
    RedeemItem(
      id: 'v_50',
      title: '₹50 Cash Voucher',
      description: 'Instant credit to your linked UPI wallet.',
      pointsCost: 50,
      icon: Icons.account_balance_wallet,
      color: Colors.teal,
    ),
    RedeemItem(
      id: 'neckband',
      title: 'Wireless Sport Neckband',
      description: '12mm drivers, 20-hour playback with fast charging.',
      pointsCost: 150,
      icon: Icons.headphones,
      color: Colors.blue,
    ),
    RedeemItem(
      id: 'powerbank',
      title: '10,000mAh Power Bank',
      description: 'Dual port output, 18W fast charging support.',
      pointsCost: 300,
      icon: Icons.battery_charging_full,
      color: Colors.orange,
    ),
    RedeemItem(
      id: 'fitband',
      title: 'Smart Fitness Band',
      description: 'Heart rate tracker, sleep monitoring, OLED display.',
      pointsCost: 500,
      icon: Icons.watch,
      color: Colors.red,
    ),
    RedeemItem(
      id: 'earbuds',
      title: 'Bluetooth Earbuds Pro',
      description: 'Active Noise Cancellation, 30-hour battery life.',
      pointsCost: 800,
      icon: Icons.hearing,
      color: Colors.purple,
    ),
    RedeemItem(
      id: 'tablet',
      title: 'Premium Smart Tablet',
      description: '10.1 inch display, 4GB RAM, 64GB storage, Wi-Fi.',
      pointsCost: 2000,
      icon: Icons.tablet_mac,
      color: Colors.indigo,
    ),
  ];

  void _redeemItem(BuildContext context, RedeemItem item, int currentPoints, Color activeColor) {
    if (currentPoints < item.pointsCost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF161823),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
          title: Text(
            'Insufficient Points',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: Text(
            'You need ${item.pointsCost - currentPoints} more points to redeem this item.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF161823),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
        title: Text(
          'Confirm Redemption',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to redeem "${item.title}" for ${item.pointsCost} points?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white38)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // close confirm dialog
              
              // Deduct points locally in state
              final authNotifier = ref.read(authProvider.notifier);
              final currentProfile = ref.read(authProvider).profile;
              if (currentProfile != null) {
                final updatedPoints = currentProfile.rewardPoints != null 
                    ? currentProfile.rewardPoints! - item.pointsCost 
                    : 0;
                final updatedWallet = currentProfile.walletBalance != null
                    ? currentProfile.walletBalance! + (item.id.startsWith('v_') ? (item.id == 'v_10' ? 10 : 50) : 0)
                    : 0;

                final updatedUser = currentProfile.copyWith(
                  rewardPoints: updatedPoints,
                  walletBalance: updatedWallet,
                );
                authNotifier.setProfile(updatedUser);
              }

              // Show success dialog
              showDialog(
                context: context,
                builder: (successContext) => AlertDialog(
                  backgroundColor: const Color(0xFF161823),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white10)),
                  title: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Redeemed Successfully!',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                  content: Text(
                    item.id.startsWith('v_') 
                        ? 'Voucher applied! The cash amount has been credited to your wallet balance.'
                        : 'Your order for "${item.title}" has been placed successfully and will be delivered to your registered profile address.',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(successContext).pop(),
                      child: Text('Done', style: TextStyle(color: activeColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: activeColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final profile = ref.watch(authProvider).profile;
    final rewardPoints = profile?.rewardPoints ?? 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Redeem Rewards',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: PremiumMeshBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Points Balance Card
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        activeColor,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR POINTS BALANCE',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.7),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$rewardPoints pts',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Icons.stars,
                          size: 50,
                          color: Colors.white.withOpacity(0.25),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Expiry Limit Card Info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade900.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade900.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade400, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Points Expiry Status: Your earned reward points remain active for 365 days. Oldest points are automatically spent first.',
                          style: GoogleFonts.inter(fontSize: 11, color: Colors.amber.shade300, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Redeemable Gadgets & Vouchers',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),

                // Items List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final isRedeemable = rewardPoints >= item.pointsCost;

                    return GlassCard(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Icon block
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: item.color.withOpacity(0.2)),
                            ),
                            child: Icon(
                              item.icon,
                              color: item.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.description,
                                  style: GoogleFonts.inter(fontSize: 11, color: Colors.white60),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${item.pointsCost} PTS',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    color: activeColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Action button
                          ElevatedButton(
                            onPressed: () => _redeemItem(context, item, rewardPoints, activeColor),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRedeemable ? activeColor : Colors.white.withOpacity(0.06),
                              foregroundColor: isRedeemable ? Colors.white : Colors.white24,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            child: Text(
                              'Redeem', 
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
