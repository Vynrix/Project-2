import 'package:flutter/material.dart';

class AppTheme {
  static const _bg = Color(0xFF070A12);
  static const _card = Color(0xFF11162A);
  static const _accent1 = Color(0xFF7C4DFF);
  static const _accent2 = Color(0xFF00B0FF);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: _bg,
      colorScheme: base.colorScheme.copyWith(
        primary: _accent1,
        secondary: _accent2,
        surface: _card,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        color: _card.withValues(alpha: 0.65),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _card.withValues(alpha: 0.55),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
