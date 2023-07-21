import 'dart:convert';

import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/profile/company_registration.dart';
import 'package:Taskapp/view/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String email;
  final String password;

  const CompleteProfileScreen({required this.email, required this.password});


  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  static const int UserTypeIndividual = 0;
  static const int UserTypeAdmin = 1;
  int _selectedUserType = UserTypeIndividual;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  Future<void> _registerUser() async {
    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'name': _nameController.text,
      'mobile': _phoneController.text,
      'email': widget.email,
      'password': widget.password,
      'user_type': _selectedUserType == UserTypeIndividual
          ? '42e09976-029a-4fee-98f7-1a7417b7ef5f'
          : '945f7900-9f6e-4105-9a6e-672a2d74791a',
    };

    // Send the API request
    final Uri url =
    Uri.parse('http://43.205.97.189:8000/api/User/registration');
    final response = await http.post(
      url,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print("API Response: ${response.body}");
    print("StatusCode: ${response.statusCode}");

    // Handle the response
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);

      // Store the response locally using shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', jsonEncode(responseData));

      if (_selectedUserType == UserTypeIndividual) {
        Navigator.pushNamed(context, WelcomeScreen.routeName);
      } else if (_selectedUserType == UserTypeAdmin) {
        // Pass the necessary data to the next screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompanyRegistrationScreen(),
          ),
        );
      }
    } else {
      // Registration failed
      final responseData = jsonDecode(response.body);
      // Handle the error and display an error message to the user
    }
  }

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
          padding: EdgeInsets.only(top: 100,left: 20,right: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("assets/images/pm-3.jpeg",width: media.width),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Let’s complete your profile",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "It will help us to know more about you!",
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: ToggleButtons(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            child: Text(
                              'Individual',
                              style: TextStyle(fontSize: 12,color: AppColors.secondaryColor2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            child: Text(
                              'Admin',
                              style: TextStyle(fontSize: 12,color: AppColors.secondaryColor2),
                            ),
                          ),
                        ],
                        isSelected: [
                          _selectedUserType == UserTypeIndividual,
                          _selectedUserType == UserTypeAdmin,
                        ],
                        onPressed: (int index) {
                          setState(() {
                            _selectedUserType = index;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                  Column(
                    children: [
                      RoundTextField(
                        hintText: "Name",
                        icon: "assets/icons/name.png",
                        textInputType: TextInputType.text,
                        textEditingController: _nameController,
                      ),
                      SizedBox(height: 15),
                      RoundTextField(
                        hintText: "Email",
                        icon: "assets/icons/message_icon.png",
                        textInputType: TextInputType.emailAddress,
                        textEditingController: _emailController,
                      ),
                      SizedBox(height: 15),
                      RoundTextField(
                        hintText: "Phone Number",
                        icon: "assets/icons/pho.png",
                        textInputType: TextInputType.phone,
                        textEditingController: _phoneController,
                      ),
                    ],
                  ),
                SizedBox(height: 40,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: RoundGradientButton(
                        title: "< Previous",
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: RoundGradientButton(
                        title: "Next >",
                        onPressed: _registerUser,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
