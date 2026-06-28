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
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'DISCOVER & EARN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  letterSpacing: 4.0,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFD4AF37), // Gold
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Watch ads and complete quick tasks to earn extra points',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.white70,
                ),
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
