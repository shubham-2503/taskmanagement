import 'package:flutter/material.dart';

Future apiCircularDialog(BuildContext context) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: ()async{
            return false;
          },
          child: Dialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal:0.41,
            ),
            child: const SizedBox(
                height: 70,
                child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2.4,
                    ))),
          ),
        );
      });
}