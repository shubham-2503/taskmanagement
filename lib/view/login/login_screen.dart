import 'dart:convert';
import 'package:Taskapp/view/login/forgetpassword/forgetpassword_mailScreen.dart';
import 'package:Taskapp/view/login/phoneNumber.dart';
import 'package:Taskapp/view/login/true_caller_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/login/otpScreen.dart';
import 'package:Taskapp/view/signup/signup_screen.dart';

import '../../models/loginModel.dart';

class LoginScreen extends StatefulWidget {
  static String routeName = "/LoginScreen";
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TruecallerAuthServices truecallerAuthServices = TruecallerAuthServices();
  bool _isPasswordVisible = false;
  final GoogleSignIn _googleSignIn = GoogleSignIn();


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

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    return null;
  }

  void login(String email, String password, BuildContext context) async {
    try {
      final Uri loginUri = Uri.parse('http://43.205.97.189:8000/api/UserAuth/login');
      final Uri requestUri = loginUri.replace(queryParameters: {
        'email': email,
        'password': password,
      });

      Response response = await post(requestUri, headers: {'accept': '*/*'});

      print("Email: $email");
      print("Password: $password");
      print("API response: ${response.body}");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['status']) {
          var userId = data['data']['user_id'];
          var orgId = data['data']['org_id'];
          var roleId = data['data']['role_id'];
          var usertype = data['data']['user_type'];
          print('User ID: $userId');
          print('Org ID: $orgId');
          print('Role ID: $roleId');
          print('Login successful');
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', userId);
          await prefs.setString('roleId', roleId);
          await prefs.setString("usertype", usertype);

          String errorMessage = "OTP sent successfully";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage, style: TextStyle(color: Colors.black54)),
              backgroundColor: AppColors.primaryColor1,
            ),
          );

          // Navigator.push(context, MaterialPageRoute(builder: (context)=> OTPVerificationScreen(userId: userId, email: email, roleId: roleId, orgId: orgId)));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (c) => OTPVerificationScreen(userId: userId!, email: email, roleId: roleId!, userType: usertype,)), // Replace with your screen
          );
        } else {
          print('Login failed - Password is incorrect');
          String errorMessage = "Password is incorrect";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage, style: TextStyle(color: Colors.black54)),
              backgroundColor: AppColors.primaryColor1,
            ),
          );
        }
      } else if (response.statusCode == 401) {
        print('Password Incorrect');
        String errorMessage = "Password Incorrect. Please check your password.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: TextStyle(color: Colors.black54)),
            backgroundColor: AppColors.primaryColor1,
          ),
        );
      } else if (response.statusCode == 404) {
        var data = jsonDecode(response.body);
        if (data['message'] != null) {
          String errorMessage = data['message'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage, style: TextStyle(color: Colors.black54)),
              backgroundColor: AppColors.primaryColor1,
            ),
          );
        } else {
          print('Email not registered');
          String errorMessage = "Email not registered. Check your email.";
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage, style: TextStyle(color: Colors.black54)),
              backgroundColor: AppColors.primaryColor1,
            ),
          );
        }
      } else {
        print('Request failed.');
        String errorMessage = "Request failed.";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage, style: TextStyle(color: Colors.black54)),
            backgroundColor: AppColors.primaryColor1,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      Fluttertoast.showToast(
        msg: "Error: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  void loginWithTruecaller(String contact) async {
    try {
      Response response = await post(
        Uri.parse('http://43.205.97.189:8000/api/UserAuth/otpLessLogin'),
        body: {'contact': contact},
      );

      print("Contact: $contact");
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data['token']);
        print('Login successfully');

        // Perform actions after successful login with Truecaller
      } else {
        print('Login failed');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    print("Google-Sign_in Started");
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        print("Successfully logged in");
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Prepare the API request
        final String email = googleUser.email ?? ''; // Get the user's email
        final String url = 'http://43.205.97.189:8000/api/UserAuth/googleSignIn?email=$email';

        // Send the API request
        final response = await http.post(
          Uri.parse(url),
          headers: {'accept': '*/*'},
        );

        print("StatusCode: ${response.body}");

        // Handle the API response
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          final String jwtToken = responseData['data']['jwttOken'];

          // Handle the JWT token or perform any necessary actions
          print('JWT Token: $jwtToken');

          // Navigate to the DashboardScreen
          // Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen(orgId: ,)));
        } else {
          // Handle API error or sign-in failure
          print('API Error: ${response.body}');
        }
      } else {
        // Handle sign-in failure
        print("Error");
      }
    } catch (error) {
      // Handle sign-in error
      print('Sign-in Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 70),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bagroud.png"), // Replace with your background image
              fit: BoxFit.cover,
            ),
          ),
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: media.width*0.03,
                    ),
                    const Text(
                      "Hey there,",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: media.width*0.01),
                    const Text(
                      "Welcome Back",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 20,
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              SizedBox(height: media.width*0.05),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      RoundTextField(
                        hintText: "Email",
                        icon: "assets/icons/message_icon.png",
                        textInputType: TextInputType.emailAddress,
                        validator: validateEmail,
                        textEditingController: _emailController,
                      ),
                      SizedBox(height: media.width*0.05),
                      RoundTextField(
                        hintText: "Password",
                        icon: "assets/icons/lock_icon.png",
                        textInputType: TextInputType.text,
                        isObscureText: !_isPasswordVisible, // Password visibility is toggled based on the state variable
                        textEditingController: _passwordController,
                        validator: validatePassword,
                        rightIcon: TextButton(
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility on icon tap
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 20,
                            height: 20,
                            child: Image.asset(
                              _isPasswordVisible
                                  ? "assets/icons/show.png" // Show eye icon when password is visible
                                  : "assets/icons/hide_pwd_icon.png", // Show crossed eye icon when password is hidden
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                              color: AppColors.grayColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: media.width*0.03),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgetPasswordMailScreen(),));
                },
                child: const Text("Forgot your password?",
                    style: TextStyle(
                      color: AppColors.grayColor,
                      fontSize: 10,
                    )),
              ),
              SizedBox(height: 10,),
              RoundGradientButton(
                title: "Login",
                onPressed: (){
                  login(
                    _emailController.text.toString(),
                    _passwordController.text.toString(),
                    context,
                  );
                } // Provide an empty callback when the button is not clickable
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      height: 1,
                      color: AppColors.grayColor.withOpacity(0.5),
                    ),
                  ),
                  Text("  Or  ",
                      style: TextStyle(
                          color: AppColors.grayColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400)),
                  Expanded(
                    child: Container(
                      width: double.maxFinite,
                      height: 1,
                      color: AppColors.grayColor.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: signInWithGoogle,
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryColor1.withOpacity(0.5), width: 1, ),
                      ),
                      child: Image.asset("assets/icons/google_icon.png",width: 20,height: 20,),
                    ),
                  ),
                  SizedBox(width: 30,),
                  GestureDetector(
                    onTap: () async {
                      String contact = await truecallerAuthServices.startVerification(context);
                      loginWithTruecaller(contact);
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryColor1.withOpacity(0.5), width: 1, ),
                      ),
                      child: Image.asset("assets/images/true.png",width: 20,height: 20,),
                    ),
                  ),
                  SizedBox(width: 30,),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>PhoneNumber(),));
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryColor1.withOpacity(0.5), width: 1, ),
                      ),
                      child: Image.asset("assets/images/phone.webp",width: 20,height: 20,),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, SignupScreen.routeName);
                },
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      style: TextStyle(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w400),
                      children: [
                        const TextSpan(
                          text: "Don’t have an account yet? ",
                        ),
                        TextSpan(
                            text: "Register",
                            style: TextStyle(
                                color: AppColors.secondaryColor1,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    truecallerAuthServices.dispose();
    super.dispose();
  }
}
