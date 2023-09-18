import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../utils/app_colors.dart';

class DeleteOrganization extends StatefulWidget {
  final String orgId;
  final VoidCallback onDelete;
  DeleteOrganization({required this.orgId, required this.onDelete});

  @override
  State<DeleteOrganization> createState() => _DeleteOrganizationState();
}

class _DeleteOrganizationState extends State<DeleteOrganization> {

  Future<void> deleteOrganization(BuildContext context, String orgId) async {
    print("orgId: $orgId");

    String apiUrl = "http://43.205.97.189:8000/api/Organization/removeOrganization?org_id=$orgId";
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');

    final response = await http.delete(
      Uri.parse(apiUrl),
      headers: {
        'Authorization': 'Bearer $storedData', // Include your authentication token here
      },
    );

    print("Code: ${response.statusCode}");
    print("Body: ${response.body}");

    if (response.statusCode == 200) {
      Navigator.pop(context);
      String successMessage = "Organization deleted successfully";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    } else if (response.statusCode == 400) {
      Navigator.pop(context);
      String errorMessage = "Default organization cannot be deleted";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    } else {
      Navigator.pop(context);
      String errorMessage = "OOPs!!!Failed to delete the organization";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 2), // Adjust the duration as needed
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Center(
                child: Text(
                  "Delete Organization",
                  style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text(
                "Are you sure \nyou want to delete \nthis organization?",
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 40),
              Row(
                children: [
                  SizedBox(
                    height: 50,
                    width: 90,
                    child: RoundGradientButton(
                      title: "Yes",
                      onPressed: () {
                        print("${widget.orgId}");
                        deleteOrganization(context, widget.orgId);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    width: 90,
                    child: RoundGradientButton(
                      title: "No",
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
