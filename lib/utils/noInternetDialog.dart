import 'dart:async';

import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NoInternetConnection extends StatefulWidget {
  const NoInternetConnection({super.key});

  @override
  State<NoInternetConnection> createState() => _NoInternetConnectionState();
}

class _NoInternetConnectionState extends State<NoInternetConnection> {
  var isDeviceConnected = false;
  bool isAlertSet = false;

  @override
  void initState() {
    super.initState();
    checkInternetConnection();
  }

  Future<void> checkInternetConnection() async {
    isDeviceConnected = await InternetConnectionChecker().hasConnection;
    if (isDeviceConnected) {
      Navigator.pop(context);
    } else {
      setState(() => isAlertSet = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isAlertSet) {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
          setState(() => isAlertSet = false);
          return false;
        }
        return true; // Allow the app to exit
      },
      child: Scaffold(
        body: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(child: Image.asset("assets/images/internet.png", width: 70, height: 50)),
              Center(child: Text("No Internet Connection")),
              Center(
                  child: Text("Please make sure you are connected\nwith an internet connection")),
              RoundGradientButton(title: "Retry", onPressed: () async {
                await checkInternetConnection();
              }),
            ],
          ),
        ),
      ),
    );
  }
}

