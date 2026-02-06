import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color primary = Color(0xFFFF7EB3); // Soft Pink
  static const Color primaryLight = Color(0xFFFFB7D5);
  static const Color secondary = Color(0xFF8B5CF6); // Gentle Purple
  static const Color accent = Color(0xFFFFD166); // Warm Yellow
  
  // Neutral Colors
  static const Color background = Color(0xFFFDFAFB);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF2D3142);
  static const Color textSecondary = Color(0xFF9EA3B0);
  
  // Semantic Colors
  static const Color cyclePeriod = Color(0xFFFF7EB3);
  static const Color cycleFollicular = Color(0xFF8B5CF6);
  static const Color cycleOvulation = Color(0xFFFFD166);
  static const Color cycleLuteal = Color(0xFF4ECDC4);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: primary,
      brightness: Brightness.light,
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.outfit(
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
      ),
    );
  }
}
