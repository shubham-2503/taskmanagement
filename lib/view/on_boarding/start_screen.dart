import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../utils/tokenManager.dart';
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
    notificationServices.getDeviceToken().then((value) async {
      print("Device token: $value");
      try {
        await TokenManager.saveToken(value!);
      } catch (e) {
        print("Error saving token: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
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
                  onPressed: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>const LoginScreen()));
                  },
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
