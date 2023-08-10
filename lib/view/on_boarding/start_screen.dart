import 'dart:async';

import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:Taskapp/view/signup/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';
import '../login/login_screen.dart';
import '../notification/widgets/notificationServices.dart';

class StartScreen extends StatefulWidget {
  static String routeName = "/StartScreen";

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  NotificationServices notificationServices = NotificationServices();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationServices.requestNotification();
    notificationServices.firebaseinit(context);
    notificationServices.isTokenRefresh();
    notificationServices.getDeviceToken().then((value) {
      print("Device token: ");
      print(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        // width: media.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/images/background.png"), // Replace with your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Center(child: Image.asset("assets/images/tm.png")),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: MaterialButton(
                  minWidth: double.maxFinite,
                  height: 50,
                  onPressed: () async {Navigator.pushNamed(context, LoginScreen.routeName);},
                  color: AppColors.primaryColor2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  textColor: AppColors.primaryColor1,
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                        color: AppColors.whiteColor),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
