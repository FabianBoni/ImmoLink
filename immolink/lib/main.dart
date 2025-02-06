import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/core/routes/app_router.dart';
import 'package:immolink/core/theme/app_theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ImmoLink(),
    ),
  );
}

class ImmoLink extends StatelessWidget {
  const ImmoLink({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImmoLink',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
    );
  }
}