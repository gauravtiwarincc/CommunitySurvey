import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:community_survey/models/admin_models.dart';
import 'package:community_survey/core/theme/premium_theme.dart';
import 'package:community_survey/models/user_context.dart';
import 'package:community_survey/features/context/context_provider.dart';

class ThemeState {
  final OrganizationConfig? config;
  final UserContext? activeContext;
  final bool isAdminMode;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  ThemeState({this.config, this.activeContext, this.isAdminMode = false, required this.lightTheme, required this.darkTheme});
}

class ThemeController extends StateNotifier<ThemeState> {
  ThemeController() : super(_createState(null, null, false));

  void updateBranding(OrganizationConfig? config) {
    state = _createState(config, state.activeContext, state.isAdminMode);
  }

  void updateContextBranding(UserContext? context) {
    state = _createState(state.config, context, state.isAdminMode);
  }
  
  void setAdminMode(bool isActive) {
    if (state.isAdminMode != isActive) {
      state = _createState(state.config, state.activeContext, isActive);
    }
  }

  static ThemeState _createState(OrganizationConfig? config, UserContext? context, bool isAdminMode) {
    Color primaryColor;
    Color secondaryColor;
    Color accentColor;

    if (isAdminMode) {
      // Midnight Blue & Gold for Admin Console
      primaryColor = const Color(0xFFD4AF37); // Rich Gold
      secondaryColor = const Color(0xFF131313); // Deep Charcoal
      accentColor = const Color(0xFFD4AF37); // Rich Gold
    } else if (context != null && context.contextType == 'GROUP') {
      // Group White-labeling
      primaryColor = _parseColor(context.primaryColor ?? config?.primaryColor, const Color(0xFF8B5CF6));
      secondaryColor = _parseColor(context.secondaryColor ?? config?.secondaryColor, const Color(0xFFEC4899));
      accentColor = _parseColor(config?.accentColor, const Color(0xFF10B981));
    } else {
      // Base/Profile Mode matching Figma
      primaryColor = const Color(0xFFD4AF37); // Rich Gold
      secondaryColor = const Color(0xFF131313); // Deep Charcoal
      accentColor = const Color(0xFFD4AF37); // Rich Gold
    }

    return ThemeState(
      config: config,
      activeContext: context,
      isAdminMode: isAdminMode,
      lightTheme: PremiumTheme.buildTheme(
        primary: primaryColor,
        secondary: secondaryColor,
        accent: accentColor,
        brightness: Brightness.dark, // Defaulting everything to dark mode for Cred-like sleekness
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
