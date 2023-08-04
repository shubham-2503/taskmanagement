import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_colors.dart';
import 'chooseplan.dart';

class RenewPlanScreen extends StatefulWidget {
  @override
  _RenewPlanScreenState createState() => _RenewPlanScreenState();
}

class _RenewPlanScreenState extends State<RenewPlanScreen> {
  int selectedPlanIndex = 0; // Index of the selected plan
  bool isCheck = false;
  List<SubscriptionPlan> plans = [];

  Future<void> fetchSubscriptionPlans() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final String? orgId = prefs.getString('org_id');

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
  }

  @override
  Widget build(BuildContext context) {
    final premiumPlan =
        plans.where((plan) => plan.name == 'Premium Plan').toList();
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                "assets/images/background.png"), // Replace with your background image
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '15-day free trial',
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor2),
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
                            subtitle: Text(plan.price),
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
                  renewPlan();
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

  void renewPlan() {
    // Implement the upgrade logic here
    print('Plan renew initiated!');
    // Make API call to upgrade the plan
  }
}
