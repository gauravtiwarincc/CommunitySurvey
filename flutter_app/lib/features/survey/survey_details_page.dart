import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/survey_service.dart';
import 'package:community_survey/models/survey.dart';

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
          SnackBar(content: Text('Please answer all questions. Missing: "${q.text}"')),
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    final payload = _selectedAnswers.entries.map((e) => {
      'questionId': e.key,
      'selectedOptionId': e.value,
    }).toList();

    try {
      final success = await ref.read(surveyServiceProvider).submitSurvey(_survey!.id, payload);
      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Thank You!'),
            content: Text('You have successfully completed this survey. +${_survey!.rewardPoints} points have been added to your account.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // pop dialog
                  Navigator.of(context).pop(); // pop details page
                },
                child: const Text('OK'),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(_survey?.title ?? 'Survey Details'),
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
                  ? const Center(child: Text('Survey details not found.'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_survey!.description != null) ...[
                            Text(
                              _survey!.description!,
                              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
                            ),
                            const SizedBox(height: 24),
                          ],
                          ..._survey!.questions.map((q) => _buildQuestionCard(q, theme)),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitAnswers,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Submit Survey'),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildQuestionCard(SurveyQuestion question, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.1)),
      ),
      color: Colors.white,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...question.options.map((option) {
              final isSelected = _selectedAnswers[question.id] == option.id;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? theme.colorScheme.primary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected ? theme.colorScheme.primary.withOpacity(0.04) : Colors.transparent,
                ),
                child: RadioListTile<String>(
                  title: Text(option.text),
                  value: option.id,
                  groupValue: _selectedAnswers[question.id],
                  activeColor: theme.colorScheme.primary,
                  onChanged: (val) {
                    setState(() {
                      _selectedAnswers[question.id] = val!;
                    });
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
