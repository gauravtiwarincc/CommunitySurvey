import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/models/admin_models.dart';
import 'package:community_survey/core/theme/premium_theme.dart';

class ThemeState {
  final OrganizationConfig? config;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  ThemeState({this.config, required this.lightTheme, required this.darkTheme});
}

class ThemeController extends StateNotifier<ThemeState> {
  ThemeController() : super(_createState(null));

  void updateBranding(OrganizationConfig? config) {
    state = _createState(config);
  }

  static ThemeState _createState(OrganizationConfig? config) {
    final primaryColor = _parseColor(config?.primaryColor, const Color(0xFF8B5CF6));
    final secondaryColor = _parseColor(config?.secondaryColor, const Color(0xFFEC4899));
    final accentColor = _parseColor(config?.accentColor, const Color(0xFF10B981));

    return ThemeState(
      config: config,
      lightTheme: PremiumTheme.buildTheme(
        primary: primaryColor,
        secondary: secondaryColor,
        accent: accentColor,
        brightness: Brightness.dark,
      ),
      darkTheme: PremiumTheme.buildTheme(
        primary: primaryColor,
        secondary: secondaryColor,
        accent: accentColor,
        brightness: Brightness.dark,
      ),
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
