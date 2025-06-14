import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:immolink/core/routes/app_router.dart';
import 'package:immolink/core/services/database_service.dart';
import 'package:immolink/core/theme/app_theme.dart';
import 'package:immolink/core/providers/theme_provider.dart';
import 'package:immolink/core/providers/locale_provider.dart';
import 'package:immolink/l10n_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.dotenv.load(fileName: "lib/config/immolink.env");
  
  try {
    await DatabaseService.instance.connect();
    print('Database connected successfully');
  } catch (e) {
    print('Database connection failed: $e');
    print('App will run in offline mode');
  }
  
  runApp(const ProviderScope(child: ImmoLink()));
}

class ImmoLink extends ConsumerWidget {
  const ImmoLink({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final currentLocale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    
    // Determine which theme mode to use
    ThemeMode appThemeMode;
    switch (themeMode) {
      case 'light':
        appThemeMode = ThemeMode.light;
        break;
      case 'dark':
        appThemeMode = ThemeMode.dark;
        break;
      case 'system':
        appThemeMode = ThemeMode.system;
        break;
      default:
        appThemeMode = ThemeMode.light;
    }
    
    return MaterialApp.router(
      routerConfig: router,
      title: 'ImmoLink',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: appThemeMode,
      locale: currentLocale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: L10n.all,
    );
  }
}

