import 'package:Taskapp/common_widgets/round_gradient_button.dart';
import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class UpgradePlanScreen extends StatefulWidget {
  @override
  _UpgradePlanScreenState createState() => _UpgradePlanScreenState();
}

class _UpgradePlanScreenState extends State<UpgradePlanScreen> {
  int selectedPlanIndex = 0; // Index of the selected plan
  bool isCheck = false;
  List<Map<String, dynamic>> plans = [
    {
      'name': 'Premium Plan',
      'price': '\$19.99/month',
      'features': [
        'Feature 1',
        'Feature 2',
        'Feature 3',
        'Feature 4',
        'Feature 5',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"), // Replace with your background image
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Upgrade Now',
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor1
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20,),
            Text(
              'This features is not included in free Plans',
              style: TextStyle(
                fontSize: 12.0,
                color: AppColors.secondaryColor2
              ),
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
              child: Column(
                children: List.generate(plans.length, (index) {
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
                      plans[index]['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(plans[index]['price']),
                    trailing: IconButton(
                      icon: Icon(Icons.info_outline),
                      onPressed: () {
                        // Show plan details or perform any action
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(plans[index]['name']),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Features:'),
                                  SizedBox(height: 8.0),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: List.generate(plans[index]['features'].length, (index) {
                                      return Text('• ${plans[index]['features'][index]}');
                                    }),
                                  ),
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
                }),
              ),
            ),
            SizedBox(height: 50,),
            RoundGradientButton(title: "Upgrade", onPressed: (){
              upgradePlan();
            }),
            SizedBox(height: 20,),
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

  void upgradePlan() {
    // Implement the upgrade logic here
    print('Plan upgrade initiated!');
    // Make API call to upgrade the plan
  }
}

