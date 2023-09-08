import 'dart:convert';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:http/http.dart' as http;
import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/subscription.dart';
import '../../utils/app_colors.dart';

class RenewPlanScreen extends StatefulWidget {
  @override
  _RenewPlanScreenState createState() => _RenewPlanScreenState();
}

class _RenewPlanScreenState extends State<RenewPlanScreen> {
  int selectedPlanIndex = 0; // Index of the selected plan
  bool isCheck = false;
  List<SubscriptionPlan> plans = []; // Define this list to hold the fetched plans
  int subscriptionDaysCount = 0;

  Future<void> fetchSubscriptionDaysCount() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        // If the user hasn't switched organizations, use the organization ID obtained during login time
        orgId = prefs.getString('org_id') ?? "";
      }

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      final response = await http.get(
        Uri.parse(
            'http://43.205.97.189:8000/api/Subscription/subscriptionDateCount?org_id=$orgId'),
        headers: {'accept': '*/*'},
      );

      print('API Response (Subscription Days Count): ${response.body}');
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final int count = int.parse(response.body); // Convert response body to int
        setState(() {
          subscriptionDaysCount = count;
        });
      } else {
        print('API Error: ${response.statusCode}');
        // Handle the error and display an error message to the user
      }
    } catch (e) {
      print('Exception: $e');
      // Handle the error and display an error message to the user
    }
  }

  Future<void> fetchSubscriptionPlans() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        // If the user hasn't switched organizations, use the organization ID obtained during login time
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }
      final response = await http.get(
        Uri.parse(
            'http://43.205.97.189:8000/api/Platform/getSubscriptionPlans?org_id=$orgId'),
        headers: {'accept': '*/*'},
      );

      print('API Response: ${response.body}');
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Decoded Data: $data');
        setState(() {
          plans = data.map((plan) => SubscriptionPlan.fromJson(plan)).toList();
        });
      } else {
        print('API Error: ${response.statusCode}');
        // Handle the error and display an error message to the user
      }
    } catch (e) {
      print('Exception: $e');
      // Handle the error and display an error message to the user
    }
  }

  @override
  void initState() {
    super.initState();
    fetchSubscriptionPlans(); // Fetch the subscription plans from the API
    fetchSubscriptionDaysCount();
  }

  @override
  Widget build(BuildContext context) {
    final premiumPlan =
        plans.where((plan) => plan.name == 'Premium Plan').toList();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Only $subscriptionDaysCount-days left', // Concatenate the count with the text
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryColor2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Find simple plans for comprehensive automations',
              style:
                  TextStyle(fontSize: 12.0, color: AppColors.secondaryColor1),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.0),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.secondaryColor2,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: premiumPlan
                        .isEmpty // Check if the premiumPlan list is empty
                    ? Center(
                        child: Text('No premium plans available'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: premiumPlan.length,
                        itemBuilder: (context, index) {
                          final plan = premiumPlan[index];
                          return ListTile(
                            leading: Radio(
                              value: index,
                              groupValue: selectedPlanIndex,
                              onChanged: (value) {
                                setState(() {
                                  selectedPlanIndex = value!;
                                });
                              },
                            ),
                            title: Text(
                              plan.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(plan.price.toString()),
                            trailing: IconButton(
                              icon: Icon(Icons.info_outline),
                              onPressed: () {
                                // Show plan details or perform any action
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(plan.name),
                                      content: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(plan.features),
                                          SizedBox(height: 8.0),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            RoundGradientButton(
                title: "Renew Plan",
                onPressed: () {
                  renewSubscription();
                }),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
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
                      "By continuing you accept our Privacy Policy and Terms of Use",
                      style: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 10,
                      )),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> renewSubscription() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        // If the user hasn't switched organizations, use the organization ID obtained during login time
        orgId = prefs.getString('org_id') ?? "";
      }

      final response = await http.post(
        Uri.parse(
            'http://43.205.97.189:8000/api/Subscription/renewSubscription?org_id=$orgId'),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer $storedData', // Add the authorization token
        },
      );

      print('API Response (Renew Subscription): ${response.body}');
      print("StatusCode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final bool success = responseData['status'] ?? false;

        if (success) {
          // Renewal successful
          final String message = responseData['message'] ?? "Subscription renewed successfully";
          _showPopupMessage(context, message);
        } else {
          final String errorMessage = responseData['message'] ?? "Subscription renewal failed";
          _showPopupMessage(context, errorMessage);
        }
      } else {
        print('API Error: ${response.statusCode}');
        // Handle the error and display an error message to the user
      }
    } catch (e) {
      print('Exception: $e');
      // Handle the error and display an error message to the user
    }
  }

  void _showPopupMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Subscription Renewal"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardScreen()));
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
