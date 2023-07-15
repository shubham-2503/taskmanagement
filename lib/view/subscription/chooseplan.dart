import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class ChoosePlan extends StatefulWidget {
  @override
  State<ChoosePlan> createState() => _ChoosePlanState();
}

class _ChoosePlanState extends State<ChoosePlan> {
  final List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      name: 'Free Plan',
      image: "assets/images/free.png",
      price: '\$0.00/month',
      features: [
        'Feature 1',
        'Feature 2',
        'Feature 3',
      ],
    ),
    SubscriptionPlan(
      name: 'Pro Plan',
      price: '\$19.99/month',
      image: "assets/images/paid.png",
      features: [
        'Feature 1',
        'Feature 2',
        'Feature 3',
        'Feature 4',
        'Feature 5',
      ],
    ),
    // Add more SubscriptionPlan objects for additional plans
  ];

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
                  onTap: (){
                    Navigator.pushNamed(context, DashboardScreen.routeName);
                  },
                  child: Text("Skip Now",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.secondaryColor2,
                      fontFamily: "Poppins",
                      fontWeight: FontWeight.bold,
                    ),),
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
                  Text("Choose your Plan",style: TextStyle(
                      color: AppColors.secondaryColor2,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),),
                  SizedBox(height: 10,),
                  Text("Buy Plan to get full access to avail",style: TextStyle(
                      color: AppColors.primaryColor2,
                      fontWeight: FontWeight.w500,
                      fontSize: 12
                  ),),
                  Text("more features",style: TextStyle(
                      color: AppColors.primaryColor2,
                      fontWeight: FontWeight.w500,
                      fontSize: 12
                  ),),
                  SizedBox(height: 20,),
                  Padding(
                    padding: const EdgeInsets.only(left: 100,right: 100),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: plans.length,
                      itemBuilder: (context, index) {
                        final plan = plans[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Container(
                            width: double.infinity,
                            // Adjust the width as desired
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 20,
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
                                        Text(
                                          plan.name,
                                          style: TextStyle(
                                            color: AppColors.secondaryColor2,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Image.asset(
                                          plan.image,
                                          width: 60,
                                          height: 60,
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
                                          children: plan.features
                                              .map(
                                                (feature) => Text(
                                              '• $feature',
                                              style: TextStyle(
                                                color: AppColors.primaryColor2,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          )
                                              .toList(),
                                        ),
                                        SizedBox(height: 15),
                                        SizedBox(
                                            height: 30,
                                            width: 110,
                                            child: RoundButton(title: "START Now", onPressed: (){}))
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
  final String name;
  final String price;
  final String image;
  final List<String> features;

  SubscriptionPlan({
    required this.name,
    required this.price,
    required this.features,
    required this.image,
  });
}
