// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../models/login_otp_model.dart';
//
// class AppLocalData {
//   late SharedPreferences preferences;
//   bool isLoggedIn = false;
//   String appVersion = "";
//
//   // Constructor to initialize SharedPreferences and load data
//   AppLocalData() {
//     _initPreferences();
//     loadLoginData();
//     loadDashboardData();
//   }
//
//   void _initPreferences() async {
//     preferences = await SharedPreferences.getInstance();
//   }
//
//   // Save login data
//   Future<void> saveLoginData(LoginOtpModel loginData) async {
//     String loginDataJson = jsonEncode(loginData.toJson());
//     await preferences.setString("loginOtpResponse", loginDataJson);
//   }
//
//   // Load login data
//   void loadLoginData() {
//     var loginData = preferences.getString("loginOtpResponse");
//     if (loginData != null) {
//       loginOtpModel = LoginOtpModel.fromJson(jsonDecode(loginData));
//     }
//   }
//
//   // Save dashboard data
//   Future<void> saveDashboardData(HomeModel dashboardData) async {
//     String dashboardDataJson = jsonEncode(dashboardData.toJson());
//     await preferences.setString("dashboardData", dashboardDataJson);
//   }
//
//   // Load dashboard data
//   void loadDashboardData() {
//     var dashboardData = preferences.getString("dashboardData");
//     if (dashboardData != null) {
//
//     }
//   }
//
//   // Save login status
//   Future<void> saveLoginStatus(bool isLoggedIn) async {
//     await preferences.setBool("isLoggedIn", isLoggedIn);
//   }
//
//   // Load login status
//   void loadLoginStatus() {
//     isLoggedIn = preferences.getBool("isLoggedIn") ?? false;
//   }
// }
