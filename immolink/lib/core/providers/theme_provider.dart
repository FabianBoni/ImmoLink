import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Theme mode provider to track current theme setting
final themeModeProvider = StateProvider<String>((ref) => 'light');

// Helper to get the current ThemeMode enum
ThemeMode getThemeMode(String mode) {
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    case 'system':
      return ThemeMode.system;
    default:
      return ThemeMode.light;
  }
}
