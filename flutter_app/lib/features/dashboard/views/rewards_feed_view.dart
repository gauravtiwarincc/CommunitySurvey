import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class RewardsFeedView extends ConsumerWidget {
  final Widget groupTile;
  final VoidCallback onRedeemRewards;

  const RewardsFeedView({
    super.key,
    required this.groupTile,
    required this.onRedeemRewards,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black, // Dineout pure black
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'PREMIUM REWARDS',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  letterSpacing: 4.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37), // Gold
                ),
              ),
            ),
            const SizedBox(height: 24),
            // The existing group tile that shows the Wallet Balance
            groupTile,
            const SizedBox(height: 32),
            GestureDetector(
              onTap: onRedeemRewards,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.wallet_giftcard, color: Color(0xFFD4AF37), size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Redeem Earnings',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Withdraw cash or buy vouchers',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 16),
                  ],
                ),
              ),
            ),
            // Add more luxurious "Dineout" style deals and elements here later
          ],
        ),
      ),
    );
  }
}
