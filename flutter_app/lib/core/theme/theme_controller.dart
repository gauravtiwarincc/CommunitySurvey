import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/models/admin_models.dart';

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
    final primaryColor = _parseColor(config?.primaryColor, const Color(0xFF2C0977));
    final secondaryColor = _parseColor(config?.secondaryColor, const Color(0xFFE6005E));
    final accentColor = _parseColor(config?.accentColor, const Color(0xFF00B300));

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: const Color(0xFFF8F9FA),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
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
