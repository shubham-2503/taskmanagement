import 'dart:convert';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/subscription/chooseplan.dart';
import 'package:Taskapp/view/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class CompanyRegistrationScreen extends StatefulWidget {

  @override
  State<CompanyRegistrationScreen> createState() => _CompanyRegistrationScreenState();
}

class _CompanyRegistrationScreenState extends State<CompanyRegistrationScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _gstNumberController = TextEditingController();
  final TextEditingController _employeeCountController = TextEditingController();
  final TextEditingController _companyAddressController =
  TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  Future<void> _registerCompany() async {
    final Map<String, dynamic> requestBody = {
      'name': _companyNameController.text,
      'address': _companyAddressController.text,
      'description': 'string',
      'employee_count': int.parse(_employeeCountController.text),
      'tax_id': _gstNumberController.text,
      'user_id': '',
      'user_type': '',
      'role_id': '',
    };

    // Fetch the stored user data from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('userData');
    if (storedData != null) {
      final userData = jsonDecode(storedData);
      requestBody['user_id'] = userData['id'];
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
    _employeeCountController.dispose();
    _companyAddressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                Column(
                  children: [
                    RoundTextField(
                      textEditingController: _companyNameController,
                      hintText: "Company Name",
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
                      textEditingController: _phoneNumberController,
                      hintText: "Phone Number",
                      icon: "assets/icons/pho.png",
                      textInputType: TextInputType.phone,
                    ),
                  ],
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
