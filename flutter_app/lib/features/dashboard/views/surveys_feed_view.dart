import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/models/survey.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class SurveysFeedView extends ConsumerWidget {
  final List<Survey> surveys;
  final Widget Function(Survey) buildSurveyCard;
  final Widget adCarousel;

  const SurveysFeedView({
    super.key,
    required this.surveys,
    required this.buildSurveyCard,
    required this.adCarousel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Center(
            child: Text(
              'AVAILABLE SURVEYS',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                letterSpacing: 4.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD4AF37), // Gold
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
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
                    adCarousel,
                    const SizedBox(height: 24),
                    ...surveys.map((survey) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: buildSurveyCard(survey),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
