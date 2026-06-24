import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/survey_service.dart';
import 'package:community_survey/models/survey.dart';
import 'package:community_survey/features/survey/widgets/survey_timer_widget.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:community_survey/core/widgets/glowing_button.dart';
import 'package:google_fonts/google_fonts.dart';

class SurveyDetailsPage extends ConsumerStatefulWidget {
  final String surveyId;

  const SurveyDetailsPage({super.key, required this.surveyId});

  @override
  ConsumerState<SurveyDetailsPage> createState() => _SurveyDetailsPageState();
}

class _SurveyDetailsPageState extends ConsumerState<SurveyDetailsPage> {
  bool _isLoading = false;
  Survey? _survey;
  String? _errorMessage;

  // Selected option IDs mapped by question ID
  final Map<String, String> _selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    _loadSurveyDetails();
  }

  Future<void> _loadSurveyDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final s = await ref.read(surveyServiceProvider).fetchSurveyDetail(widget.surveyId);
      if (mounted) {
        setState(() => _survey = s);
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _submitAnswers() async {
    if (_survey == null) return;
    
    // Check all questions answered
    for (var q in _survey!.questions) {
      if (!_selectedAnswers.containsKey(q.id)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            content: Text(
              'Please answer all questions. Missing: "${q.text}"',
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    final payload = _selectedAnswers.entries.map((e) => {
      'questionId': e.key,
      'selectedOption': e.value,
    }).toList();

    try {
      final success = await ref.read(surveyServiceProvider).submitSurvey(_survey!.id, payload);
      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Colors.white12),
            ),
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Thank You!',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            content: Text(
              'You have successfully completed this survey. +${_survey!.rewardPoints} points have been added to your account.',
              style: GoogleFonts.inter( fontSize: 13),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // pop dialog
                  Navigator.of(context).pop(); // pop details page
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      } else {
        throw Exception('Submission failed.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Submission failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalQuestions = _survey?.questions.length ?? 0;
    final answeredQuestions = _selectedAnswers.length;
    final progressPercent = totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          _survey?.title ?? 'Survey Detail',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PremiumMeshBackground(
        child: _isLoading && _survey == null
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadSurveyDetails, child: const Text('Retry')),
                      ],
                    ),
                  )
                : _survey == null
                    ? const Center(child: Text('Survey details not found.'))
                    : SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_survey!.description != null) ...[
                                Text(
                                  _survey!.description!,
                                  style: GoogleFonts.inter(fontSize: 14, height: 1.5),
                                ),
                                const SizedBox(height: 20),
                              ],
                              
                              if (!_survey!.isCompleted && _survey!.expiresAt != null) ...[
                                SurveyTimerWidget(expiresAt: _survey!.expiresAt!),
                                const SizedBox(height: 20),
                              ],

                              // Animated Progress Indicator Bar
                              GlassCard(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Progress Tracker',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          '$answeredQuestions of $totalQuestions completed',
                                          style: GoogleFonts.inter(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            color: theme.colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: progressPercent,
                                        minHeight: 6,
                                        backgroundColor: Colors.white.withOpacity(0.04),
                                        valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              ..._survey!.questions.map((q) => _buildQuestionCard(q, theme)),
                              const SizedBox(height: 12),
                              
                              GlowingButton(
                                onPressed: _isLoading ? null : _submitAnswers,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator( strokeWidth: 2),
                                      )
                                    : const Text('Submit Survey'),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildQuestionCard(SurveyQuestion question, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              question.text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ...question.options.map((option) {
            final isSelected = _selectedAnswers[question.id] == option.id;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isSelected ? theme.colorScheme.primary.withOpacity(0.08) : Colors.white.withOpacity(0.03),
                border: Border.all(
                  color: isSelected ? theme.colorScheme.primary : Colors.white.withOpacity(0.06),
                  width: isSelected ? 1.5 : 1.0,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAnswers[question.id] = option.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            option.text,
                            style: GoogleFonts.inter(
                              color: isSelected ? Colors.white : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // Premium indicator circle on the right side
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? theme.colorScheme.primary : Colors.white24,
                              width: isSelected ? 6 : 1.5,
                            ),
                            color: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
