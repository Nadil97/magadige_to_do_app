import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Clean Light Theme Colors
  static const Color lightBg = Color(0xFFF4F6F9);
  static const Color cardBg = Color(0xFFFFFFFF);
  
  static const Color colorPrimary = Color(0xFF3F51B5); // Deep Indigo
  static const Color colorSecondary = Color(0xFF009688); // Teal
  
  static const Color colorTodo = Color(0xFF3B82F6); // Vibrant Blue
  static const Color colorInProgress = Color(0xFFF59E0B); // Vibrant Amber
  static const Color colorDone = Color(0xFF10B981); // Emerald Green
  
  static const Color textTodo = Color(0xFF2563EB);
  static const Color textInProgress = Color(0xFFD97706);
  static const Color textDone = Color(0xFF059669);

  static const Color priorityEasy = Color(0xFFDCEDC8); 
  static const Color priorityMedium = Color(0xFFFFF9C4); 
  static const Color priorityHard = Color(0xFFFFCDD2); 
  
  static const Color textEasy = Color(0xFF33691E);
  static const Color textMedium = Color(0xFFF57F17);
  static const Color textHard = Color(0xFFB71C1C);

  // Backward compatibility compatibility aliases (solid light versions)
  static const Color darkBg = lightBg;
  static const Color accentCyan = colorSecondary;
  static const Color accentTeal = colorSecondary;
  static const Color accentPurple = colorPrimary;
  static const Color accentPink = textHard;

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: colorPrimary,
      scaffoldBackgroundColor: lightBg,
      cardColor: cardBg,
      colorScheme: const ColorScheme.light(
        primary: colorPrimary,
        secondary: colorSecondary,
        surface: cardBg,
        error: textHard,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          color: Colors.black87,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          color: Colors.black54,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: colorPrimary, width: 1.5),
        ),
        labelStyle: GoogleFonts.inter(color: Colors.black54),
        hintStyle: GoogleFonts.inter(color: Colors.black38),
      ),
    );
  }

  // Keep darkTheme getter mapped to light theme for compatibility if requested
  static ThemeData get darkTheme => lightTheme;
}
