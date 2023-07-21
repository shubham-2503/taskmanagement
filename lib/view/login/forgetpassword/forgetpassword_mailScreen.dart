
import 'dart:convert';
import 'package:Taskapp/view/login/forgetpassword/emailOvermail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common_widgets/round_gradient_button.dart';
import '../../../common_widgets/round_textfield.dart';

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

    final url = Uri.parse('http://43.205.97.189:8000/api/UserAuth/forgotPassword?email=$email');

    try {
      final response = await http.post(url, headers: {'accept': '*/*'});
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final message = responseData['message'];

        // Save the received data locally using shared preferences
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('userData', json.encode(responseData['data']));

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MailSentOverEmail(
              // userId: responseData['data']['userID'],
            ),
          ),
        );
      } else {
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
                    "Forget Password?",
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
                        const SizedBox(height: 20.0),
                        SizedBox(
                            height: 50,
                            width: 120,
                            child: RoundGradientButton(title: "Next", onPressed: sendResetInstructions))
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
