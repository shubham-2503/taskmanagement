
import 'dart:convert';

import 'package:Taskapp/view/profile/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common_widgets/round_gradient_button.dart';
import '../../../common_widgets/round_textfield.dart';

class EditOrganization extends StatefulWidget {
  final String userId;
  final String orgId; // Organization ID to edit

  EditOrganization({required this.userId, required this.orgId});

  @override
  State<EditOrganization> createState() => _EditOrganizationState();
}

class _EditOrganizationState extends State<EditOrganization> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _gstNumberController = TextEditingController();
  final TextEditingController _employeeCountController = TextEditingController();
  final TextEditingController _companyAddressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch organization details and populate the fields
    fetchOrganizationDetails();
  }

  Future<void> fetchOrganizationDetails() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final url = Uri.parse('http://43.205.97.189:8000/api/Organization/getOrgDetail${widget.orgId}');


      final response = await http.get(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData is List && responseData.isNotEmpty) {
          final organization = responseData[0]; // Assuming there's only one organization in the response

          if (organization != null && organization is Map<String, dynamic>) {
            _companyNameController.text = organization['name'] ?? '';
            _gstNumberController.text = organization['tax_id'] ?? '';
            final employeeCount = organization['employee'];
            _employeeCountController.text = employeeCount != null ? employeeCount.toString() : '';
            _companyAddressController.text = organization['address'] ?? '';
            _descriptionController.text = organization['description'] ?? '';

            // Access and parse the subscription data
            final subscriptions = organization['subsciption'];
            if (subscriptions is List && subscriptions.isNotEmpty) {
              final firstSubscription = subscriptions[0]; // Access the first subscription object
              final subscriptionPlan = firstSubscription['subscription_plan'] ?? '';
              final startDate = firstSubscription['start_date'] ?? '';
              final endDate = firstSubscription['end_date'] ?? '';

              // You can handle the subscription data as needed
              print('Subscription Plan: $subscriptionPlan');
              print('Start Date: $startDate');
              print('End Date: $endDate');
            }
          } else {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: Text('Invalid organization data received.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("OK"),
                  ),
                ],
              ),
            );
            print('Invalid organization data received.');
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              content: Text('Empty organization data received.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("OK"),
                ),
              ],
            ),
          );
          print('Empty organization data received.');
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('Failed to fetch organization details. Status code: ${response.statusCode}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        print('Failed to fetch organization details. Status code: ${response.statusCode}');
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
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
      print('API Error: $e');
    }
  }

  Future<void> editOrganization() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final url = Uri.parse('http://43.205.97.189:8000/api/Organization/editOrganization?org_id=${widget.orgId}');

      final body = json.encode({
        'name': _companyNameController.text,
        'tax_id': _gstNumberController.text,
        'employee_count': int.parse(_employeeCountController.text),
        'address': _companyAddressController.text,
        'description': _descriptionController.text,
      });

      final response = await http.patch(
        url,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Organization edited Successfully"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context,true);
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        print('Organization edited successfully');
      } else if (response.statusCode == 401) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Unauthorized: Please check your authentication credentials"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        print('Unauthorized: Please check your authentication credentials');
      } else if (response.statusCode == 403) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text("Forbidden: You do not have permission to perform this action"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        print('Forbidden: You do not have permission to perform this action');
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Text('Failed to edit organization. Status code: ${response.statusCode}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        print('Failed to edit organization. Status code: ${response.statusCode}');
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
              Text(
                "Edit Organization",
                style: TextStyle(
                  color: Colors.blue, // Update the color as needed
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
            icon: "assets/images/title.jpeg",
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
                  title: "Save",
                  onPressed: () {
                    editOrganization();
                  },
                ),
              )
              // Rest of the widget remains the same
            ],
          ),
          ]
        ),
      ),
      ),
    );
  }
}
