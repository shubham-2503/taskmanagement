import 'package:Taskapp/Providers/project_provider.dart';
import 'package:Taskapp/routes.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:Taskapp/view/on_boarding/start_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Providers/session_provider.dart';
import 'Providers/taskProvider.dart';
import 'organization_proivider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message)async{
  await Firebase.initializeApp();
  print(message.notification!.title.toString());
  print(message.notification!.body.toString());
  print(message.data.toString());
}

class DoubleTapExitDetector {
  static DateTime? _lastTapTime;

  static Future<bool> onWillPop(BuildContext context) async {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(_lastTapTime ?? DateTime(0));

    if (_lastTapTime == null || difference > Duration(seconds: 2)) {
      // If the user hasn't tapped in the last 2 seconds, update the last tap time
      _lastTapTime = now;
      // Show a SnackBar to inform the user to tap again to exit
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false; // Prevent the app from exiting
    } else {
      return true; // Allow the app to exit
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<OrganizationProvider>(
            create: (context) => OrganizationProvider()),
        ChangeNotifierProvider<SessionProvider>(
            create: (context) => SessionProvider()),
        ChangeNotifierProvider<TaskProvider>(
            create: (context) => TaskProvider()),
        ChangeNotifierProvider<ProjectDataProvider>(
            create: (context) => ProjectDataProvider()),
      ],
      builder: (context, _) {
        return MaterialApp(
          title: 'Task Management',
          debugShowCheckedModeBanner: false,
          routes: routes,
          theme: ThemeData(
            primaryColor: AppColors.whiteColor,
            useMaterial3: true,
            fontFamily: "Poppins",
          ),
          home: FutureBuilder<void>(
            future: Provider.of<SessionProvider>(context, listen: false)
                .checkLoginStatus(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // Access the SessionProvider to get isLoggedIn status
                final sessionProvider =
                Provider.of<SessionProvider>(context);
                return WillPopScope(
                  onWillPop: () =>
                      DoubleTapExitDetector.onWillPop(context),
                  child: sessionProvider.isLoggedIn
                      ? DashboardScreen()
                      : StartScreen(),
                );
              }
              // Show a loading indicator while checking login status
              return CircularProgressIndicator();
            },
          ),
        );
      },
    );
  }
}



