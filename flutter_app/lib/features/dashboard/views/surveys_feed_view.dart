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
      decoration: const BoxDecoration(
        color: Color(0xFF000000), // Pure Black
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Available Surveys near you',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
