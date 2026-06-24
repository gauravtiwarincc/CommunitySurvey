import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:community_survey/core/widgets/glowing_button.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:community_survey/models/user.dart';
import 'package:community_survey/models/reward_item.dart';
import 'package:community_survey/services/reward_service.dart';

class RedeemRewardsPage extends ConsumerStatefulWidget {
  const RedeemRewardsPage({super.key});

  @override
  ConsumerState<RedeemRewardsPage> createState() => _RedeemRewardsPageState();
}

class _RedeemRewardsPageState extends ConsumerState<RedeemRewardsPage> {
  List<RewardItem> _items = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isRedeeming = false;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      final items = await ref.read(rewardServiceProvider).fetchRewardItems();
      if (mounted) {
        setState(() {
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Fallback to mock items if backend fails
        setState(() {
          _items = [
            RewardItem(
              id: 'v_10',
              title: '₹10 Cash Voucher',
              description: 'Instant credit to your linked UPI wallet.',
              pointsCost: 10,
              category: 'voucher',
              cashValue: 10,
            ),
            RewardItem(
              id: 'neckband',
              title: 'Wireless Sport Neckband',
              description: '12mm drivers, 20-hour playback with fast charging.',
              pointsCost: 150,
              category: 'gadget',
            ),
          ];
          _isLoading = false;
        });
      }
    }
  }

  IconData _getIconForCategory(String? category, String id) {
    if (category == 'voucher') return Icons.monetization_on;
    if (id.contains('band')) return Icons.headphones;
    if (id.contains('bank')) return Icons.battery_charging_full;
    if (id.contains('watch') || id.contains('fit')) return Icons.watch;
    if (id.contains('tablet')) return Icons.tablet_mac;
    return Icons.card_giftcard;
  }

  Color _getColorForCategory(String? category) {
    if (category == 'voucher') return Colors.green;
    return Colors.blue;
  }

  void _redeemItem(BuildContext context, RewardItem item, int currentPoints, Color activeColor) {
    if (currentPoints < item.pointsCost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white12)),
          title: Text(
            'Insufficient Points',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'You need ${item.pointsCost - currentPoints} more points to redeem this item.',
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
      barrierDismissible: !_isRedeeming,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white12)),
            title: Text(
              'Confirm Redemption',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Are you sure you want to redeem "${item.title}" for ${item.pointsCost} points?',
            ),
            actions: [
              TextButton(
                onPressed: _isRedeeming ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _isRedeeming ? null : () async {
                  setStateDialog(() => _isRedeeming = true);
                  
                  try {
                    final result = await ref.read(rewardServiceProvider).redeemItem(item.id);
                    
                    if (mounted) {
                      final updatedUserJson = result['updatedUser'] as Map<String, dynamic>?;
                      if (updatedUserJson != null) {
                        final authNotifier = ref.read(authProvider.notifier);
                        final currentProfile = ref.read(authProvider).profile;
                        if (currentProfile != null) {
                          authNotifier.setProfile(currentProfile.copyWith(
                            rewardPoints: updatedUserJson['rewardPoints'],
                            walletBalance: updatedUserJson['walletBalance'],
                          ));
                        }
                      } else {
                        // Fallback local deduct if API success but no user returned
                        final authNotifier = ref.read(authProvider.notifier);
                        final currentProfile = ref.read(authProvider).profile;
                        if (currentProfile != null) {
                           authNotifier.setProfile(currentProfile.copyWith(
                             rewardPoints: (currentProfile.rewardPoints ?? 0) - item.pointsCost,
                             walletBalance: (currentProfile.walletBalance ?? 0) + (item.cashValue?.toInt() ?? 0),
                           ));
                        }
                      }
                      
                      Navigator.of(dialogContext).pop(); // close confirm dialog
                      
                      // Show success dialog
                      showDialog(
                        context: context,
                        builder: (successContext) => AlertDialog(
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.white12)),
                          title: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                'Redeemed Successfully!',
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          content: Text(
                            result['message'] ?? 'Your order has been placed successfully.',
                            style: const TextStyle( fontSize: 13),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(successContext).pop(),
                              child: Text('Done', style: TextStyle(color: activeColor, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                      );
                    }
                  } finally {
                     if (mounted) {
                       setStateDialog(() => _isRedeeming = false);
                     }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  foregroundColor: activeColor.contrastTextColor,
                ),
                child: _isRedeeming 
                   ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2))
                   : const Text('Redeem'),
              ),
            ],
          );
        }
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
          ),
        ),
      ),
      body: PremiumMeshBackground(
        child: SafeArea(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Points Balance Card
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [activeColor, theme.colorScheme.secondary],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: -10,
                          bottom: -10,
                          child: Icon(
                            Icons.stars,
                            size: 80,
                            color: activeColor.withOpacity(0.05),
                          ),
                        ),
                        Padding(
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
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '$rewardPoints pts',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 30,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.stars,
                                size: 50,
                                color: activeColor,
                              ),
                            ],
                          ),
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
                  ),
                ),
                const SizedBox(height: 12),

                // Items List
                if (_items.isEmpty)
                  const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text('No reward items available right now.'),
                  ))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      final isRedeemable = rewardPoints >= item.pointsCost;
                      final icon = _getIconForCategory(item.category, item.id);
                      final iconColor = _getColorForCategory(item.category);

                      return GlassCard(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Icon block
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: iconColor.withOpacity(0.2)),
                              ),
                              child: Icon(
                                icon,
                                color: iconColor,
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
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.description,
                                    style: GoogleFonts.inter(fontSize: 11),
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
                                foregroundColor: isRedeemable ? activeColor.contrastTextColor : Colors.white24,
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
