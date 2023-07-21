import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MailSentOverEmail extends StatefulWidget {
  const MailSentOverEmail({super.key});

  @override
  State<MailSentOverEmail> createState() => _MailSentOverEmailState();
}

class _MailSentOverEmailState extends State<MailSentOverEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/icons/message_icon.png",width: 10,height:40,color: AppColors.primaryColor2,),
            SizedBox(height: 10,),
            Text("Check your Mail",style: TextStyle(
              color: AppColors.blackColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,),
            SizedBox(height: 10,),
            Text("We have sent a password recover\n instructions to you email",style: TextStyle(
              color: AppColors.grayColor,
              fontSize: 12,
            ),
              textAlign: TextAlign.center,),
            SizedBox(height: 20,),
            SizedBox(
              height: 60,
              width: 20,
              child: Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: RoundGradientButton(
                  title: "Back To Login",
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen(),));
                  },
                ),
              ),
            ),
            SizedBox(height: 60,),
            Text("Didn't receive the email?Check your Spam filter,",style: TextStyle(
              color: AppColors.grayColor,
              fontSize: 12,
            ),
              textAlign: TextAlign.center,),
            InkWell(
              onTap: (){
                Navigator.pop(context);
              },
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                  ),
                  children: [
                    TextSpan(text: 'or '),
                    TextSpan(
                      text: 'try another email Address',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor2
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Open Mail App"),
          content: Text("No mail apps installed"),
          actions: <Widget>[
            ElevatedButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }
}
