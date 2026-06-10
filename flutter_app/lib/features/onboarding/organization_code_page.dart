import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/organization_service.dart';
import 'package:community_survey/core/theme/theme_controller.dart';
import 'package:community_survey/main.dart';
import 'package:community_survey/features/auth/register_page.dart';
import 'package:community_survey/core/network/api_client.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:community_survey/core/widgets/glowing_button.dart';
import 'package:google_fonts/google_fonts.dart';

class OrganizationCodePage extends ConsumerStatefulWidget {
  const OrganizationCodePage({super.key});

  @override
  ConsumerState<OrganizationCodePage> createState() => _OrganizationCodePageState();
}

class _OrganizationCodePageState extends ConsumerState<OrganizationCodePage> {
  final _codeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _errorMessage = 'Please enter a group code');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final config = await ref.read(organizationServiceProvider).fetchConfig(code);
      // Update global theme
      ref.read(themeProvider.notifier).updateBranding(config);
      
      if (mounted) {
        // Direct to Registration with group code
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RegisterPage(
              organizationCode: code,
              config: config,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = getApiErrorMessage(e);
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _skipOnboarding() {
    ref.read(onboardingCompletedProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Group Setup',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: TextButton(
              onPressed: _skipOnboarding,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                backgroundColor: Colors.white.withOpacity(0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.08)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
      body: PremiumMeshBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Glow logo block
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: PremiumTheme.glowPurple.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: PremiumTheme.glowPurple.withOpacity(0.15),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.group_work_outlined,
                      size: 56,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Join Your Organization',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter the unique code provided by your administrator to load custom branding and surveys.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: Colors.white60,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 36),
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _codeController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Organization Code',
                          hintText: 'e.g. T2EF1U',
                          errorText: _errorMessage,
                          prefixIcon: const Icon(Icons.qr_code, color: Colors.white60),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 20),
                      GlowingButton(
                        onPressed: _isLoading ? null : _submitCode,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Verify & Continue'),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
