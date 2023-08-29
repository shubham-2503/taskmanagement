import 'dart:convert';
import 'package:Taskapp/common_widgets/snackbar.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/subscription/chooseplan.dart';
import 'package:Taskapp/view/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class CompanyRegistrationScreen extends StatefulWidget {
  final String userId;
  final String userType;
  final String roleId;

  CompanyRegistrationScreen({required this.userId, required this.userType, required this.roleId});

  @override
  State<CompanyRegistrationScreen> createState() => _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState extends State<CompanyRegistrationScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _gstNumberController = TextEditingController();
  final TextEditingController _employeeCountController = TextEditingController();
  final TextEditingController _companyAddressController =
  TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  List<Map<String, dynamic>> countryCodes = [
    {"name": "+91 (India)", "code": "+91"},
  ];
  String selectedCountryCode = "+91";

  Future<void> _registerCompany() async {
    final Map<String, dynamic> requestBody = {
      'name': _companyNameController.text,
      'address': _companyAddressController.text,
      'description': _descriptionController.text,
      'employee_count': int.parse(_employeeCountController.text),
      'tax_id': _gstNumberController.text,
      'user_id': widget.userId,
      'user_type': widget.userType,
      'role_id': widget.roleId,
    };

    // Fetch the stored user data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('userData');
    if (storedData != null) {
      final userData = jsonDecode(storedData);
      requestBody['user_type'] = userData['user_type'];
      requestBody['role_id'] = userData['role_id'];
    }

    final Uri url = Uri.parse('http://43.205.97.189:8000/api/Organization/organizationRegistration');
    final response = await http.post(
      url,
      headers: {
        'accept': '*/*',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print("Decode Body: ${jsonEncode(requestBody)}");
    print("API Error: ${response.body}");
    print("StatusCode: ${response.statusCode}");

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final companyId = responseData['id'];

      // Store the company_id locally using SharedPreferences
      await prefs.setString('id', companyId);
      print("CompanyID: $companyId");

      // Registration successful, navigate to the next screen
      Navigator.push(context, MaterialPageRoute(builder: (context)=>ChoosePlan(orgId: companyId),));
    } else {
      // Registration failed
      final responseData = jsonDecode(response.body);
      // Handle the error and display an error message to the user
      String errorMessage = "Network Error";
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _gstNumberController.dispose();
    _descriptionController.dispose();
    _employeeCountController.dispose();
    _companyAddressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.userId;
    print(userId);
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 100, left: 20, right: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("assets/images/pm-3.jpeg", width: media.width),
                SizedBox(height: 15),
                Text(
                  "Let’s complete your profile",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
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
                SizedBox(height: 40),
                RoundTextField(
                  textEditingController: _companyNameController,
                  hintText: "Company Name",
                  icon: "assets/icons/name.png",
                  textInputType: TextInputType.text,
                ),
                SizedBox(height: 15),
                RoundTextField(
                  textEditingController: _descriptionController,
                  hintText: "Company Description",
                  icon: "assets/icons/name.png",
                  textInputType: TextInputType.text,
                ),
                SizedBox(height: 15),
                RoundTextField(
                 textEditingController: _gstNumberController,
                  hintText: "GST Number",
                  icon: "assets/icons/gst.jpeg",
                  textInputType: TextInputType.text,
                ),
                SizedBox(height: 15),
                RoundTextField(
                  textEditingController: _employeeCountController,
                  hintText: "Employees Count",
                  icon: "assets/icons/count.png",
                  textInputType: TextInputType.number,
                ),
                SizedBox(height: 15),
                RoundTextField(
                 textEditingController: _companyAddressController,
                  hintText: "Company Address",
                  icon: "assets/icons/add.png",
                  textInputType: TextInputType.text,
                ),
                SizedBox(height: 15),
                RoundTextField(
                  hintText: "Phone Number",
                  textInputType: TextInputType.phone,
                  textEditingController: _phoneNumberController,
                  rightIcon: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: 8), // Add some spacing between the dropdown and phone number input
                        RoundTextField(
                          hintText: "Phone Number",
                          textEditingController: _phoneNumberController,
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
                                  controller: _phoneNumberController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                     DialogUtils.showSnackbar(context, "Please enter your phone number");
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
                  ),
                ),
                SizedBox(height: 40),
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
                        onPressed: () {
                          _registerCompany();
                        },
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
