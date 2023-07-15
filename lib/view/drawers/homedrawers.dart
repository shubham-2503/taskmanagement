import 'package:flutter/material.dart';

import '../../common_widgets/round_button.dart';
import '../../utils/app_colors.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryG),),
            child: Container(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    "assets/images/bg.png",
                    height: media.width * 0.4,
                    width: double.maxFinite,
                    fit: BoxFit.fitHeight,
                  ),
                  Padding(
                    padding:
                    EdgeInsets.symmetric(vertical: 25, horizontal: 25),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Hello, Admin",
                                    style: TextStyle(
                                        color: AppColors.whiteColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(width: 8,),
                                  Image.asset("assets/images/hi.png",width: 20,)
                                ],
                              ),
                              SizedBox(height: 10,),
                              Text(
                                "admin@example.com",
                                style: TextStyle(
                                  color:
                                  AppColors.whiteColor.withOpacity(0.7),
                                  fontSize: 12,
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: media.width * 0.05),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.home),
                  title: Text('Home'),
                  onTap: () {
                    // Handle the drawer item on press
                    Navigator.pop(context); // Close the drawer
                    // Navigate to the home screen or perform any desired action
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  onTap: () {
                    // Handle the drawer item on press
                    Navigator.pop(context); // Close the drawer
                    // Navigate to the settings screen or perform any desired action
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
