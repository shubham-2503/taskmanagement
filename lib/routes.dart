import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:Taskapp/view/login/login_screen.dart';
import 'package:Taskapp/view/notification/notification_screen.dart';
import 'package:Taskapp/view/projects/projectDashScreen.dart';
import 'package:Taskapp/view/signup/signup_screen.dart';
import 'package:Taskapp/view/tasks/tasks.dart';
import 'package:Taskapp/view/welcome/welcome_screen.dart';
import 'package:flutter/cupertino.dart';

final Map<String, WidgetBuilder> routes = {
  LoginScreen.routeName: (context) => const LoginScreen(),
  SignupScreen.routeName: (context) => const SignupScreen(),
  WelcomeScreen.routeName: (context) => const WelcomeScreen(),
  DashboardScreen.routeName: (context) => const DashboardScreen(),
  NotificationScreen.routeName: (context) => const NotificationScreen(),
  ProjectDashScreen.routeName:(context)=>ProjectDashScreen(),
};