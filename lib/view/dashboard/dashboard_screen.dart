import 'dart:io';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/activity/activity_screen.dart';
import 'package:Taskapp/view/profile/user_profile.dart';
import 'package:Taskapp/view/spaces/mySpaces.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../common_widgets/round_textfield.dart';
import '../home/home_screen.dart';

class DashboardScreen extends StatefulWidget {
  static String routeName = "/DashboardScreen";

  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectTab = 0;
  PersistentBottomSheetController? _bottomSheetController;
  int notificationCount = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const MySpaces(),
    const ActivityScreen(),
    const UserProfile(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize Firebase messaging and handle incoming messages
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      // Handle initial message if needed
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Handle foreground messages
      handleNotificationReceived();
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle when the app is opened from a notification
    });
  }

  void handleNotificationReceived() {
    setState(() {
      notificationCount++; // Increase the notification count
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: InkWell(
        onTap: () {},
        child: SizedBox(
          width: 70,
          height: 70,
          child: Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: AppColors.primaryG),
                borderRadius: BorderRadius.circular(35),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2)
                ]),
            child: InkWell(
              onTap: (){
                print("search icon tapped");
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.primaryColor1,
                    title: RoundTextField(
                          hintText: "Search",
                          icon: "assets/images/search_icon.png",
                          textInputType: TextInputType.text),
                  ),
                );
              },
              child: const Icon(Icons.search_sharp,
                  color: AppColors.primaryColor1, size: 32),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: selectTab,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomAppBar(
        height: Platform.isIOS ? 70 : 65,
        color: Colors.transparent,
        padding: const EdgeInsets.all(0),
        child: Container(
          height: Platform.isIOS ? 70 : 65,
          decoration: const BoxDecoration(
              color: AppColors.whiteColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black12,
                    blurRadius: 2,
                    offset: Offset(0, -2))
              ]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TabButton(
                title: "Home",
                  icon: "assets/images/home.png",
                  selectIcon: "assets/images/home_select.png",
                  isActive: selectTab == 0,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 0;
                      });
                    }
                  }),
              TabButton(
                  title: "My Spaces",
                  icon: "assets/images/folders.png",
                  selectIcon: "assets/images/folders.png",
                  isActive: selectTab == 1,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 1;
                      });
                    }
                  }),
              const SizedBox(width: 40),
              TabButton(
                  title: "Activity",
                  icon: "assets/icons/activity_icon.png",
                  selectIcon: "assets/icons/activity_select_icon.png",
                  isActive: selectTab == 2,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 2;
                      });
                    }
                  }),
              TabButton(
                title: "User Profile",
                  icon: "assets/images/account.png",
                  selectIcon: "assets/images/account_select.png",
                  isActive: selectTab == 3,
                  onTap: () {
                    if (mounted) {
                      setState(() {
                        selectTab = 3;
                      });
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final String title;
  final String icon;
  final String selectIcon;
  final bool isActive;
  final VoidCallback onTap;

  const TabButton(
      {Key? key,
        required this.title,
      required this.icon,
      required this.selectIcon,
      required this.isActive,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isActive ? selectIcon : icon,
              width: 25,
              height: 25,
              fit: BoxFit.fitWidth,
            ),
            SizedBox(height: isActive ? 8 : 12),
            Text(
              title, // Add the title here
              style: TextStyle(
                fontSize: 12, // Adjust the font size as per your requirement
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.secondaryColor2 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


