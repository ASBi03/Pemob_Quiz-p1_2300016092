import 'package:flutter/material.dart';

/// Palet warna aplikasi (sengaja berbeda dari codelab: tanpa kuning/bintang).
class AppColors {
  AppColors._();

  static const Color seed = Color(0xFF7C4DFF); // violet
  static const Color gem = Color(0xFFD81B60); // pink magenta untuk ikon skor
  static const Color correct = Color(0xFF7EE0B5); // mint
  static const Color wrong = Color(0xFFFF8A80); // coral

  /// Pasangan warna gradient latar; berganti tiap pertanyaan.
  static const List<List<Color>> backgrounds = [
    [Color(0xFFE0C3FC), Color(0xFF8EC5FC)], // lavender -> biru langit
    [Color(0xFFFFD1DC), Color(0xFFFFA8C5)], // pink permen
    [Color(0xFFC1F2D0), Color(0xFF8FD3F4)], // mint -> aqua
    [Color(0xFFFFE0B2), Color(0xFFFFAB91)], // persik
  ];
}
