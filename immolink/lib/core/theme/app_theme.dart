import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.white,
      brightness: Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: Colors.grey[900],
      brightness: Brightness.dark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}