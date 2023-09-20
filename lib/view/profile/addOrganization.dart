import 'dart:convert';

import 'package:Taskapp/view/subscription/planSelection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import 'package:http/http.dart' as http;

import '../../utils/app_colors.dart';

class AddOrganization extends StatefulWidget {
  final String userId;
  final Function() refreshCallback;
  AddOrganization({required this.userId, required this.refreshCallback});

  @override
  State<AddOrganization> createState() => _AddOrganizationState();
}

class _AddOrganizationState extends State<AddOrganization> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _gstNumberController = TextEditingController();
  final TextEditingController _employeeCountController = TextEditingController();
  final TextEditingController _companyAddressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> addOrganization() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final url = Uri.parse('http://43.205.97.189:8000/api/Organization/addOrganization');

      // Prepare the request body using the data from text fields
      final body = json.encode({
        'name': _companyNameController.text,
        'tax_id': _gstNumberController.text,
        'employee_count': int.parse(_employeeCountController.text),
        'address': _companyAddressController.text,
        'description': _descriptionController.text,
        // Add other properties as needed based on the API schema
      });

      final response = await http.post(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print("data: $body");

      print("CODE:${response.statusCode}");
      print("bODY: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final orgId = responseData['data']['org_id']; // Assuming 'org_id' is the key in the response
        print('Organization added successfully');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlanSelectionScreen(orgId: orgId, refreshCallback: widget.refreshCallback,),
          ),
        );
      } else if (response.statusCode == 401) {
        // Unauthorized
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Unauthorized: Please check your authentication credentials"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        print('Unauthorized: Please check your authentication credentials');
      } else if (response.statusCode == 403) {
        // Forbidden
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Forbidden: You do not have permission to perform this action"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        print('Forbidden: You do not have permission to perform this action');
      } else {
        // Other error codes
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('Failed to add organization. Status code: ${response.statusCode}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        print('Failed to add organization. Status code: ${response.statusCode}');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text('API Error: $e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
      print('API Error: $e');
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _gstNumberController.dispose();
    _employeeCountController.dispose();
    _companyAddressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: Padding(
          padding: EdgeInsets.only(top: 100, left: 20, right: 20),
          child: Column(
            children: [
              Text("Add New Organization",style: TextStyle(
                color: AppColors.secondaryColor2,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
              SizedBox(height: 40,),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a GST number.';
                  }

                  // Check for a valid GST format (15 characters)
                  final gstRegExp = RegExp(r"^\d{2}[A-Z]{5}\d{4}[A-Z]{1}\d[Z]{1}[A-Z\d]{1}$");
                  if (!gstRegExp.hasMatch(value)) {
                    return 'Please enter a valid GST number.';
                  }

                  return null;
                },
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
                textEditingController: _descriptionController,
                hintText: "Description",
                icon: "assets/icons/add.png",
                textInputType: TextInputType.text,
              ),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 140,
                    child: RoundGradientButton(
                      title: "< Cancel",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 140,
                    child: RoundGradientButton(
                      title: "Add >",
                      onPressed: () {
                        addOrganization();
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
