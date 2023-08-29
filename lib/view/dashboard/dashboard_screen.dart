import 'dart:io';
import 'package:Taskapp/Providers/session_provider.dart';
import 'package:Taskapp/user.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/profile/user_profile.dart';
import 'package:Taskapp/view/reports/reports.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../home/home_screen.dart';

class DashboardScreen extends StatefulWidget {
  static String routeName = "/DashboardScreen";
  const DashboardScreen({Key? key,}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectTab = 0;
  PersistentBottomSheetController? _bottomSheetController;
  int notificationCount = 0;

  late List<Widget> _widgetOptions;


  @override
  bool get wantKeepAlive => true;

  void refreshTabScreen() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _widgetOptions = [
      HomeScreen(),
      InviteScreen(refreshCallback: refreshTabScreen),
      ReportScreen(refreshCallback: refreshTabScreen),
      UserProfile(refreshCallback: refreshTabScreen),
    ];
    // Initialize Firebase messaging and handle incoming messages
    FirebaseMessaging.instance.getInitialMessage().then((message) {});

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
    final sessionProvider = Provider.of<SessionProvider>(context);
    sessionProvider.checkLoginStatus();
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
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
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
              TabButton(
                  title: "Reports",
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


