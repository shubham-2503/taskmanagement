import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:Taskapp/view/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../utils/app_colors.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  Future<void> resendVerificationEmail() async {
    try {
      final String apiUrl = "http://43.205.97.189:8000/api/UserAuth/resendEmailVerificationLink?email=${widget.email}";
      final response = await http.post(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Show a dialog on success
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('Verification email sent successfully.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, LoginScreen.routeName, (route) => false);// Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        print("Verification email sent successfully.");
      } else {
        // Handle error responses here
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      // Handle exceptions here
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "This Account has not been verified yet ",
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.secondaryColor2,
                  fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 10,),
              Text(
                "Please Click Below to resend the Verification Link",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.primaryColor2,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: 200,
                  child: RoundGradientButton(title: "Resend Link", onPressed: (){
                    resendVerificationEmail();
                  }))
            ],
          ),
        ),
      );
  }
}