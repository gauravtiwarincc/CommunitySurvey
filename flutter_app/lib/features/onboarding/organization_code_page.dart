import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/organization_service.dart';
import 'package:community_survey/core/theme/theme_controller.dart';
import 'package:community_survey/main.dart';
import 'package:community_survey/features/auth/register_page.dart';
import 'package:community_survey/core/network/api_client.dart';

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
      appBar: AppBar(
        title: const Text('Enter Group Code'),
        actions: [
          TextButton(
            onPressed: _skipOnboarding,
            child: const Text(
              'Skip',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.group_work_outlined,
              size: 72,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 24),
            const Text(
              'Join Your Organization',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Enter the unique code provided by your administrator to load custom branding and surveys.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Organization Code',
                hintText: 'e.g. T2EF1U',
                errorText: _errorMessage,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.qr_code),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
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
    );
  }
}
