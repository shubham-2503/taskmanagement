import 'package:Taskapp/view/activity_tracker/activity_tracker_screen.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:Taskapp/view/finish_work/finish_workout_screen.dart';
import 'package:Taskapp/view/login/login_screen.dart';
import 'package:Taskapp/view/notification/notification_screen.dart';
import 'package:Taskapp/view/on_boarding/start_screen.dart';
import 'package:Taskapp/view/profile/complete_profile_screen.dart';
import 'package:Taskapp/view/signup/signup_screen.dart';
import 'package:Taskapp/view/tasks/tasks.dart';
import 'package:Taskapp/view/welcome/welcome_screen.dart';
import 'package:flutter/cupertino.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (context) => const LoginScreen(),
  StartScreen.routeName: (context) => const StartScreen(),
  SignupScreen.routeName: (context) => const SignupScreen(),
  WelcomeScreen.routeName: (context) => const WelcomeScreen(),
  DashboardScreen.routeName: (context) => const DashboardScreen(),
  FinishWorkScreen.routeName: (context) => const FinishWorkScreen(),
  NotificationScreen.routeName: (context) => const NotificationScreen(),
  ActivityTrackerScreen.routeName: (context) => const ActivityTrackerScreen(),
};