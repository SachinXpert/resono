import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(ColorScheme? dynamicColorScheme) {
    final scheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: GoogleFonts.outfitTextTheme(),
    );
  }

  static ThemeData darkTheme(ColorScheme? dynamicColorScheme) {
    final scheme = dynamicColorScheme ?? ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    );
  }
}
