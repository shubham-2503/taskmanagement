import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:Taskapp/view/login/login_screen.dart';
import 'package:Taskapp/view/subscription/chooseplan.dart';
import 'package:flutter/material.dart';
import '../../../common_widgets/round_gradient_button.dart';

class BackToLogin extends StatelessWidget {
  static String routeName = "/WelcomeScreen";

  const BackToLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"), // Replace with your background image
            fit: BoxFit.fill,
          ),
        ),
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
                "Please check your email for Proceed Further",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600),
              ),
              Spacer(),
              RoundGradientButton(
                title: "Back to Login",
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
