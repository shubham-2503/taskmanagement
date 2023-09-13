import 'dart:convert';

import 'package:Taskapp/Providers/filterProvider.dart';
import 'package:Taskapp/Providers/project_provider.dart';
import 'package:Taskapp/routes.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:Taskapp/view/on_boarding/start_screen.dart';
import 'package:Taskapp/view/projects/myProjectFilterProvider.dart';
import 'package:Taskapp/view/tasks/widgets/mytasksFilter_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Providers/session_provider.dart';
import 'Providers/taskProvider.dart';
import 'organization_proivider.dart';
import 'package:http/http.dart' as http;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  if(!kDebugMode) {

    PlatformDispatcher.instance.onError = (error, stack) {
      // If you wish to record a "non-fatal" exception, please remove the "fatal" parameter
      print("Platform Error: ");
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    FlutterError.onError = (errorDetails) {
      print("Flutter Error: ${errorDetails.exception}");
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  }
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MaterialApp(
      home: const MyApp()
  ));
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

  Future<Map<String, dynamic>> checkForceUpgrade() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    final url = 'http://43.205.97.189:8000/api/AppSetting/getAppSetting';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $storedData', // Include your authentication token here
      },
    );
    print("Api response: ${response.body}");
    print("StatusCode: ${response.statusCode}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data from the API');
    }
  }

  Future<void> checkForForceUpgrade(BuildContext context) async {
    final apiResponse = await checkForceUpgrade();

    final isForceUpdate = apiResponse['is_force_update'];
    final appVersion = apiResponse['app_version'];
    final message = apiResponse['message'];
    final packageInfo = await PackageInfo.fromPlatform(); // Get the current app version
    final currentAppVersion = packageInfo.version;
    print("version: $currentAppVersion");

    if (isForceUpdate && appVersion != currentAppVersion) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("New Update Available"),
            content: Text(message),
            actions: [
              TextButton(
                child: Text("Update"),
                onPressed: () {
                  // Open the app store for the user to update the app.
                  // You can use packages like 'url_launcher' to achieve this.
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    checkForForceUpgrade(context);
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
        ChangeNotifierProvider<FilterProvider>(
            create: (context) =>FilterProvider()),
        ChangeNotifierProvider<TasksFilterNotifier>(
          create: (_) => TasksFilterNotifier(),),
        ChangeNotifierProvider<ProjectsFilterNotifier>(
          create: (_) => ProjectsFilterNotifier(),),
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



//
// import 'package:Taskapp/Providers/filterProvider.dart';
// import 'package:Taskapp/Providers/project_provider.dart';
// import 'package:Taskapp/routes.dart';
// import 'package:Taskapp/utils/app_colors.dart';
// import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
// import 'package:Taskapp/view/on_boarding/start_screen.dart';
// import 'package:Taskapp/view/projects/myProjectFilterProvider.dart';
// import 'package:Taskapp/view/tasks/widgets/mytasksFilter_provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'Providers/session_provider.dart';
// import 'Providers/taskProvider.dart';
// import 'organization_proivider.dart';
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//
//   if (!kDebugMode) {
//     FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
//
//     // Set custom keys
//     FirebaseCrashlytics.instance.setCustomKey('my_string_key', 'foo');
//     FirebaseCrashlytics.instance.setCustomKey('my_bool_key', true);
//     FirebaseCrashlytics.instance.setCustomKey('my_double_key', 1.0);
//     FirebaseCrashlytics.instance.setCustomKey('my_float_key', 1.0);
//     FirebaseCrashlytics.instance.setCustomKey('my_int_key', 1);
//
//     // Add custom logs
//     FirebaseCrashlytics.instance.log('message');
//
//     // Set a custom user identifier
//     FirebaseCrashlytics.instance.setUserIdentifier('user123456789');
//
//     // Example: Handle exceptions (replace with your own exception handling)
//     try {
//       throw Exception('This is a test exception');
//     } catch (e, stackTrace) {
//       FirebaseCrashlytics.instance.recordError(e, stackTrace);
//       // Handle your exception here
//     }
//   }
//
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//
//   runApp(const MyApp());
// }
//
// @pragma("vm:entry-point")
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print(message.notification!.title.toString());
//   print(message.notification!.body.toString());
//   print(message.data.toString());
// }
//
//
// class DoubleTapExitDetector {
//   static DateTime? _lastTapTime;
//
//   static Future<bool> onWillPop(BuildContext context) async {
//     final DateTime now = DateTime.now();
//     final Duration difference = now.difference(_lastTapTime ?? DateTime(0));
//
//     if (_lastTapTime == null || difference > Duration(seconds: 2)) {
//       _lastTapTime = now;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Press back again to exit'),
//           duration: Duration(seconds: 2),
//         ),
//       );
//       return false;
//     } else {
//       return true;
//     }
//   }
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
//
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         // Define your other providers here
//
//         // Example of adding a Firebase Crashlytics log
//         Provider<FirebaseCrashlytics>(
//           create: (_) => FirebaseCrashlytics.instance,
//         ),
//         ChangeNotifierProvider<OrganizationProvider>(
//           create: (context) => OrganizationProvider(),
//         ),
//         ChangeNotifierProvider<SessionProvider>(
//           create: (context) => SessionProvider(),
//         ),
//         ChangeNotifierProvider<TaskProvider>(
//           create: (context) => TaskProvider(),
//         ),
//         ChangeNotifierProvider<ProjectDataProvider>(
//           create: (context) => ProjectDataProvider(),
//         ),
//         ChangeNotifierProvider<FilterProvider>(
//           create: (context) => FilterProvider(),
//         ),
//         ChangeNotifierProvider<TasksFilterNotifier>(
//           create: (_) => TasksFilterNotifier(),
//         ),
//         ChangeNotifierProvider<ProjectsFilterNotifier>(
//           create: (_) => ProjectsFilterNotifier(),
//         ),
//       ],
//       builder: (context, _) {
//         return MaterialApp(
//           title: 'Task Management',
//           debugShowCheckedModeBanner: false,
//           // Define your routes, theme, and other configurations here
//           home: FutureBuilder<void>(
//             future: Provider.of<SessionProvider>(context, listen: false)
//                 .checkLoginStatus(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 final sessionProvider = Provider.of<SessionProvider>(context);
//                 return WillPopScope(
//                   onWillPop: () => DoubleTapExitDetector.onWillPop(context),
//                   child: sessionProvider.isLoggedIn
//                       ? DashboardScreen()
//                       : StartScreen(),
//                 );
//               }
//               return CircularProgressIndicator();
//             },
//           ),
//         );
//       },
//     );
//   }
// }
//




