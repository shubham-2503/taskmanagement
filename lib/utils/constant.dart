import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

var scaffoldKey = GlobalKey<ScaffoldState>();
ValueNotifier<int> selectedIndex=ValueNotifier(0);
ValueNotifier<bool> connectivityNotifier = ValueNotifier(false);
ValueNotifier<int> projectCountNotifier = ValueNotifier<int>(0);

//This function is use for show platform specifc error
void showError(String message, BuildContext context, [String title = "Error"]) {
  // AppLocalizations? locatization = AppLocalizations.of(context);
  Platform.isAndroid
      ? Fluttertoast.showToast(msg: message)
      : showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          // title: Text(locatization?.error??""),
          content: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              isDefaultAction: true,
              child: const Text("Ok"),
            )
          ],
        );
      });
}