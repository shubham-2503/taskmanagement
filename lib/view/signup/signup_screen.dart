import 'dart:convert';

import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/login/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../profile/complete_profile_screen.dart';

class SignupScreen extends StatefulWidget {
  static String routeName = "/SignupScreen";

  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String? email;
  String? password;
  String? confirmPassword = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isconfirmPasswordVisible = false;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email and Password';
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

    // Regular expression to check if the password contains at least one uppercase, one lowercase,
    // one special character, and one digit.
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$');
    if (!passwordRegex.hasMatch(value)) {
      return "Password should be a combination of uppercase, lowercase, special char, and numeric";
    }

    return null;
  }

  Future<void> checkIfEmailExists(String email) async {
    final response = await http.post(
      Uri.parse('http://43.205.97.189:8000/api/User/checkEmail?email=$email'),
      headers: {'accept': '*/*'},
    );

    if (response.statusCode == 200) {
      // Email does not exist, proceed with registration or display a success message
      print("Email is available for registration");
    } else if (response.statusCode == 400) {
      // Email already exists, display an error message to the user
      final responseData = json.decode(response.body);
      String Message = responseData['message'];
      _showDialog(Message);
    } else {
      // Handle API request failure or other errors
      print("Failed to check email: ${response.statusCode}");
      Fluttertoast.showToast(
        msg: "Failed to check email. Please try again later.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.primaryColor1,
        textColor: Colors.white,
      );
    }
  }

  void _showDialog(String Message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(Message,style: TextStyle(
          fontSize: 20
        ),),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())),
            child: Text("Login"),
          ),
        ],
      ),
    );
  }

  bool isCheck = false;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<void> signUpWithGoogle() async {
    try {
      CircularProgressIndicator();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        print("successfully account created");
        // Navigator.push(context, MaterialPageRoute(builder: (context)=>CompleteProfileScreen(),));

        // final String accessToken = googleAuth.accessToken;
        // final String idToken = googleAuth.idToken;
        //
        // // Make the API request to your backend
        // // Include the accessToken and idToken in the request headers or body
        // // Example using the http package:
        // final response = await http.post(
        //   Uri.parse('https://your-api-endpoint.com/register'),
        //   headers: {'Content-Type': 'application/json'},
        //   body: json.encode({
        //     'accessToken': accessToken,
        //     'idToken': idToken,
        //   }),
        // );
        //
        // if (response.statusCode == 200) {
        //   // User successfully registered
        //   // Perform any additional actions after sign-up
        //
        // } else {
        //   // Handle sign-up failure
        // }
      } else {
        // Handle sign-in failure
      }
    } catch (error) {
      // Handle sign-in or sign-up error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bagroud.png"), // Replace with your background image
              fit: BoxFit.cover,
            ),
          ),
          margin: const EdgeInsets.only(top: 10,),
          child: Padding(
            padding: EdgeInsets.only(top: 200,left: 20,right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Hey there,",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Create an Account",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                RoundTextField(
                  hintText: "Email",
                  icon: "assets/icons/message_icon.png",
                  textInputType: TextInputType.emailAddress,
                  onChanged: (value) {
                    setState(() {
                      email = value;
                    });

                    // Check if the email is valid before making the API request
                    String? emailError = validateEmail(email);
                    if (emailError == null) {
                      checkIfEmailExists(email!);
                    }
                  },
                  validator: validateEmail,
                  textEditingController: _emailController,
                ),
                SizedBox(
                  height: 15,
                ),
                RoundTextField(
                  hintText: "Password",
                  icon: "assets/icons/lock_icon.png",
                  textInputType: TextInputType.text,
                  isObscureText: !_isPasswordVisible, // Password visibility is toggled based on the state variable
                  textEditingController: _passwordController,
                  validator: validatePassword,
                  onChanged: (value) {
                    setState(() {
                      password = value; // Update the password variable
                    });
                  },
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
                SizedBox(
                  height: 15,
                ),
                RoundTextField(
                  hintText: "Confirm Password",
                  icon: "assets/icons/lock_icon.png",
                  textInputType: TextInputType.text,
                  isObscureText: !_isconfirmPasswordVisible,
                  onChanged: (value) {
                    setState(() {
                      confirmPassword = value;
                    });
                  },
                  validator: validatePassword,
                  rightIcon: TextButton(
                    onPressed: () {
                      setState(() {
                        _isconfirmPasswordVisible = !_isconfirmPasswordVisible; // Toggle password visibility on icon tap
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
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          onPressed: () {
                            setState(() {
                              isCheck = !isCheck;
                            });
                          },
                          icon: Icon(
                            isCheck
                                ? Icons.check_box_outline_blank_outlined
                                : Icons.check_box_outlined,
                            color: AppColors.grayColor,
                          )),
                      Expanded(
                        child: Text(
                            "By continuing you accept our Privacy Policy and\nTerm of Use",
                            style: TextStyle(
                              color: AppColors.grayColor,
                              fontSize: 10,
                            )),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                RoundGradientButton(
                  title: "Register",
                  onPressed: () {
                    String? emailError = validateEmail(email);
                    String? passwordError = validatePassword(password);

                    if (emailError != null || passwordError != null) {
                      // Show the validation error messages for email and password
                      String errorMessage = emailError ?? passwordError ?? "";
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage,style: TextStyle(
                              color: Colors.black54
                          ),),
                          backgroundColor: AppColors.primaryColor1,
                        ),
                      );
                    } else if (password != confirmPassword) {
                      // Show the validation error message for password mismatch
                      String errorMessage = "Passwords do not match";
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(errorMessage,style: TextStyle(
                            color: Colors.black54
                          ),),
                          backgroundColor: AppColors.primaryColor1,
                        ),
                      );
                    } else {
                      // Validation successful, proceed with navigation
                      print("Email: $email");
                      print("Password: $password");
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompleteProfileScreen(
                            email: _emailController.text,
                            password: _passwordController.text,
                          ),
                        ),
                      );
                    }
                  },
                ),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                      width: double.maxFinite,
                      height: 1,
                      color: AppColors.grayColor.withOpacity(0.5),
                    )),
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
                    )),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: signUpWithGoogle,
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
                      onTap: () {

                      },
                      child: Container(
                        width: 50,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primaryColor1.withOpacity(0.5), width: 1, ),
                        ),
                        child: Image.asset("assets/icons/facebook_icon.png",width: 20,height: 20,),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, LoginScreen.routeName);
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
                              text: "Already have an account? ",
                            ),
                            TextSpan(
                                text: "Login",
                                style: TextStyle(
                                    color: AppColors.secondaryColor1,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800)),
                          ]),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
