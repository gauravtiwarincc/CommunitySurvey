import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/services/auth_service.dart';
import 'package:community_survey/features/auth/auth_provider.dart';
import 'package:community_survey/core/network/api_client.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/core/widgets/glass_card.dart';
import 'package:community_survey/core/widgets/glowing_button.dart';
import 'package:google_fonts/google_fonts.dart';

class OTPVerificationPage extends ConsumerStatefulWidget {
  final String mobileNumber;
  final String transactionID;
  final String? debugOTP;
  final int expiresIn;

  const OTPVerificationPage({
    super.key,
    required this.mobileNumber,
    required this.transactionID,
    this.debugOTP,
    required this.expiresIn,
  });

  @override
  ConsumerState<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends ConsumerState<OTPVerificationPage> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  late int _secondsRemaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.expiresIn;
    _startTimer();
    // Auto fill debug OTP if present
    if (widget.debugOTP != null) {
      _otpController.text = widget.debugOTP!;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final otp = _otpController.text.trim();

    try {
      final session = await ref.read(authServiceProvider).verifyOTP(
        widget.mobileNumber,
        otp,
        widget.transactionID,
      );

      await ref.read(authProvider.notifier).setSession(session);
      // Fetch user profile and set
      final profile = await ref.read(authServiceProvider).getProfile();
      ref.read(authProvider.notifier).setProfile(profile);

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
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
                          color: PremiumTheme.glowCyan.withOpacity(0.08),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: PremiumTheme.glowCyan.withOpacity(0.12),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.security_outlined,
                          size: 56,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Enter Verification Code',
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
                      'Sent to ${widget.mobileNumber}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 36),
                    if (widget.debugOTP != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade900.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.shade900.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, color: Colors.amber.shade400, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '[Dev] Auto-filling OTP: ${widget.debugOTP}',
                              style: GoogleFonts.inter(
                                color: Colors.amber.shade300,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
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
                            controller: _otpController,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 22,
                              letterSpacing: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Verification Code',
                              hintText: '• • • • • •',
                              prefixIcon: Icon(Icons.lock_outline, color: Colors.white60),
                              hintStyle: TextStyle(letterSpacing: 10, color: Colors.white24),
                            ),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 6,
                            validator: (val) {
                              if (val == null || val.trim().length != 6) return 'Please enter 6-digit code';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.hourglass_empty,
                                size: 14,
                                color: _secondsRemaining > 0 ? PremiumTheme.glowCyan : Colors.white24,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _secondsRemaining > 0
                                    ? 'Resend in $_secondsRemaining seconds'
                                    : 'You can resend OTP now',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: _secondsRemaining > 0 ? Colors.white70 : Colors.white38,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          GlowingButton(
                            onPressed: _isLoading ? null : _verifyOTP,
                            glowColor: PremiumTheme.glowCyan,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Verify & Login'),
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
