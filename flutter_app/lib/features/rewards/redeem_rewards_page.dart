import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/features/auth/auth_provider.dart';

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

  void _redeemItem(BuildContext context, RedeemItem item, int currentPoints) {
    if (currentPoints < item.pointsCost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Insufficient Points'),
          content: Text('You need ${item.pointsCost - currentPoints} more points to redeem this item.'),
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
        title: const Text('Confirm Redemption'),
        content: Text('Are you sure you want to redeem "${item.title}" for ${item.pointsCost} points?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
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
                  title: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 28),
                      SizedBox(width: 8),
                      Text('Redeemed Successfully!'),
                    ],
                  ),
                  content: Text(item.id.startsWith('v_') 
                      ? 'Voucher applied! The cash amount has been credited to your wallet balance.'
                      : 'Your order for "${item.title}" has been placed successfully and will be delivered to your registered profile address.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(successContext).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(authProvider).profile;
    final rewardPoints = profile?.rewardPoints ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Redeem Rewards'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Points Balance Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: theme.colorScheme.primary.withOpacity(0.08),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Points Balance',
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$rewardPoints pts',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      Icons.stars,
                      size: 48,
                      color: theme.colorScheme.primary.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Expiry Limit Card Info
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.amber.shade200),
              ),
              color: Colors.amber.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber.shade800),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Points Expiry Status: Your earned reward points remain active for 365 days. Oldest points are automatically spent first.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Redeemable Gadgets & Vouchers',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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

                return Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      children: [
                        // Icon block
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: item.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            item.icon,
                            color: item.color,
                            size: 28,
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
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.description,
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item.pointsCost} pts',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Action button
                        ElevatedButton(
                          onPressed: () => _redeemItem(context, item, rewardPoints),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRedeemable ? theme.colorScheme.primary : Colors.grey.shade300,
                            foregroundColor: isRedeemable ? Colors.white : Colors.black38,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            elevation: 0,
                          ),
                          child: const Text('Redeem', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
