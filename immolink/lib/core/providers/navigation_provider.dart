import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider für den aktuellen Navigation-Index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

// Provider für das Zurücksetzen des Navigation-Index basierend auf der aktuellen Route
final currentRouteProvider = StateProvider<String>((ref) => '/home');
