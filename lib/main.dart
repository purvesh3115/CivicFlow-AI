import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_routes.dart';
import 'navigation/route_generator.dart';
import 'providers/admin_provider.dart';
import 'providers/ai_assistant_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/complaint_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/services_provider.dart';
import 'services/firebase_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(dynamic message) async {
  // Background message handler entry-point
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for citizen-connect-57db0
  try {
    await FirebaseService().initialize();
  } catch (e) {
    debugPrint('Firebase init caught in main: $e');
  }

  // Set preferred portrait orientation & transparent status bar
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CitizenConnectApp());
}

class CitizenConnectApp extends StatelessWidget {
  const CitizenConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ComplaintProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ServicesProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AiAssistantProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'CitizenConnect',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
