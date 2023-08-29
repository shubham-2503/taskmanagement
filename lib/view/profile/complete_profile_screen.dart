import 'dart:convert';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/login/login_screen.dart';
import 'package:Taskapp/view/welcome/backToLogin/backToLogin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  static const int UserTypeBusiness = 1;
  int _selectedUserType = UserTypeIndividual;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  List<Map<String, dynamic>> countryCodes = [
    {"name": "+91", "code": "+91"},
    // Add more country codes as needed
  ];
  String selectedCountryCode = "+91"; // Set a default country code if needed

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }


  Future<void> _registerUser() async {
    // Prepare the request body
    final Map<String, dynamic> requestBody = {
      'name': _nameController.text,
      'mobile': selectedCountryCode + _phoneController.text,
      'email': widget.email,
      'password': widget.password,
      'user_type': _selectedUserType == UserTypeIndividual
          ? '42e09976-029a-4fee-98f7-1a7417b7ef5f'
          : '945f7900-9f6e-4105-9a6e-672a2d74791a',
    };

    // Validate the fields
    if (_nameController.text.isEmpty ||
        selectedCountryCode.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      _showValidationErrorPopup("Please fill in all the required fields.");
      return;
    }

    // Send the API request to register the user
    final Uri url = Uri.parse('http://43.205.97.189:8000/api/User/registration');
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
      final userData = {
        'id': responseData['id'],
        'user_type': responseData['user_type'],
        'role_id': responseData['role_id'],
      };
      final userDataJson = jsonEncode(userData);
      await prefs.setString('userData', userDataJson);
      final userId = responseData['id'];
      // Save the userId locally using SharedPreferences
      await prefs.setString('userId', userId);
      requestBody['user_id'] = responseData['id'];
      requestBody['user_type'] = responseData['user_type'];
      requestBody['role_id'] = responseData['role_id'];

      if (_selectedUserType == UserTypeIndividual) {
        // Register the default organization for individual users
        // final orgId = await _registerDefaultOrganization(requestBody);
        // if (orgId != null) {
        //   // Registration successful, navigate to the next screen with orgId
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => BackToLogin()),
        //   );
        // } else {
        //   // Failed to create the default organization
        //   _showValidationErrorPopup("Failed to create default organization.");
        // }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BackToLogin(),
          ),
        );
      } else if (_selectedUserType == UserTypeBusiness) {
        // Pass the necessary data to the next screen
        final errorMessage = responseData['message'] ??
            "Registration successful.Proceed for further details"; // Customize the error message as needed
        _showValidationErrorPopup(errorMessage);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BackToLogin(),
          ),
        );
      }
    } else if (response.statusCode == 400) {
      // Registration failed due to an existing user with the same email
      final responseData = jsonDecode(response.body);
      final errorMessage = responseData
          .toString(); // Retrieve the error message from the response body
      _showDialog(errorMessage);
    } else {
      // Registration failed
      final responseData = jsonDecode(response.body);
      // Handle the error and display an error message to the user
      final errorMessage =
          responseData['message'] ?? "Registration failed"; // Customize the error message as needed
      _showValidationErrorPopup(errorMessage);
    }
  }

  Future<String?> _registerDefaultOrganization(Map<String, dynamic> userData) async {
    final Map<String, dynamic> requestBody = {
      'name': "default",
      'address': " ",
      'description': " ",
      'employee_count': 1,
      'tax_id': "",
      'user_id': userData['user_id'],
      'user_type': userData['user_type'],
      'role_id': userData['role_id'],
    };

    final Uri url = Uri.parse(
        'http://43.205.97.189:8000/api/Organization/organizationRegistration');
    final response = await http.post(
      url,
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print("API Error: ${response.body}");
    print("StatusCode: ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final companyId = responseData['id'];

      // Store the company_id locally using SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('id', companyId);
      print("CompanyID: $companyId");

      return companyId;
    } else {
      return null; // Failed to create default organization
    }
  }

  void _showValidationErrorPopup(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }
  void _showDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())),
            child: Text("Login"),
          ),
        ],
      ),
    );
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
                              'Business',
                              style: TextStyle(fontSize: 12,color: AppColors.secondaryColor2),
                            ),
                          ),
                        ],
                        isSelected: [
                          _selectedUserType == UserTypeIndividual,
                          _selectedUserType == UserTypeBusiness,
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
                        textEditingController: _phoneController,
                        rightIcon: Row(
                          children: [
                            DropdownButton<String>(
                              value: selectedCountryCode,
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCountryCode = newValue!;
                                });
                              },
                              items: countryCodes.map<DropdownMenuItem<String>>((Map<String, dynamic> country) {
                                return DropdownMenuItem<String>(
                                  value: country['code'],
                                  child: Text(
                                    country['code'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                              selectedItemBuilder: (BuildContext context) {
                                return countryCodes.map<Widget>((Map<String, dynamic> country) {
                                  return Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      country['code'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black, // Customize the selected item color
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            SizedBox(width: 8), // Add some spacing between the dropdown and phone number input
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                keyboardType: TextInputType.phone,
                                controller: _phoneController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please enter your phone number";
                                  }
                                  if (value.length != 10) {
                                    return "Phone number must contain 10 digits";
                                  }
                                  return null; // Return null if validation is successful
                                },
                                autovalidateMode: AutovalidateMode.onUserInteraction, // Trigger validation on user interaction
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(10), // Limit input length to 10 characters
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                              ),
                            ),
                          ],
                        ),
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
