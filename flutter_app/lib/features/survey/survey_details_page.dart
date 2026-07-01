import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/survey_service.dart';
import 'package:community_survey/models/survey.dart';
import 'package:community_survey/features/survey/widgets/survey_timer_widget.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:community_survey/core/widgets/glowing_button.dart';
import 'package:community_survey/features/survey/survey_complete_page.dart';
import 'package:google_fonts/google_fonts.dart';

class SurveyDetailsPage extends ConsumerStatefulWidget {
  final String surveyId;

  const SurveyDetailsPage({super.key, required this.surveyId});

  @override
  ConsumerState<SurveyDetailsPage> createState() => _SurveyDetailsPageState();
}

class _SurveyDetailsPageState extends ConsumerState<SurveyDetailsPage> {
  Survey? _survey;
  bool _isLoading = true;
  String? _errorMessage;
  final Map<String, String> _selectedAnswers = {};
  bool _hasStarted = false;

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
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => SurveyCompletePage(
                pointsEarned: _survey!.rewardPoints,
                surveyTitle: _survey!.title,
              ),
            ),
          );
        }
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
    final goldColor = const Color(0xFFD4AF37);
    final charcoal = const Color(0xFF1A1A1A);
    final totalQuestions = _survey?.questions.length ?? 0;
    final answeredQuestions = _selectedAnswers.length;
    final progressPercent = totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF131313),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131313),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Community Vault',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: goldColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_balance_wallet_outlined, color: goldColor),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
      ),
      body: _isLoading && _survey == null
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
                  ? const Center(child: Text('Survey details not found.', style: TextStyle(color: Colors.white)))
                  : !_hasStarted
                      ? _buildPreStartScreen(charcoal, goldColor)
                      : _buildActiveSurveyScreen(theme, charcoal, goldColor, progressPercent, answeredQuestions, totalQuestions),
    );
  }

  Widget _buildPreStartScreen(Color charcoal, Color goldColor) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Header
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?q=80&w=800'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: goldColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: goldColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          'FEATURED SURVEY',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: goldColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _survey!.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Duration & Reward Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: charcoal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.schedule, color: goldColor),
                          const SizedBox(height: 8),
                          Text('DURATION', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white54, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text('5 Min', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: charcoal,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.stars, color: goldColor),
                          const SizedBox(height: 8),
                          Text('REWARD', style: GoogleFonts.montserrat(fontSize: 10, color: Colors.white54, letterSpacing: 1)),
                          const SizedBox(height: 4),
                          Text('${_survey!.rewardPoints} Pts', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: goldColor)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description Container
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: charcoal,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: goldColor, size: 20),
                        const SizedBox(width: 8),
                        Text('Description', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _survey!.description ?? 'Your voice matters in shaping the future. Complete this survey to share your insights.',
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70, height: 1.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'All data is anonymized and secured within the Vault. Upon completion, ${_survey!.rewardPoints} points will be instantly added to your wallet.',
                      style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white70, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    _buildCheckItem('Influence local policies', goldColor),
                    const SizedBox(height: 12),
                    _buildCheckItem('Contribute to regional reports', goldColor),
                    const SizedBox(height: 12),
                    _buildCheckItem('Data remains 100% private', goldColor),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bottom Sticky Button
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [const Color(0xFF131313), const Color(0xFF131313).withOpacity(0.0)],
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                setState(() => _hasStarted = true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                'Start Survey',
                style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckItem(String text, Color goldColor) {
    return Row(
      children: [
        Icon(Icons.check_circle_outline, color: goldColor, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: GoogleFonts.montserrat(fontSize: 13, color: Colors.white))),
      ],
    );
  }

  Widget _buildActiveSurveyScreen(ThemeData theme, Color charcoal, Color goldColor, double progressPercent, int answeredQuestions, int totalQuestions) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Animated Progress Indicator Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: charcoal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Progress Tracker', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white)),
                      Text('$answeredQuestions of $totalQuestions completed', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 11, color: goldColor)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.04),
                      valueColor: AlwaysStoppedAnimation<Color>(goldColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ..._survey!.questions.map((q) => _buildQuestionCard(q, theme, charcoal, goldColor)),
            const SizedBox(height: 12),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _submitAnswers,
              style: ElevatedButton.styleFrom(
                backgroundColor: goldColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text('Submit Survey', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(SurveyQuestion question, ThemeData theme, Color charcoal, Color goldColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              question.text,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ...question.options.map((option) {
            final isSelected = _selectedAnswers[question.id] == option.id;
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? goldColor.withOpacity(0.1) : charcoal,
                border: Border.all(
                  color: isSelected ? goldColor : Colors.white.withOpacity(0.05),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedAnswers[question.id] = option.id;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            option.text,
                            style: GoogleFonts.montserrat(
                              color: isSelected ? goldColor : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? goldColor : Colors.white24,
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
