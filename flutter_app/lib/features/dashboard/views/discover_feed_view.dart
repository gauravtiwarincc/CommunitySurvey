import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoverFeedView extends ConsumerWidget {
  final Widget adCarousel;
  final Widget statsProgress;

  const DiscoverFeedView({
    super.key,
    required this.adCarousel,
    required this.statsProgress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55), // Translucent to reveal background glow
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Discover & Earn',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Watch ads and complete quick tasks to earn extra points',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            statsProgress,
            const SizedBox(height: 24),
            adCarousel,
            // We can add "Quick Tasks" or other Instamart-style horizontal scrollers here later
          ],
        ),
      ),
    );
  }
}
