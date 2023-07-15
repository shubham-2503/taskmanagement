import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/welcome/welcome_screen.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_gradient_button.dart';
import '../../common_widgets/round_textfield.dart';

class CompleteProfileScreen extends StatefulWidget {
  static String routeName = "/CompleteProfileScreen";

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  static const int UserTypeIndividual = 0;
  static const int UserTypeAdmin = 1;
  int _selectedUserType = UserTypeIndividual;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"), // Replace with your background image
            fit: BoxFit.fill,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: 100,left: 20,right: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset("assets/images/pm-3.jpeg",width: media.width),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Let’s complete your profile",
                  style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w700
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "It will help us to know more about you!",
                  style: TextStyle(
                    color: AppColors.grayColor,
                    fontSize: 12,
                    fontFamily: "Poppins",
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: ToggleButtons(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            child: Text(
                              'Individual',
                              style: TextStyle(fontSize: 12,color: AppColors.secondaryColor2),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                            child: Text(
                              'Admin',
                              style: TextStyle(fontSize: 12,color: AppColors.secondaryColor2),
                            ),
                          ),
                        ],
                        isSelected: [
                          _selectedUserType == UserTypeIndividual,
                          _selectedUserType == UserTypeAdmin,
                        ],
                        onPressed: (int index) {
                          setState(() {
                            _selectedUserType = index;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                if (_selectedUserType == UserTypeIndividual)
                  Column(
                    children: [
                      RoundTextField(
                        hintText: "Email",
                        icon: "assets/icons/message_icon.png",
                        textInputType: TextInputType.emailAddress,
                      ),
                      SizedBox(height: 15),
                      RoundTextField(
                        hintText: "Phone Number",
                        icon: "assets/icons/pho.png",
                        textInputType: TextInputType.phone,
                      ),
                    ],
                  ),

                if (_selectedUserType ==UserTypeAdmin)
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        RoundTextField(
                          hintText: "Company Name",
                          icon: "assets/icons/name.png",
                          textInputType: TextInputType.text,
                        ),
                        SizedBox(height: 15),
                        RoundTextField(
                          hintText: "GST Number",
                          icon: "assets/icons/gst.jpeg",
                          textInputType: TextInputType.text,
                        ),
                        SizedBox(height: 15),
                        RoundTextField(
                          hintText: "Employees Count",
                          icon: "assets/icons/count.png",
                          textInputType: TextInputType.number,
                        ),
                        SizedBox(height: 15),
                        RoundTextField(
                          hintText: "Company Address",
                          icon: "assets/icons/add.png",
                          textInputType: TextInputType.text,
                        ),
                        SizedBox(height: 15),
                        RoundTextField(
                          hintText: "Phone Number",
                          icon: "assets/icons/pho.png",
                          textInputType: TextInputType.phone,
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 40,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: RoundGradientButton(
                        title: "< Previous",
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: RoundGradientButton(
                        title: "Next >",
                        onPressed: () {
                          Navigator.pushNamed(context, WelcomeScreen.routeName);
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
