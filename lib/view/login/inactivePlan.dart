import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:Taskapp/view/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../utils/app_colors.dart';

class InactivePlanScreen extends StatefulWidget {
  @override
  State<InactivePlanScreen> createState() => _InactivePlanScreenState();
}

class _InactivePlanScreenState extends State<InactivePlanScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Return true to prevent navigation back
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "You don't have any Active Plan",
                style: TextStyle(
                    fontSize: 18,
                    color: AppColors.secondaryColor2,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 10,),
              Text(
                "Please Contact Our Team",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryColor2,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}