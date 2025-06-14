import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en'));

  void setLocale(String languageCode) {
    state = Locale(languageCode);
  }

  void updateLanguage(String language) {
    switch (language) {
      case 'en':
        state = const Locale('en');
        break;
      case 'de':
        state = const Locale('de');
        break;
      case 'fr':
        state = const Locale('fr');
        break;
      case 'it':
        state = const Locale('it');
        break;
      default:
        state = const Locale('en');
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

// Helper to get language name from code
String getLanguageName(String code) {
  switch (code) {
    case 'en':
      return 'English';
    case 'de':
      return 'German';
    case 'fr':
      return 'French';
    case 'it':
      return 'Italian';
    default:
      return 'English';
  }
}
