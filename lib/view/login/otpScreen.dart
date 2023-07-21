import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../utils/app_colors.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String userId;

  OTPVerificationScreen({required this.userId});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  late Timer _timer;
  int _start = 60;
  bool _resendEnabled = false;
  String _timerText = '';

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _resendEnabled = true;
        });
        _timer.cancel();
      } else {
        setState(() {
          _start--;
          _timerText = '$_start seconds';
        });
      }
    });
  }

  void resendOTP() async {
    if (_resendEnabled) {
      setState(() {
        _start = 60;
        _resendEnabled = false;
        _timerText = '$_start seconds';
      });
      startTimer();

      final url = Uri.parse('http://43.205.97.189:8000/api/UserAuth/resendOtp?user_id=${widget.userId}');

      try {
        final response = await http.post(url, headers: {
          'accept': '*/*',
        });

        if (response.statusCode == 200) {
          // Resend OTP successful
          print('Resend OTP successful!');
        } else {
          // Resend OTP failed
          print('Resend OTP failed with status: ${response.statusCode}');
        }
      } catch (error) {
        // Error occurred
        print('Error: $error');
      }
    }
  }

  Future<void> verifyOTP(BuildContext context, String userId, String otp) async {
    final url = Uri.parse(
        'http://43.205.97.189:8000/api/UserAuth/verifyOtp?user_id=$userId&otp=$otp');

    try {
      final response = await http.post(url, headers: {
        'accept': '*/*',
      });

      if (response.statusCode == 200) {
        print('OTP verification response: ${response.body}');
        final responseData = jsonDecode(response.body);
        bool status = responseData['status'];

        if (status) {
          // OTP verification successful
          Navigator.pushReplacementNamed(context, DashboardScreen.routeName);
          print('OTP verification successful!');
        } else {
          // OTP verification failed
          print('OTP verification failed!');
        }
      } else {
        // Request failed
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      // Error occurred
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bagroud.png"), // Replace with your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 300, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text(
                  "Verify your Email,",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: media.width * 0.01),
                const Text(
                  "Please enter your OTP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.0),
                PinCodeTextField(
                  appContext: context,
                  length: 6, // Length of the OTP code
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    activeFillColor: AppColors.secondaryColor2,
                    selectedFillColor: Colors.transparent,
                    inactiveFillColor: Colors.transparent,
                    activeColor: AppColors.secondaryColor2,
                    selectedColor: Colors.grey,
                    inactiveColor: Colors.grey,
                    borderWidth: 2,
                    // Set border color to black
                  ),
                  animationDuration: Duration(milliseconds: 300),
                  onChanged: null,
                  onCompleted: (value) {
                    verifyOTP(context, widget.userId, value);
                  },
                ),
                SizedBox(height: 16.0),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(text: "Didn't receive email?  "),
                      TextSpan(
                        text: _resendEnabled ? 'Resend code' : _timerText,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _resendEnabled
                              ? AppColors.primaryColor2
                              : AppColors.grayColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = resendOTP,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20,),
                RoundGradientButton(
                  title: "Verify OTP",
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
