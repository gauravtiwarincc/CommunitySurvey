import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class DiscoverFeedView extends ConsumerWidget {
  final Widget adCarousel;
  final Widget statsProgress;
  final int availableSurveys;
  final int pointsEarned;
  final List<dynamic> trendingSurveys; // Will accept generic list of surveys

  const DiscoverFeedView({
    super.key,
    required this.adCarousel,
    required this.statsProgress,
    this.availableSurveys = 24,
    this.pointsEarned = 1250,
    this.trendingSurveys = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goldColor = const Color(0xFFD4AF37);
    final charcoal = const Color(0xFF1A1A1A);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, left: 24, right: 24, bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Stats Cards
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: charcoal,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.assignment_outlined, color: goldColor, size: 24),
                      const SizedBox(height: 16),
                      Text(
                        '$availableSurveys',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: goldColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'SURVEYS AVAILABLE',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: charcoal,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.stars, color: goldColor, size: 24),
                      const SizedBox(height: 16),
                      Text(
                        '$pointsEarned',
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: goldColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'POINTS EARNED',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Featured Highlights
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Highlights',
                style: GoogleFonts.montserrat(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'View All',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: goldColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // We assume the adCarousel passed in looks similar to the glassmorphic card with the learn more button
          // For now, we wrap it to ensure it takes full width
          adCarousel,
          const SizedBox(height: 32),

          // Trending Missions
          Text(
            'Trending Missions',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildMissionTile(
            title: 'Daily Marketplace Feedback',
            subtitle: 'Earn 50 Points • 3 mins',
            icon: Icons.payments_outlined,
            isFeatured: true,
          ),
          const SizedBox(height: 12),
          _buildMissionTile(
            title: 'Market Sentiment Survey',
            subtitle: 'Earn 120 Points • 8 mins',
            icon: Icons.bar_chart,
            isFeatured: false,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionTile({required String title, required String subtitle, required IconData icon, bool isFeatured = false}) {
    final goldColor = const Color(0xFFD4AF37);
    final charcoal = const Color(0xFF1A1A1A);
    
    return Container(
      decoration: BoxDecoration(
        color: charcoal,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          if (isFeatured)
            Positioned(
              left: 0,
              top: 16,
              bottom: 16,
              child: Container(
                width: 4,
                decoration: BoxDecoration(
                  color: goldColor,
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(4)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: goldColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

