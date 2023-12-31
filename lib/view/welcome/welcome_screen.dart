import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:Taskapp/view/login/login_screen.dart';
import 'package:Taskapp/view/subscription/chooseplan.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_gradient_button.dart';

class WelcomeScreen extends StatelessWidget {
  static String routeName = "/WelcomeScreen";

  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Spacer(),
              Image.asset("assets/images/stm.png",
                  width: media.width * 0.75, fit: BoxFit.fitWidth),
              SizedBox(height: media.width * 0.05),
              const Text(
                "You are all set now, let’s reach your\ngoals together with us",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              Spacer(),
              RoundGradientButton(
                title: "Go To Login",
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen(),));
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
