import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'constant.dart';


noInternetDialoug(BuildContext context){
  if(connectivityNotifier.value){
    if(Platform.isAndroid){
      showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Network Error"),
            content: Text("Netwoek Error"),
            actions: <Widget>[
              TextButton(
                child:  Text("Okay"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }else{
      showDialog(context: context, builder: (context){
        return CupertinoAlertDialog(
          title: Text("Network Error"),
          content: Text("Network_error_text"),
          actions: [
            CupertinoDialogAction(child: Text("Okay"),onPressed: (){
              Navigator.pop(context);
            },),
          ],
        );
      });
    }
    return;
  }
}