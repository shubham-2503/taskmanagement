import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../utils/app_colors.dart';

class OTPVerificationScreen extends StatefulWidget {
  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _verifyOTP(String otp) {
    // Perform OTP verification logic here
    // You can replace this with your actual OTP verification implementation

    print('Verifying OTP: $otp');

    setState(() {
      _isLoading = true;
    });

    // Simulating OTP verification with a delay
    Future.delayed(Duration(seconds: 2), () {
      // Mocking success or failure based on the entered OTP
      if (otp == '123456') {
        // OTP verification successful
        Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
        print('OTP verification successful!');
      } else {
        // OTP verification failed
        print('OTP verification failed!');
      }

      setState(() {
        _isLoading = false;
      });
    });
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
          padding: EdgeInsets.only(top: 300,left: 20,right: 20),
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
              SizedBox(height: media.width*0.01),
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
                controller: _otpController,
                onChanged: (value) {
                  // Triggered when the OTP value changes
                  print('OTP: $value');
                },
                onCompleted: _verifyOTP,
              ),
              SizedBox(height: 16.0),
              RoundGradientButton(
                title: "Verify OTP",
                onPressed: () {
                  _isLoading ? null : () => _verifyOTP(_otpController.text);
                  Navigator.pushNamed(context, DashboardScreen.routeName);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
