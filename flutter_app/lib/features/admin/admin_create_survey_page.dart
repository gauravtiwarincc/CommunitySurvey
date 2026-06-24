import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/admin_service.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:community_survey/core/widgets/glowing_button.dart';
import 'package:community_survey/core/network/api_client.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionInput {
  final TextEditingController controller = TextEditingController();
  final List<TextEditingController> options = [
    TextEditingController(),
    TextEditingController(),
  ];

  void dispose() {
    controller.dispose();
    for (var opt in options) {
      opt.dispose();
    }
  }
}

class AdminCreateSurveyPage extends ConsumerStatefulWidget {
  const AdminCreateSurveyPage({super.key});

  @override
  ConsumerState<AdminCreateSurveyPage> createState() => _AdminCreateSurveyPageState();
}

class _AdminCreateSurveyPageState extends ConsumerState<AdminCreateSurveyPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');
  
  final List<QuestionInput> _questions = [QuestionInput()];
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    for (var q in _questions) {
      q.dispose();
    }
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionInput());
    });
  }

  void _removeQuestion(int index) {
    if (_questions.length > 1) {
      setState(() {
        _questions[index].dispose();
        _questions.removeAt(index);
      });
    }
  }

  void _addOption(int questionIndex) {
    setState(() {
      _questions[questionIndex].options.add(TextEditingController());
    });
  }

  void _removeOption(int questionIndex, int optionIndex) {
    if (_questions[questionIndex].options.length > 2) {
      setState(() {
        _questions[questionIndex].options[optionIndex].dispose();
        _questions[questionIndex].options.removeAt(optionIndex);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final points = int.tryParse(_pointsController.text) ?? 10;
      
      final questionsPayload = _questions.map((q) {
        return {
          'question': q.controller.text.trim(),
          'options': q.options.map((opt) => {'title': opt.text.trim()}).toList(),
        };
      }).toList();

      final success = await ref.read(adminServiceProvider).createSurvey(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        rewardPoints: points,
        questions: questionsPayload,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Survey created successfully!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = getApiErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Create Survey',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
        ),
      ),
      body: PremiumMeshBackground(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Survey Details',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(
                            labelText: 'Survey Title',
                            prefixIcon: Icon(Icons.title),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description (Optional)',
                            prefixIcon: Icon(Icons.description),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _pointsController,
                          decoration: const InputDecoration(
                            labelText: 'Reward Points',
                            prefixIcon: Icon(Icons.stars),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (int.tryParse(value) == null) return 'Must be a number';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  ..._questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Question ${index + 1}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_questions.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _removeQuestion(index),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: question.controller,
                              decoration: const InputDecoration(
                                labelText: 'Question Text',
                                prefixIcon: Icon(Icons.help_outline),
                              ),
                              validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                            ),
                            const SizedBox(height: 16),
                            const Text('Options', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...question.options.asMap().entries.map((optEntry) {
                              final optIndex = optEntry.key;
                              final optController = optEntry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: optController,
                                        decoration: InputDecoration(
                                          labelText: 'Option ${optIndex + 1}',
                                          isDense: true,
                                        ),
                                        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                                      ),
                                    ),
                                    if (question.options.length > 2)
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 20),
                                        onPressed: () => _removeOption(index, optIndex),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                            TextButton.icon(
                              onPressed: () => _addOption(index),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Option'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: _addQuestion,
                    icon: const Icon(Icons.add_box),
                    label: const Text('Add Another Question'),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  GlowingButton(
                    onPressed: _isLoading ? () {} : _submit,
                    child: Text(_isLoading ? 'Creating...' : 'Create Group Survey'),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
