import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PremiumTheme {
  // Brand color palette
  static const Color background = Color(0xFF080A0F);
  static const Color surface = Color(0xFF12141C);
  static const Color glassBorder = Color(0xFF22242D);
  static const Color glowPurple = Color(0xFF8B5CF6);
  static const Color glowMagenta = Color(0xFFEC4899);
  static const Color glowCyan = Color(0xFF06B6D4);
  static const Color glowGreen = Color(0xFF10B981);

  // Gradient presets
  static const LinearGradient purplePink = LinearGradient(
    colors: [glowPurple, glowMagenta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x0FFFFFFF),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData buildTheme({Color? primary, Color? secondary, Color? accent}) {
    final seed = primary ?? glowPurple;
    final sec = secondary ?? glowMagenta;
    final acc = accent ?? glowGreen;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
        primary: seed,
        secondary: sec,
        tertiary: acc,
        surface: surface,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        bodyLarge: GoogleFonts.inter(
          textStyle: ThemeData.dark().textTheme.bodyLarge?.copyWith(color: Colors.white),
        ),
        bodyMedium: GoogleFonts.inter(
          textStyle: ThemeData.dark().textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
        ),
        bodySmall: GoogleFonts.inter(
          textStyle: ThemeData.dark().textTheme.bodySmall?.copyWith(color: Colors.white60),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: seed.withOpacity(0.5), width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
        hintStyle: GoogleFonts.inter(color: Colors.white30, fontSize: 13),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: glassBorder),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: seed,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
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
    final primary = orgPrimary ?? PremiumTheme.glowPurple;
    final secondary = orgSecondary ?? PremiumTheme.glowMagenta;

    return Stack(
      children: [
        // Solid dark obsidian canvas
        Container(color: PremiumTheme.background),
        // Top Left glow spot
        Positioned(
          top: -120,
          left: -120,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.12),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        // Bottom Right glow spot
        Positioned(
          bottom: -150,
          right: -120,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondary.withOpacity(0.08),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 85, sigmaY: 85),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        // Middle ambient spot
        Positioned(
          top: 300,
          right: -80,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primary.withOpacity(0.06),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
