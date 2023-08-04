import 'dart:convert';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/login/login_screen.dart';
import 'package:Taskapp/view/welcome/backToLogin/backToLogin.dart';
import 'package:Taskapp/view/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/app_colors.dart';

class ChoosePlan extends StatefulWidget {
  final String orgId;

  const ChoosePlan({super.key, required this.orgId});
  @override
  State<ChoosePlan> createState() => _ChoosePlanState();
}

class _ChoosePlanState extends State<ChoosePlan> {
  List<SubscriptionPlan> plans = [];

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

  void addSubscriptionToAccount(String orgId, String planId) async {
    try {
      final requestBody = {
        'org_id': widget.orgId,
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

      if (response.statusCode == 200) {
        // Subscription added successfully
        // Handle the success scenario
        print("Successfully added");
        Navigator.push(context, MaterialPageRoute(builder: (context)=>BackToLogin(),));
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

  @override
  void initState() {
    super.initState();
    fetchSubscriptionPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, BackToLogin.routeName);
                  },
                  child: Text(
                    "Skip Now",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.secondaryColor2,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bagroud.png"), // Replace with your background image
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              width: double.infinity,
              child: Column(
                children: [
                  Text(
                    "Choose your Plan",
                    style: TextStyle(
                      color: AppColors.secondaryColor2,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text(
                    "Buy Plan to get full access to avail",
                    style: TextStyle(
                      color: AppColors.primaryColor2,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    "more features",
                    style: TextStyle(
                      color: AppColors.primaryColor2,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 50,),
                  Padding(
                    padding: const EdgeInsets.only(left: 60,right: 60),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 70.0),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 15,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [
                                AppColors.primaryColor2.withOpacity(0.3),
                                AppColors.primaryColor1.withOpacity(0.3),
                              ]),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Center(
                                          child: Text(
                                            plan.name,
                                            style: TextStyle(
                                              color: AppColors.secondaryColor2,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          plan.price,
                                          style: TextStyle(
                                            color: AppColors.secondaryColor1,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: plan.getFeaturesList().map(
                                                (feature) => Text(
                                              '• $feature',
                                              style: TextStyle(
                                                color: AppColors.primaryColor2,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ).toList(),
                                        ),

                                        SizedBox(height: 15),
                                        SizedBox(
                                          height: 30,
                                          width: 110,
                                          child: RoundButton(title: "START Now", onPressed: () async{
                                            SharedPreferences prefs = await SharedPreferences.getInstance();
                                            final orgID = prefs.getString('id');

                                            if (orgID != null) {
                                              print("org_Id: $orgID");
                                              addSubscriptionToAccount(orgID, plan.id);
                                            } else {
                                              // Handle the case when the storedCompanyId is null
                                              // Display an error message or take appropriate action
                                              print("Company Id can't be null");
                                            }
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final String price;
  final String features;
  final int userCount;
  final int storageLimit;
  final String status;
  final String validity;

  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.features,
    required this.userCount,
    required this.storageLimit,
    required this.status,
    required this.validity,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'],
      features: json['features'],
      userCount: json['user_count'],
      storageLimit: json['storage_limit'],
      status: json['status'],
      validity: json['validity'],
    );
  }

  List<String> getFeaturesList() {
    return features.split(','); // Split the features string into a list of strings
  }
}
