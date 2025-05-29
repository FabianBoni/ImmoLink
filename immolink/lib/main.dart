import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:immolink/core/routes/app_router.dart';
import 'package:immolink/core/services/database_service.dart';
import 'package:immolink/core/theme/app_theme.dart';
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
    
    return MaterialApp.router(
      routerConfig: router,
      title: 'ImmoLink',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
    );
  }
}
