import 'package:flutter/material.dart';

class BrandColors {
  // Primary Colorss
  static const Color royalBlue = Color(0xFFA7ABDE);
  static const Color slateGray = Color(0xFF8A8BA6);
  
  // Accent Colors
  static const Color successGreen = Color(0xFF8ABDA8);
  static const Color alertYellow = Color(0xFFE8A2A2);
  static const Color highlightBlue = Color(0xFFCDE1F8);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFBFF);
  static const Color lightSurface = Color(0xFFD5E3E8);
  static const Color textDark = Color(0xFF2C3650);
  static const Color textSecondary = Color(0xFF6C7270);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF5858CF), Color.fromARGB(255, 163, 164, 222)],
  );
}