import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Providers/session_provider.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../utils/app_colors.dart';
import '../../utils/tokenManager.dart';
import 'forgetpassword/verificationScreens.dart';
import 'inactivePlan.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String? email;
  final String? userId;
  final String? roleId;
  final String? userType;

  OTPVerificationScreen({
    required this.userId,
    required this.email,
    required this.roleId,
    required this.userType,
  });

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {


  Timer? _timer; // Declare the timer as nullable
  int _start = 60;
  bool _resendEnabled = false;
  String _timerText = "";
  String enteredOTP = "";

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _resendEnabled = true;
        });
        timer.cancel(); // Use timer instead of _timer to cancel
      } else {
        setState(() {
          _start--;
          _timerText = "$_start seconds";
        });
      }
    });
  }

  void resendOTP() async {
    if (_resendEnabled) {
      setState(() {
        _start = 60;
        _resendEnabled = false;
        _timerText = "$_start seconds";
      });
      startTimer();

      final url =
      Uri.parse('http://43.205.97.189:8000/api/UserAuth/resendOtp?user_id=${widget.userId ?? ''}');

      try {
        final response = await http.post(url, headers: {
          'accept': '*/*',
        });

        if (response.statusCode == 200) {
          // Resend OTP successful
          String message = "Resend Otp Successfully!";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: TextStyle(color: Colors.black54),
              ),
              backgroundColor: AppColors.primaryColor1,
            ),
          );
          print('Resend OTP successful!');
        } else if (response.statusCode == 404) {
          // User not found
          String message = "User not found. Please check your user ID.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: TextStyle(color: Colors.black54),
              ),
              backgroundColor: AppColors.primaryColor1,
            ),
          );
          print('User not found. Please check your user ID.');
        } else {
          // Resend OTP failed with an unexpected status code
          String message = "Resend OTP failed!";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: TextStyle(color: Colors.black54),
              ),
              backgroundColor: AppColors.primaryColor1,
            ),
          );
          print('Resend OTP failed with status: ${response.statusCode}');
        }
      } catch (error) {
        // Error occurred
        String message = "Oops! Request Failed Please Try again!!!!";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: TextStyle(color: Colors.black54),
            ),
            backgroundColor: AppColors.primaryColor1,
          ),
        );
        print('Error: $error');
      }
    }
  }

  Future<void> verifyOTP(BuildContext context, String? userId, String otp, String? email, String? roleId) async {
    print("Email: $email");
    print("UserId: $userId");
    print("RoleId: $roleId");
    // Declare the token variable
    String? token;

    try {
      // Retrieve the device token
      token = await TokenManager.getToken();
      if (token != null) {
        print("Retrieved token: $token");
      } else {
        print("Token not found.");
      }
    } catch (e) {
      print("Error retrieving token: $e");
    }

    print("Token found: $token");

    final url = Uri.parse(
        'http://43.205.97.189:8000/api/UserAuth/verifyOtp?user_id=${userId ?? ''}&otp=$otp&email=${email ?? ''}&role_id=${roleId ?? ''}&device_token=$token');

    try {
      final response = await http.post(url, headers: {
        'accept': '*/*',
      }, body: {
        'email': email ?? '', // Replace with the user's email
        'role_id': roleId ?? '', // Replace with the user's role ID
        'user_id': userId ?? '',
        'otp': otp,
        'device_token': token ?? '',
      });

      print("Api response: ${response.body}");
      print("code: ${response.statusCode}");
      if (response.statusCode == 200) {
        print('OTP verification response: ${response.body}');
        final responseData = jsonDecode(response.body);
        bool status = responseData['status'];
        if (status) {
          var jwtToken = responseData['data']['jwtToken'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwtToken', jwtToken);
          var orgDetail = responseData['data']['org_detail'];
          var orgId = orgDetail != null ? orgDetail['org_id'] : null;

          if (orgId != null) {
            await prefs.setString('org_id', orgId);
          }

          print("User_type = ${widget.userType}");
          bool subsStatus = orgDetail != null ? orgDetail['subs_status'] : false;
          bool isSubscribed = orgDetail != null ? orgDetail['is_subscribed'] : false;
          bool isVerified = responseData['data']['is_verified'];

          String message = "OTP verification successful!";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                message,
                style: TextStyle(color: Colors.black54),
              ),
              backgroundColor: AppColors.primaryColor1,
            ),
          );

          if (!isVerified) {
            navigateToVerificationScreen(context, email);
          } else if (orgDetail == null) {
            navigateToCompanyRegistrationScreen(context, userId, widget.userType, roleId);
          } else if (!isSubscribed) {
            navigateToChoosePlanScreen(context, orgId);
          } else if (!subsStatus) {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) => InactivePlanScreen(),
            ));
          } else {
            final sessionProvider = Provider.of<SessionProvider>(context, listen: false);
            sessionProvider.setLoggedIn(true);

            Navigator.pushNamedAndRemoveUntil(
              context,
              DashboardScreen.routeName,
                  (route) => false,
              arguments: orgId ?? "",
            );
          }
          print('OTP verification successful!');
        } else {
          String errorMessage = "OTP verification failed!";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: TextStyle(color: Colors.black54),
              ),
              backgroundColor: AppColors.primaryColor1,
            ),
          );
          print('OTP verification failed!');
        }
      } else if (response.statusCode == 401) {
        String errorMessage = "Please Enter Correct OTP";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: TextStyle(color: Colors.black54),
            ),
            backgroundColor: AppColors.primaryColor1,
          ),
        );
        print('Unauthorized: Please check the OTP entered.');
      } else {
        String errorMessage = "Request failed with status: ${response.statusCode}";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: TextStyle(color: Colors.black54),
            ),
            backgroundColor: AppColors.primaryColor1,
          ),
        );
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (error) {
      String errorMessage = "Error: $error";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: TextStyle(
              color: Colors.black54,
            ),
          ),
          backgroundColor: AppColors.primaryColor1,
        ),
      );
      print('Error: $error');
    }
  }

  void navigateToVerificationScreen(BuildContext context, String? email) {
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) => VerificationScreen(email: email??""),
    ));
  }

  void navigateToCompanyRegistrationScreen(BuildContext context, String? userId, String? userType, String? roleId) {
    // Implement your navigation logic here
    // For example:
    // Navigator.pushReplacement(context, MaterialPageRoute(
    //   builder: (context) => CompanyRegistrationScreen(userId: userId, userType: userType, roleId: roleId),
    // ));
  }

  void navigateToChoosePlanScreen(BuildContext context, String? orgId) {
    // Implement your navigation logic here
    // For example:
    // Navigator.pushReplacement(context, MaterialPageRoute(
    //   builder: (context) => ChoosePlan(orgId: orgId),
    // ));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
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
                  onChanged: (otp) {
                    setState(() {
                      enteredOTP = otp;
                    });
                  },
                  onCompleted: (value) {},
                  keyboardType: TextInputType.number,
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
                SizedBox(height: 20),
                RoundGradientButton(
                  title: "Verify OTP",
                  onPressed: () {
                    verifyOTP(
                      context,
                      widget.userId,
                      enteredOTP ?? "",
                      widget.email,
                      widget.roleId,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
