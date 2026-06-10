import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/auth_service.dart';
import 'package:community_survey/features/auth/otp_verification_page.dart';
import 'package:community_survey/core/network/api_client.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:community_survey/core/widgets/glowing_button.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _mobileController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _requestOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final mobile = _mobileController.text.trim();

    try {
      final response = await ref.read(authServiceProvider).requestOTP(mobile);
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              mobileNumber: mobile,
              transactionID: response['transactionID'] as String,
              debugOTP: response['otp'] as String?,
              expiresIn: response['expiresIn'] as int,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Verification',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: PremiumMeshBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    // Glow logo block
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: PremiumTheme.glowMagenta.withOpacity(0.08),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PremiumTheme.glowMagenta.withOpacity(0.12),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_circle_outlined,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Enter Mobile Number',
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
                      'We will send a 6-digit OTP to verify your account.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade900.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade900.withOpacity(0.3)),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _mobileController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number',
                              hintText: 'e.g. 9876543210',
                              prefixIcon: Icon(Icons.phone, color: Colors.white60),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) return 'Please enter mobile number';
                              if (val.trim().length < 10) return 'Please enter a valid mobile number';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          GlowingButton(
                            onPressed: _isLoading ? null : _requestOTP,
                            glowColor: PremiumTheme.glowMagenta,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Send OTP'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
