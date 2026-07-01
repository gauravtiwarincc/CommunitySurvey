import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumTheme {
  static const Color glowGold = Color(0xFFC57D3E); // Warm Amber/Gold
  static const Color glowCharcoal = Color(0xFF393A48); // Muted Charcoal Blue
  static const Color glowOnyx = Color(0xFF0A0A0A);
  static const Color glowBronze = Color(0xFFCD7F32);

  static ThemeData buildAdminTheme() {
    const primaryGold = Color(0xFFC57D3E);
    const secondaryDark = Color(0xFF393A48);
    const accentYellow = Color(0xFFFACC15);
    const bgColor = Color(0xFF25201D); // Dark Sepia Charcoal
    const surfaceColor = Color(0xFF2D2622); // Slightly lighter for elevation
    final borderColor = Colors.white.withOpacity(0.04);

    return _buildCoreTheme(primaryGold, secondaryDark, accentYellow, bgColor, surfaceColor, borderColor);
  }

  static ThemeData buildTheme({
    Color? primary,
    Color? secondary,
    Color? accent,
    Brightness brightness = Brightness.dark,
  }) {
    final seed = primary ?? glowGold;
    final sec = secondary ?? glowCharcoal;
    final acc = accent ?? glowBronze;

    const bgColor = Color(0xFF25201D); // Dark Sepia Charcoal
    const surfaceColor = Color(0xFF2D2622); // Slightly lighter for elevation
    final borderColor = Colors.white.withOpacity(0.06);

    return _buildCoreTheme(seed, sec, acc, bgColor, surfaceColor, borderColor);
  }

  static ThemeData _buildCoreTheme(Color seed, Color sec, Color acc, Color bgColor, Color surfaceColor, Color borderColor) {
    const textHeadingColor = Colors.white;
    const textBodyColor = Colors.white70;
    const textSmallColor = Colors.white54;
    final hintColor = Colors.white30;
    
    final inputFill = const Color(0xFF111111); // Dark input
    final inputBorder = Colors.white.withOpacity(0.05);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark, // Force dark mode
      scaffoldBackgroundColor: bgColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
        primary: seed,
        secondary: sec,
        tertiary: acc,
        surface: surfaceColor,
        background: bgColor,
      ),
      textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.montserrat(textStyle: const TextStyle(color: textHeadingColor, fontWeight: FontWeight.bold)),
        titleMedium: GoogleFonts.montserrat(textStyle: const TextStyle(color: textHeadingColor, fontWeight: FontWeight.bold)),
        titleSmall: GoogleFonts.montserrat(textStyle: const TextStyle(color: textHeadingColor, fontWeight: FontWeight.w600)),
        bodyLarge: GoogleFonts.montserrat(textStyle: const TextStyle(color: textHeadingColor)),
        bodyMedium: GoogleFonts.montserrat(textStyle: const TextStyle(color: textBodyColor)),
        bodySmall: GoogleFonts.montserrat(textStyle: const TextStyle(color: textSmallColor)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textHeadingColor,
        ),
        iconTheme: const IconThemeData(color: textHeadingColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Aura Spec: 8px
          borderSide: BorderSide(color: inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: seed.withOpacity(0.5), width: 1.0),
        ),
        labelStyle: GoogleFonts.montserrat(color: textSmallColor, fontSize: 14),
        hintStyle: GoogleFonts.montserrat(color: hintColor, fontSize: 14),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0, 
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Aura Spec: 8px
          side: BorderSide(color: borderColor, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: seed.contrastTextColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 24,
      ),
    );
  }
}

class PremiumMeshBackground extends StatelessWidget {
  final Widget child;
  final Color? orgPrimary;
  final Color? orgSecondary;

  const PremiumMeshBackground({
    super.key,
    required this.child,
    this.orgPrimary,
    this.orgSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(bottom: false, child: child),
    );
  }
}

extension PremiumColorExtension on Color {
  Color get contrastTextColor => computeLuminance() > 0.5 ? Colors.black : Colors.white;
}
