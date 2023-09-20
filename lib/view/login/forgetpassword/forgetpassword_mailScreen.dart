
import 'dart:convert';
import 'package:Taskapp/view/login/forgetpassword/emailOvermail.dart';
import 'package:Taskapp/view/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common_widgets/round_gradient_button.dart';
import '../../../common_widgets/round_textfield.dart';
import '../../../utils/app_colors.dart';

class ForgetPasswordMailScreen extends StatefulWidget {
  const ForgetPasswordMailScreen({Key? key}) : super(key: key);

  @override
  State<ForgetPasswordMailScreen> createState() =>
      _ForgetPasswordMailScreenState();
}

class _ForgetPasswordMailScreenState extends State<ForgetPasswordMailScreen> {
  final TextEditingController _emailController = TextEditingController();

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }

    // Email regex pattern
    final emailRegex = RegExp(
        r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+(\.[a-zA-Z]+)?$');

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  Future<void> sendResetInstructions() async {
    final email = _emailController.text;

    if (email.isEmpty) {
      String errorMessage = "Please enter email address";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage, style: TextStyle(color: Colors.black54)),
          backgroundColor: AppColors.primaryColor1,
        ),
      );
      return; // Exit the function if email is empty
    }

    final url = Uri.parse('http://43.205.97.189:8000/api/UserAuth/forgotPassword?email=$email');

    try {
      final response = await http.post(url, headers: {'accept': '*/*'});
      print("Status Code: ${response.statusCode}");
      print("Api Response: ${response.body}");

      final responseData = json.decode(response.body);
      final message = responseData['message'];

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userData', json.encode(responseData['data']));
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: Text('Resend Password link has been sent to your registered email address'),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else if (response.statusCode == 400 && message == 'User Not registered') {
        // Handle case where user is not registered
        String errorMessage = "User is not registered. Please check your email address.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: TextStyle(color: Colors.black54)),
            backgroundColor: AppColors.primaryColor1,
          ),
        );
      } else {
        // Handle other error cases
        final errorMessage = 'An error occurred. Please try again later.';
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      final errorMessage = 'An error occurred. Please try again later.';
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 200),
            child: Container(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "No worries, we'll send you reset instructions",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Form(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RoundTextField(
                            hintText: "Email",
                            icon: "assets/icons/message_icon.png",
                            textInputType: TextInputType.emailAddress,
                            validator: validateEmail,
                            textEditingController: _emailController,
                          ),
                        ),
                        const SizedBox(height: 30.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            SizedBox(
                                height: 50,
                                width: 120,
                                child: RoundGradientButton(title: "Submit", onPressed: sendResetInstructions)),
                            SizedBox(
                                height: 50,
                                width: 120,
                                child: RoundGradientButton(title: "Back", onPressed: (){
                                  Navigator.of(context).popAndPushNamed('LoginScreen');
                                })),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
