import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/models/admin_models.dart';
import 'package:community_survey/core/theme/premium_theme.dart';

class ThemeState {
  final OrganizationConfig? config;
  final ThemeData themeData;

  ThemeState({this.config, required this.themeData});
}

class ThemeController extends StateNotifier<ThemeState> {
  ThemeController() : super(ThemeState(themeData: _buildTheme(null)));

  void updateBranding(OrganizationConfig? config) {
    state = ThemeState(config: config, themeData: _buildTheme(config));
  }

  static ThemeData _buildTheme(OrganizationConfig? config) {
    final primaryColor = _parseColor(config?.primaryColor, const Color(0xFF8B5CF6));
    final secondaryColor = _parseColor(config?.secondaryColor, const Color(0xFFEC4899));
    final accentColor = _parseColor(config?.accentColor, const Color(0xFF10B981));

    return PremiumTheme.buildTheme(
      primary: primaryColor,
      secondary: secondaryColor,
      accent: accentColor,
    );
  }

  static Color _parseColor(String? hexString, Color fallback) {
    if (hexString == null || hexString.isEmpty) return fallback;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}

final themeProvider = StateNotifierProvider<ThemeController, ThemeState>((ref) {
  return ThemeController();
});
