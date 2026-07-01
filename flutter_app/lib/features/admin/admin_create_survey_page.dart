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
    final goldColor = const Color(0xFFD4AF37);
    final charcoal = const Color(0xFF131313);
    final cardColor = const Color(0xFF1A1A1A);
    
    return Scaffold(
      backgroundColor: charcoal,
      appBar: AppBar(
        backgroundColor: charcoal,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: goldColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add Mission',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
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
                  
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'MISSION DETAILS',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildAuraTextField(
                          controller: _titleController,
                          label: 'TITLE',
                          icon: Icons.title,
                          goldColor: goldColor,
                        ),
                        const SizedBox(height: 16),
                        _buildAuraTextField(
                          controller: _descriptionController,
                          label: 'DESCRIPTION (OPTIONAL)',
                          icon: Icons.description,
                          maxLines: 2,
                          goldColor: goldColor,
                        ),
                        const SizedBox(height: 16),
                        _buildAuraTextField(
                          controller: _pointsController,
                          label: 'REWARD POINTS',
                          icon: Icons.stars,
                          keyboardType: TextInputType.number,
                          goldColor: goldColor,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  ..._questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'QUESTION ${index + 1}',
                                  style: GoogleFonts.montserrat(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.5,
                                    color: Colors.white54,
                                  ),
                                ),
                                if (_questions.length > 1)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _removeQuestion(index),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildAuraTextField(
                              controller: question.controller,
                              label: 'QUESTION TEXT',
                              icon: Icons.help_outline,
                              goldColor: goldColor,
                            ),
                            const SizedBox(height: 24),
                            Text('OPTIONS', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1, color: Colors.white54)),
                            const SizedBox(height: 12),
                            ...question.options.asMap().entries.map((optEntry) {
                              final optIndex = optEntry.key;
                              final optController = optEntry.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildAuraTextField(
                                        controller: optController,
                                        label: 'OPTION ${optIndex + 1}',
                                        goldColor: goldColor,
                                      ),
                                    ),
                                    if (question.options.length > 2)
                                      IconButton(
                                        icon: const Icon(Icons.close, size: 20, color: Colors.white54),
                                        onPressed: () => _removeOption(index, optIndex),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                            TextButton.icon(
                              onPressed: () => _addOption(index),
                              icon: Icon(Icons.add, color: goldColor),
                              label: Text('Add Option', style: GoogleFonts.montserrat(color: goldColor, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                  
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: charcoal,
                      foregroundColor: goldColor,
                      side: BorderSide(color: goldColor.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _addQuestion,
                    icon: Icon(Icons.add_box, color: goldColor),
                    label: Text('Add Another Question', style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: _isLoading ? () {} : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : Text('Publish Mission', style: GoogleFonts.montserrat(fontSize: 16, fontWeight: FontWeight.bold)),
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

  Widget _buildAuraTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    required Color goldColor,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
        filled: true,
        fillColor: const Color(0xFF131313),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: goldColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        if (label == 'REWARD POINTS' && int.tryParse(value) == null) return 'Must be a number';
        return null;
      },
    );
  }
}
