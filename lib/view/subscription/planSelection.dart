import 'dart:convert';

import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/subscription.dart';

class PlanSelectionScreen extends StatefulWidget {
  final String orgId;

  const PlanSelectionScreen({super.key, required this.orgId});
  @override
  _PlanSelectionScreenState createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  int selectedIndex = 0; // Keeps track of selected plan index
  int selectedPlanIndex = -1; // Keeps track of selected plan index
  List<dynamic> previousPlans = []; // To store fetched previous subscription data
  List<SubscriptionPlan> plans = [];

  @override
  void initState() {
    super.initState();
    fetchPreviousSubscriptions();
    fetchSubscriptionPlans();
  }

  void addSubscriptionToAccount(String planId, String orgId) async {
    try {
      final requestBody = {
        'org_id': orgId,
        'plan_id': planId,
      };
      final response = await http.post(
        Uri.parse('http://43.205.97.189:8000/api/Subscription/addSubscription?org_id=$orgId&plan_id=$planId'),
        headers: {
          'accept': '*/*',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print("Plan Id: $planId");
      print("Org Id: $orgId");

      print('API Response: ${response.body}');
      print('StatusCode: ${response.statusCode}');
      print("Decoded Data: $requestBody");

      if (response.statusCode == 200) {
        // Subscription added successfully
        // Handle the success scenario
        print("Successfully added");
      } else {
        print('API Response: ${response.body}');
        print("StatusCode: ${response.statusCode}");
        // Subscription failed to be added
        // Handle the error scenario
      }
    } catch (e) {
      print('Exception: $e');
      // Handle the exception and display an error message to the user
    }
  }

  Future<void> mapExistingSubscription(String subsId, String orgId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final url = 'http://43.205.97.189:8000/api/Subscription/mapExistingSubscription?subs_id=$subsId&org_id=$orgId';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final Map<String, dynamic> requestBody = {
        'subs_id': subsId,
        'org_id': orgId,
      };

      final response = await http.post(Uri.parse(url), headers: headers, body: jsonEncode(requestBody));

      print("Statuscode: ${response.statusCode}");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Thank You'),
              content: RichText(
                text: TextSpan(
                  text: 'Subscription mapping successful',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              actions: [
                InkWell(
                    onTap: (){
                      Navigator.pop(context,true);
                      Navigator.pop(context,true);
                    },
                    child: Text("OK",style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 20
                    ),))
              ],
            );
          },
        );
        print('Subscription mapping successful');
      } else {
        print('Error mapping subscription: ${response.statusCode}');
        // Handle error response
      }
    } catch (e) {
      print('Exception mapping subscription: $e');
      // Handle exception
    }
  }

  Future<void> fetchPreviousSubscriptions() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final url = 'http://43.205.97.189:8000/api/Subscription/previousSubscriptions';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        setState(() {
          previousPlans = jsonDecode(response.body);
        });
      } else {
        print('Error fetching previous subscriptions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching previous subscriptions: $e');
    }
  }

  Future<void> fetchSubscriptionPlans() async {
    try {

      final response = await http.get(
        Uri.parse('http://43.205.97.189:8000/api/Platform/getSubscriptionPlans'),
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
  Widget build(BuildContext context) {
    final orgId = widget.orgId;
    print("OrgId: $orgId");
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ToggleButtons(
                isSelected: [selectedIndex == 0, selectedIndex == 1],
                onPressed: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Previous Plans'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('New Plans'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              if (selectedIndex == 0 && previousPlans.isNotEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int index = 0; index < previousPlans.length; index++)
                      Column(
                        children: [
                          RadioListTile<int>(
                            subtitle: Text(previousPlans[index]['subs_name'] ?? 'N/A',style: TextStyle(color: AppColors.secondaryColor2,),),
                            title: Text("${previousPlans[index]['org_name'] ?? 'N/A'}",style: TextStyle(color: AppColors.primaryColor2,fontWeight: FontWeight.bold),),
                            value: index,
                            groupValue: selectedPlanIndex,
                            onChanged: (int? newIndex) {
                              setState(() {
                                selectedPlanIndex = newIndex!;
                              });
                            },
                            activeColor: AppColors.secondaryColor2, // Set the color of the selected radio button
                          ),
                          if (index < previousPlans.length - 1)
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20), // Add horizontal padding
                              child: Divider(
                                color: Colors.grey,
                                height: 1,
                                thickness: 1,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              if (selectedIndex == 1 && plans.isNotEmpty)
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (int index = 0; index < plans.length; index++)
                      Column(
                        children: [
                          RadioListTile<int>(
                            title: Text(
                              plans[index].name, // Change 'plan.name' to 'plans[index].name'
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor2
                              ),
                            ),
                            subtitle: Text(plans[index].price.toString(),style: TextStyle(color: AppColors.secondaryColor2,),), // Change 'plan.price' to 'plans[index].price'
                            value: index,
                            groupValue: selectedPlanIndex,
                            onChanged: (int? newIndex) {
                              setState(() {
                                selectedPlanIndex = newIndex!;
                              });
                            },
                            activeColor: AppColors.secondaryColor2,
                          ),
                          if (index < plans.length - 1) // Change 'previousPlans.length' to 'plans.length'
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(
                                color: Colors.grey,
                                height: 1,
                                thickness: 1,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              SizedBox(height: 20,),
              SizedBox(
                height: 50,
                width: 90,
                child: RoundButton(
                  title: "Proceed",
                  onPressed: () {
                    if (selectedPlanIndex != -1) {
                      if (selectedIndex == 0) {
                        final selectedSubscription = previousPlans[selectedPlanIndex];
                        final subsId = selectedSubscription['subs_id'];
                        final orgId = widget.orgId;
                        print("SubsId: $subsId, orgId= $orgId");

                        mapExistingSubscription(subsId, orgId); // Call the API function
                      } else if (selectedIndex == 1) {
                        final selectedPlan = plans[selectedPlanIndex];
                        final planId = selectedPlan.id; // Change to your plan ID key
                        final orgId = widget.orgId; // Change to your organization ID key

                        addSubscriptionToAccount(planId, orgId); // Call the API function
                      }
                    } else {
                      // Handle case where no plan is selected
                      print('No plan selected');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

