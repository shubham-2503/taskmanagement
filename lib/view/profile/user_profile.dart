import 'dart:convert';
import 'package:Taskapp/view/subscription/subscriptions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:Taskapp/view/subscription/renewPlan.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/profile/widgets/setting_row.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_button.dart';
import '../../organization_proivider.dart';
import '../login/login_screen.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String _appVersion = '';
  bool positive = false;
  Map<String, dynamic> userProfileData = {};
  Map<String, dynamic> latestSubscription = {};
  Map<String, dynamic>? organization;
  int selectedOrganizationIndex = -1; // Or any other default value based on your application's logic
  String selectedOrganizationName = '';
  String selectOrganizationAdd = "";

  List otherArr = [
    {"image": "assets/icons/p_contact.png", "name": "Contact Us", "tag": "5"},
    {"image": "assets/icons/p_privacy.png", "name": "Privacy Policy", "tag": "6"},
    {"image": "assets/icons/p_setting.png", "name": "Setting", "tag": "7"},
  ];

  Future<Map<String, dynamic>> fetchUserProfile() async {
    final url = 'http://43.205.97.189:8000/api/User/myProfile';

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');

    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $storedData',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    print("StatusCode: ${response.statusCode}");
    print("Response: ${response.body}");

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      if (responseData.isNotEmpty) {
        // Get the first organization as the default organization
        final Map<String, dynamic> userProfileData = responseData[0] as Map<String, dynamic>;
        return userProfileData;
      }
    }

    // Return an empty map if there's an error or no data
    return {};
  }

  void _logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => LoginScreen()));
  }


  @override
  void initState() {
    super.initState();
    _getAppVersion();
    // Call fetchOrganizationList() when the screen is built
    Provider.of<OrganizationProvider>(context, listen: false).fetchOrganizationList();
    fetchUserProfile().then((data) {
      setState(() {
        userProfileData = data;
        if (userProfileData.containsKey('subscription') &&
            userProfileData['subscription'].isNotEmpty) {
          latestSubscription = userProfileData['subscription'].last;
        }
        if (userProfileData.containsKey('org') && userProfileData['org'].isNotEmpty) {
          organization = userProfileData['org'].last;
        }

        print("Organization Data: $organization");
      });
    }).catchError((error) {
      print('Error fetching user profile: $error');
    });
  }

  Future<void> _getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  // Future<void> fetchOrganizationList() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final storedData = prefs.getString('jwtToken');
  //
  //   final url = 'http://43.205.97.189:8000/api/Organization/MyOrganizations';
  //   try {
  //     final headers = {
  //       'accept': '*/*',
  //       'Authorization': 'Bearer $storedData',
  //     };
  //
  //     final response = await http.get(Uri.parse(url), headers: headers);
  //
  //     print('Response: ${response.body}');
  //     print('Status: ${response.statusCode}');
  //
  //     if (response.statusCode == 200) {
  //       // If the server returns a successful response, parse the JSON
  //       final List<dynamic> data = json.decode(response.body);
  //       setState(() {
  //         _organizationList = data.cast<Map<String, dynamic>>();
  //       });
  //     } else {
  //       throw Exception('Failed to load organization list');
  //     }
  //   } catch (e) {
  //     print('Error fetching organization list: $e');
  //     throw Exception('Failed to load organization list');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    final _selectedOrganizationIndex = organizationProvider.selectedOrganizationIndex;
    final _organizationList = organizationProvider.organizationList;
    print('Organization List Length: ${_organizationList}');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.whiteColor),
        title: const Text(
          "Profile",
          style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 16,
              fontWeight: FontWeight.w700),
        ),
        actions: [
          InkWell(
            child: PopupMenuButton<int>(
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Text("Open Invoice"),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Text("Manage Subscription"),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Text("Renew Plan"),
                ),
              ],
              onSelected: (value) {
                // Handle the selected option here
                switch (value) {
                  case 0:
                    break;
                  case 1:
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>SubscriptionsPlan(),));
                    break;
                  case 2:
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>RenewPlanScreen(),));
                    break;
                  default:
                    break;
                }
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                height: 40,
                width: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.lightGrayColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.asset(
                  "assets/icons/more_icon.png",
                  width: 12,
                  height: 12,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.people,color: AppColors.secondaryColor2,),
                  SizedBox(width: 20,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userProfileData.containsKey('name')
                              ? userProfileData['name']
                              : 'John', // Use the name from the fetched data, or default to 'John'
                          style: TextStyle(
                              color: AppColors.secondaryColor2,
                              fontSize: 15,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Role: ",
                            style: TextStyle(
                                color: AppColors.secondaryColor2,
                                fontSize: 12,
                                fontWeight: FontWeight.bold
                            ),
                            children: [
                              TextSpan(
                                text: "${userProfileData.containsKey('role')
                                    ? userProfileData['role']
                                    : 'NA'}",
                                style: TextStyle(
                                  // Add any specific styles for the plan name here, if needed
                                  color: AppColors.blackColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Organization: ",
                            style: TextStyle(
                                color: AppColors.secondaryColor2,
                                fontSize: 12,
                                fontWeight: FontWeight.bold
                            ),
                            children: [
                              TextSpan(
                                text: "$selectedOrganizationName",
                                style: TextStyle(
                                  // Add any specific styles for the plan name here, if needed
                                  color: AppColors.blackColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20,),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "My Organization",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.secondaryColor2,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: (_organizationList.length * 38.0) + 80, // Height calculation
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns in the GridView
                          crossAxisSpacing: 10.0, // Spacing between columns
                          mainAxisSpacing: 10.0, // Spacing between rows
                        ),
                        itemCount: _organizationList.length,
                        itemBuilder: (context, index) {
                          print('Building item for index $index');
                          final org = _organizationList[index];
                          return GestureDetector(
                            onTap: () {
                              organizationProvider.switchOrganization(index);
                              // Switch the organization in the provider and refresh the screen
                              setState(() {
                                selectedOrganizationName = org['name'];
                                selectOrganizationAdd = org['address'];
                              });
                              _showNotification('Organization switched to ${org['name']}'); // Show notification
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedOrganizationIndex == index
                                    ? AppColors.secondaryColor2 // Selected organization color
                                    : AppColors.whiteColor,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    org["name"],
                                    style: TextStyle(
                                      color: _selectedOrganizationIndex == index
                                          ? Colors.white // Selected organization text color
                                          : AppColors.blackColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    org["address"],
                                    style: TextStyle(
                                      color: _selectedOrganizationIndex == index
                                          ? Colors.white // Selected organization text color
                                          : AppColors.blackColor,
                                      fontSize: 10,
                                    ),
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: "Employee: ",
                                      style: TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "${org['employees']}",
                                          style: TextStyle(
                                            color: AppColors.blackColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 45,
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.primaryColor1,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 10,),
                              Text(
                                "Profile Information",
                                style: TextStyle(
                                  color: AppColors.secondaryColor2,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "Hi,I am ${userProfileData.containsKey('name')
                                ? userProfileData['name']
                                : 'John'},I am ${ userProfileData.containsKey('role')
                                ? userProfileData['role']
                                : 'Admin'} at ${organization != null && organization!.containsKey('org_name')
                                ? organization!['org_name']
                                : 'No Organization'}",
                            style: TextStyle(
                              color: AppColors.secondaryColor1,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: "Full Name: ",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "${userProfileData.containsKey('name')
                                            ? userProfileData['name']
                                            : 'John'}",
                                        style: TextStyle(
                                          // Add any specific styles for the plan name here, if needed
                                          color: AppColors.blackColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    text: "Mobile: ",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "${userProfileData.containsKey('phone')
                                            ? userProfileData['phone']
                                            : 'No Phone'}",
                                        style: TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    text: "Email: ",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "${
                                            userProfileData.containsKey('email')
                                                ? userProfileData['email']
                                                : 'No Email'
                                        }",
                                        style: TextStyle(
                                          // Add any specific styles for the plan name here, if needed
                                          color: AppColors.blackColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    text: "Organization: ",
                                    style: TextStyle(
                                      color: AppColors.secondaryColor2,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "$selectedOrganizationName",
                                        style: TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    text: "Organization Address: ",
                                    style: TextStyle(
                                      color: AppColors.secondaryColor2,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "$selectOrganizationAdd",
                                        style: TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    SizedBox(
                        height: 30,
                        width: 70,
                        child:RoundButton(
                          onPressed: (){
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => EditProfileScreen(userProfileData: userProfileData),
                            //   ),
                            // );
                          },
                          title: "Edit",
                        )
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 45,
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.primaryColor1,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/renewable-energy.png",
                                height: 15,
                                width: 15,
                                fit: BoxFit.contain,
                                color: AppColors.secondaryColor2,
                              ),
                              SizedBox(width: 10,),
                              Text(
                                "My Subscribed Plan",
                                style: TextStyle(
                                  color: AppColors.secondaryColor2,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "You are using the ${latestSubscription.containsKey('name')
                                ? latestSubscription['name']
                                : 'No Subscription'}",
                            style: TextStyle(
                              color: AppColors.secondaryColor1,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Text("Plan Details",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10,),
                                RichText(
                                  text: TextSpan(
                                    text: "Plan name: ",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "${latestSubscription.containsKey('name')
                                            ? latestSubscription['name']
                                            : 'No Subscription'}",
                                        style: TextStyle(
                                          // Add any specific styles for the plan name here, if needed
                                          color: AppColors.blackColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    text: "Subscription Status: ",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),
                                    children: [
                                      TextSpan(
                                        text: latestSubscription.containsKey('startDate')
                                            ? " Active"
                                            : " Inactive",
                                        style: TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    text: "Subscription Start Date: ",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "${
                                            latestSubscription.containsKey('startDate')
                                                ? _formatDate(latestSubscription['startDate'])
                                                : 'N/A'
                                        }",
                                        style: TextStyle(
                                          // Add any specific styles for the plan name here, if needed
                                          color: AppColors.blackColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    text: "Subscription Renewal Date: ",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "${
                                            latestSubscription.containsKey('endDate')
                                                ? _formatDate(latestSubscription['endDate'])
                                                : 'N/A'
                                        }",
                                        style: TextStyle(
                                          // Add any specific styles for the plan name here, if needed
                                          color: AppColors.blackColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    text: "Subscription Price: ",
                                    style: TextStyle(
                                        color: AppColors.secondaryColor2,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "${latestSubscription.containsKey('price')
                                            ? latestSubscription['price']
                                            : 'NA'}",
                                        style: TextStyle(
                                          // Add any specific styles for the plan name here, if needed
                                          color: AppColors.blackColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30,),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Notification",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      height: 30,
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/icons/p_notification.png",
                                height: 15, width: 15, fit: BoxFit.contain),
                            const SizedBox(
                              width: 15,
                            ),
                            Expanded(
                              child: Text(
                                "Pop-up Notification",
                                style: TextStyle(
                                  color: AppColors.blackColor,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            CustomAnimatedToggleSwitch<bool>(
                              current: positive,
                              values: [false, true],
                              dif: 0.0,
                              indicatorSize: Size.square(30.0),
                              animationDuration:
                              const Duration(milliseconds: 200),
                              animationCurve: Curves.linear,
                              onChanged: (b) => setState(() => positive = b),
                              iconBuilder: (context, local, global) {
                                return const SizedBox();
                              },
                              defaultCursor: SystemMouseCursors.click,
                              onTap: () => setState(() => positive = !positive),
                              iconsTappable: false,
                              wrapperBuilder: (context, global, child) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned(
                                        left: 10.0,
                                        right: 10.0,

                                        height: 30.0,
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                colors: AppColors.secondaryG),
                                            borderRadius:
                                            const BorderRadius.all(
                                                Radius.circular(30.0)),
                                          ),
                                        )),
                                    child,
                                  ],
                                );
                              },
                              foregroundIndicatorBuilder: (context, global) {
                                return SizedBox.fromSize(
                                  size: const Size(10, 10),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(50.0)),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black38,
                                            spreadRadius: 0.05,
                                            blurRadius: 1.1,
                                            offset: Offset(0.0, 0.8))
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ]),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 2)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Other",
                      style: TextStyle(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: otherArr.length,
                      itemBuilder: (context, index) {
                        var iObj = otherArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: iObj["image"].toString(),
                          title: iObj["name"].toString(),
                          onPressed: () {},
                        );
                      },
                    )
                  ],
                ),
              ),
              SizedBox(height: 25,),
              Center(
                child: InkWell(
                  onTap: _logOut,
                  child: Text("Logout",style: TextStyle(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),),
                ),
              ),
              SizedBox(height: 25,),
              Center(child: Text('App Version: $_appVersion'))
            ],
          ),
        ),
      ),
    );
  }

  void _showNotification(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP, // Show toast at the top
      timeInSecForIosWeb: 2,
      backgroundColor: AppColors.secondaryColor2,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}


String _formatDate(String dateString) {
  final inputFormat = DateFormat('yyyy-MM-ddTHH:mm:ss'); // Replace with the actual format of your input date string
  final outputFormat = DateFormat('MMM dd, yyyy'); // Replace with the desired output format
  final date = inputFormat.parse(dateString);
  return outputFormat.format(date);
}