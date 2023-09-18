import 'dart:convert';
import 'package:Taskapp/view/profile/addOrganization.dart';
import 'package:Taskapp/view/profile/widgets/confirmationModal.dart';
import 'package:Taskapp/view/profile/widgets/edit_organization.dart';
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
import '../dashboard/dashboard_screen.dart';
import '../login/login_screen.dart';
import 'delete_organization.dart';

class UserProfile extends StatefulWidget {

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String _appVersion = '';
  bool positive = false;
  Map<String, dynamic> userProfileData = {};
  Map<String, dynamic> latestSubscription = {};
  Map<String, dynamic>? organization;
  int _selectedOrganizationIndex = 0; // Or any other default value based on your application's logic
  String selectedOrganizationName = '';
  Map<String, dynamic> selectedOrganization = {};
  String selectOrganizationAdd = "";
  List<Map<String, dynamic>> _organizationList = [];
  String userId = "";

  List otherArr = [
    {"image": "assets/icons/p_contact.png", "name": "Contact Us", "tag": "5"},
    {
      "image": "assets/icons/p_privacy.png",
      "name": "Privacy Policy",
      "tag": "6"
    },
    {"image": "assets/icons/p_setting.png", "name": "Setting", "tag": "7"},
  ];
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

    if (orgId == null) {
      // If the user hasn't switched organizations, use the organization ID obtained during login time
      orgId = prefs.getString('org_id') ?? "";
    }

    print("OrgId: $orgId");

    if (orgId.isEmpty) {
      throw Exception('orgId not found locally');
    }

    final url = 'http://43.205.97.189:8000/api/User/myProfile?org_id=$orgId';

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
        final String userIds = userProfileData['user_id'];
        setState(() {
          userId = userIds;
        });

        // Fetch and set the organization data here
        final orgData = userProfileData['org']; // Assuming 'org' contains the organization data
        if (orgData != null && orgData.isNotEmpty) {
          organization = orgData.last; // Assuming you want to use the last organization
        }

        print("User_id: $userId");
        return userProfileData;
      }
    }

    // Return an empty map if there's an error or no data
    return {};
  }

  void _logOut(BuildContext? context) async {
    if (context == null) {
      // Handle the case where context is null, such as logging an error or returning early.
      print('Error: Context is null in _logOut.');
      return;
    }
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog and set confirmLogout to false
                Navigator.of(context)?.pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Close the dialog and set confirmLogout to true
                Navigator.of(context)?.pop(true);

                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear();

                  // Delay navigation to the LoginScreen by a short duration (e.g., 100 milliseconds)
                  await Future.delayed(Duration(milliseconds: 300));

                  // Rebuild the app and start a new route stack with LoginScreen
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                        (route) => false,
                  );
                } catch (e) {
                  print('Error during logout: $e');
                }
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      // Perform logout logic here
    }
  }

  void _loadUserProfile() async {
    try {
      Map<String, dynamic> fetchedData = await fetchUserProfile();
      setState(() {
        userProfileData = fetchedData;
      });
    } catch (error) {
      print("Error fetching user profile data: $error");
      // Handle the error
    }
  }

  @override
  void initState() {
    super.initState();
    _getAppVersion();
    _loadUserProfile();
    _fetchOrganizationList();
  }


  Future<void> _fetchOrganizationList() async {
    try {
      await Provider.of<OrganizationProvider>(context, listen: false)
          .fetchOrganizationList();

      setState(() {
        if (userProfileData.containsKey('subscription') &&
            userProfileData['subscription'].isNotEmpty) {
          latestSubscription = userProfileData['subscription'].last;
        }
        if (userProfileData.containsKey('org') &&
            userProfileData['org'].isNotEmpty) {
          organization = userProfileData['org'].last;
          selectedOrganization = userProfileData['org'][0];
        }

        print("subscription: $latestSubscription");
        print("Organization Data: $organization");
      });
    } catch (error) {
      print('Error fetching user profile: $error');
    }
  }

  Future<void> _getAppVersion() async {
    PackageInfo? packageInfo;
    try {
      packageInfo = await PackageInfo.fromPlatform();
    } catch (e) {
      print('Error getting package info: $e');
    }

    if (packageInfo != null) {
      setState(() {
        _appVersion = packageInfo!.version;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final organizationProvider = Provider.of<OrganizationProvider>(context);
    final _selectedOrganizationIndex = organizationProvider.selectedOrganizationIndex;
    final _organizationList = organizationProvider.organizationList;
    print('Organization List Length: ${_organizationList}');

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.whiteColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.blackColor),
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
                  child: Text("Manage Organization"),
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubscriptionsPlan(),
                        ));
                    break;
                  case 2:
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RenewPlanScreen(),
                        ));
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
                  Icon(
                    Icons.people,
                    color: AppColors.secondaryColor2,
                  ),
                  SizedBox(
                    width: 20,
                  ),
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
                              fontWeight: FontWeight.bold),
                        ),
                        RichText(
                          text: TextSpan(
                            text: "Role: ",
                            style: TextStyle(
                                color: AppColors.secondaryColor2,
                                fontSize: 12,
                                fontWeight: FontWeight.bold),
                            children: [
                              TextSpan(
                                text:
                                    "${userProfileData.containsKey('role') ? userProfileData['role'] : 'NA'}",
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
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  GestureDetector(
                    // onTap: () {
                    //   Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => AddOrganization(
                    //         userId: userProfileData['user_id'],
                    //       ),
                    //     ),
                    //   );
                    // },
                    child: IconButton(
                      icon: Icon(Icons.add_circle),
                      onPressed: () async {
                        print("UserId: $userId");
                        final result = Navigator.push(context, MaterialPageRoute(builder: (context)=>AddOrganization(userId: userId)));
                        if (result == true) {
                          await _fetchOrganizationList(); // Replace with your actual fetch function.
                        }
                      },
                    )
                  ),
                ],
              ),
              SizedBox(height: 20,),
              // Container(
              //   width: double.infinity,
              //   height: 220,
              //   padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              //   decoration: BoxDecoration(
              //     color: AppColors.primaryColor1,
              //     borderRadius: BorderRadius.circular(15),
              //     boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
              //   ),
              //   child: SingleChildScrollView(
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         const SizedBox(height: 8),
              //         Scrollbar(
              //           controller: ScrollController(),
              //           thickness: 8,
              //           child: SizedBox(
              //             width: 300,
              //             child: ListView.builder(
              //               shrinkWrap: true,
              //               physics: NeverScrollableScrollPhysics(),
              //               itemCount: _organizationList.length,
              //               itemBuilder: (context, index) {
              //                 final org = _organizationList[index];
              //                 final orgId = org['org_id'];
              //                 final isSelected = orgId == selectedOrganization['org_id'];
              //                 final visibleOrgName = organization != null && organization!.containsKey('org_name')
              //                     ? organization!['org_name']
              //                     : 'No Organization';
              //
              //
              //                 return GestureDetector(
              //                   onTap: () async {
              //                     final prefs = await SharedPreferences.getInstance();
              //                     if (userProfileData.isNotEmpty) {
              //                       prefs.setString('selectedOrgId', orgId);
              //
              //                       organizationProvider.switchOrganization(
              //                         index,
              //                         context,
              //                       );
              //
              //                       setState(() {
              //                         selectedOrganizationName = org['name'];
              //                         selectOrganizationAdd = org['address'];
              //                         selectedOrganization = org;
              //                       });
              //                       _showNotification('Organization switched to ${org['name']}');
              //                     }
              //                   },
              //                   child: Container(
              //                     margin: EdgeInsets.all(8.0),
              //                     padding: EdgeInsets.all(16.0),
              //                     decoration: BoxDecoration(
              //                       color: visibleOrgName == org['name'] ? AppColors.secondaryColor2 : (org['subs_status'] == true ? Colors.white : Colors.grey),
              //                       borderRadius: BorderRadius.circular(15),
              //                       border: isSelected
              //                           ? Border.all(
              //                         color: AppColors.primaryColor2,
              //                         width: 3,
              //                       )
              //                           : Border.all(
              //                         color: AppColors.blackColor,
              //                         width: 2,
              //                       ),
              //                       boxShadow: const [
              //                         BoxShadow(color: Colors.black12, blurRadius: 2),
              //                       ],
              //                     ),
              //                    child: Row(
              //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //                       children: [
              //                         Expanded(
              //                           child: Column(
              //                             mainAxisAlignment: MainAxisAlignment.start,
              //                             crossAxisAlignment: CrossAxisAlignment.start,
              //                             children: [
              //                               SingleChildScrollView(
              //                                 scrollDirection: Axis.horizontal,
              //                                 child: SizedBox(
              //                                   height: 40,
              //                                   child: Text(
              //                                     org["name"],
              //                                     style: TextStyle(
              //                                       color: isSelected ? Colors.white : AppColors.blackColor,
              //                                       fontSize: 16,
              //                                       fontWeight: FontWeight.bold,
              //                                     ),
              //                                   ),
              //                                 ),
              //                               ),
              //                               SingleChildScrollView(
              //                                 scrollDirection: Axis.horizontal,
              //                                 child: RichText(
              //                                   text: TextSpan(
              //                                     text: "Employee: ",
              //                                     style: TextStyle(
              //                                       color: AppColors.blackColor,
              //                                       fontSize: 12,
              //                                       fontWeight: FontWeight.bold,
              //                                     ),
              //                                     children: [
              //                                       TextSpan(
              //                                         text: "${org['employees']}",
              //                                         style: TextStyle(
              //                                           color: AppColors.blackColor,
              //                                         ),
              //                                       ),
              //                                     ],
              //                                   ),
              //                                 ),
              //                               ),
              //                             ],
              //                           ),
              //                         ),
              //                         SizedBox(
              //                           width:100, // Set a fixed width for the edit and delete buttons
              //                           child: Row(
              //                             mainAxisAlignment: MainAxisAlignment.end,
              //                             children: [
              //                               IconButton(
              //                                 icon: Icon(Icons.edit, color: Colors.black),
              //                                 onPressed: () async {
              //                                   final result = await Navigator.push(
              //                                     context,
              //                                     MaterialPageRoute(
              //                                       builder: (context) => EditOrganization(userId: userId, orgId: orgId),
              //                                     ),
              //                                   );
              //
              //                                   if (result == true) {
              //                                     await _fetchOrganizationList(); // Replace with your actual fetch function.
              //                                   }
              //                                 },
              //                               ),
              //                               IconButton(
              //                                 icon: Icon(Icons.delete, color: Colors.black),
              //                                 onPressed: () async{
              //                                   print("OrgId: $orgId"); // Ensure you have the correct orgId here
              //                                   final result = await showDialog(
              //                                     context: context,
              //                                     builder: (BuildContext context) {
              //                                       return AlertDialog(
              //                                         content: Container(
              //                                           height: 300, // Adjust this value as needed
              //                                           child: Builder(
              //                                             builder: (BuildContext context) {
              //                                               return DeleteOrganization(orgId: orgId, onDelete: () {
              //                                                 setState(() {
              //                                                   _fetchOrganizationList();
              //                                                 });
              //                                               });
              //                                             },
              //                                           ),
              //                                         ),
              //                                       );
              //                                     },
              //                                   );
              //                                   if (result == true) {
              //                                     await _fetchOrganizationList(); // Replace with your actual fetch function.
              //                                   }
              //                                 },
              //                               )
              //                             ],
              //                           ),
              //                         ),
              //                       ],
              //                     ),
              //
              //                   ),
              //                 );
              //               },
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //
              //   ),
              // ),
              Container(
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor1,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Scrollbar(
                        controller: ScrollController(),
                        thickness: 8,
                        child: SizedBox(
                          width: 300,
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: _organizationList.length,
                            itemBuilder: (context, index) {
                              final org = _organizationList[index];
                              final orgId = org['org_id'];
                              final isSelected = orgId == selectedOrganization['org_id'];
                              final visibleOrgName =
                              organization != null && organization!.containsKey('org_name')
                                  ? organization!['org_name']
                                  : 'No Organization';

                              // Check if organization is deactivated (subs_status = false)
                              final isDeactivated = org['subs_status'] == false;

                              return GestureDetector(
                                onTap: () async {
                                  final prefs = await SharedPreferences.getInstance();
                                  if (userProfileData.isNotEmpty) {
                                    final orgId = org['org_id'];

                                    if (!isDeactivated) {
                                      prefs.setString('selectedOrgId', orgId);

                                      organizationProvider.switchOrganization(
                                        index,
                                        context,
                                      );

                                      setState(() {
                                        selectedOrganizationName = org['name'];
                                        selectOrganizationAdd = org['address'];
                                        selectedOrganization = org;
                                      });
                                      _showNotification('Organization switched to ${org['name']}');
                                    } else {
                                      // Display a message when subs_status is false
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Deactivated Organization'),
                                            content: Text('This organization is deactivated and cannot be selected.'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  margin: EdgeInsets.all(8.0),
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: visibleOrgName == org['name']
                                        ? AppColors.secondaryColor2
                                        : (isDeactivated ? Colors.black12 : Colors.white),
                                    borderRadius: BorderRadius.circular(15),
                                    border: isSelected
                                        ? Border.all(
                                      color: AppColors.primaryColor2,
                                      width: 3,
                                    )
                                        : Border.all(
                                      color: AppColors.blackColor,
                                      width: 2,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(color: Colors.black12, blurRadius: 2),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: SizedBox(
                                                height: 40,
                                                child: Text(
                                                  org["name"],
                                                  style: TextStyle(
                                                    color: (visibleOrgName == org['name'] ? Colors.white : AppColors.blackColor),
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: RichText(
                                                text: TextSpan(
                                                  text: "Employee: ",
                                                  style: TextStyle(
                                                    color: (visibleOrgName == org['name'] ? Colors.white : AppColors.blackColor),
                                                    fontSize: 12,
                                                  ),
                                                  children: [
                                                    TextSpan(
                                                      text: "${org['employees']}",
                                                      style: TextStyle(
                                                        color: (visibleOrgName == org['name'] ? Colors.white : AppColors.blackColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 100, // Set a fixed width for the edit and delete buttons
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: (visibleOrgName == org['name'] ? Colors.white : AppColors.blackColor)),
                                              onPressed: () async {
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => EditOrganization(userId: userId, orgId: orgId),
                                                  ),
                                                );

                                                if (result == true) {
                                                  await _fetchOrganizationList(); // Replace with your actual fetch function.
                                                }
                                              },
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: (visibleOrgName == org['name'] ? Colors.white : AppColors.blackColor)),
                                              onPressed: () async {
                                                print("OrgId: $orgId"); // Ensure you have the correct orgId here
                                                if (!isDeactivated) {
                                                  final result = await showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        content: Container(
                                                          height: 300, // Adjust this value as needed
                                                          child: Builder(
                                                            builder: (BuildContext context) {
                                                              return DeleteOrganization(orgId: orgId, onDelete: () {
                                                                setState(() {
                                                                  _fetchOrganizationList();
                                                                });
                                                              });
                                                            },
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                  if (result == true) {
                                                    await _fetchOrganizationList(); // Replace with your actual fetch function.
                                                  }
                                                }
                                              },
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
                      ),
                    ],
                  ),
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
                              SizedBox(
                                width: 10,
                              ),
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
                            "Hi,I am ${userProfileData.containsKey('name') ? userProfileData['name'] : 'John'},I am ${userProfileData.containsKey('role') ? userProfileData['role'] : 'Admin'} at ${organization != null && organization!.containsKey('org_name')
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
                    SizedBox(
                      height: 10,
                    ),
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
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text:
                                            "${userProfileData.containsKey('name') ? userProfileData['name'] : 'John'}",
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
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text:
                                            "${userProfileData.containsKey('phone') ? userProfileData['phone'] : 'No Phone'}",
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
                                        fontWeight: FontWeight.bold),
                                    children: [
                                      TextSpan(
                                        text:
                                            "${userProfileData.containsKey('email') ? userProfileData['email'] : 'No Email'}",
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                        height: 30,
                        width: 70,
                        child: RoundButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => EditProfileScreen(userProfileData: userProfileData),
                            //   ),
                            // );
                          },
                          title: "Edit",
                        ))
                  ],
                ),
              ),
              const SizedBox(
                height: 45,
              ),
              Visibility(
                visible:
                    latestSubscription.isNotEmpty,
                child: Container(
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
                                SizedBox(
                                  width: 10,
                                ),
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
                              "You are using the ${latestSubscription.containsKey('name') ? latestSubscription['name'] : 'No Subscription'}",
                              style: TextStyle(
                                color: AppColors.secondaryColor1,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
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
                                    child: Text(
                                      "Plan Details",
                                      style: TextStyle(
                                          color: AppColors.secondaryColor2,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  RichText(
                                    text: TextSpan(
                                      text: "Plan name: ",
                                      style: TextStyle(
                                          color: AppColors.secondaryColor2,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                          text:
                                              "${latestSubscription.containsKey('name') ? latestSubscription['name'] : 'No Subscription'}",
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
                                          fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                          text: latestSubscription
                                                  .containsKey('startDate')
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
                                          fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                          text:
                                              "${latestSubscription.containsKey('startDate') ? _formatDate(latestSubscription['startDate']) : 'N/A'}",
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
                                          fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                          text:
                                              "${latestSubscription.containsKey('endDate') ? _formatDate(latestSubscription['endDate']) : 'N/A'}",
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
                                          fontWeight: FontWeight.bold),
                                      children: [
                                        TextSpan(
                                          text:
                                              "${latestSubscription.containsKey('price') ? latestSubscription['price'] : 'NA'}",
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
              ),
              SizedBox(
                height: 30,
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
              SizedBox(
                height: 25,
              ),
              Center(
                child: InkWell(
                  onTap:(){
                    _logOut(context);
                  },
                  child: Text(
                    "Logout",
                    style: TextStyle(
                      color: AppColors.blackColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 25,
              ),
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

void _showMoreOptionsModal(BuildContext context, Map<String, dynamic> org) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle edit organization logic here
                Navigator.pop(context); // Close the modal
              },
              child: Text('Edit Organization'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Handle delete organization logic here
                Navigator.pop(context); // Close the modal
              },
              child: Text('Delete Organization'),
            ),
          ],
        ),
      );
    },
  );
}

String _formatDate(String dateString) {
  final inputFormat = DateFormat(
      'yyyy-MM-ddTHH:mm:ss'); // Replace with the actual format of your input date string
  final outputFormat =
      DateFormat('MMM dd, yyyy'); // Replace with the desired output format
  final date = inputFormat.parse(dateString);
  return outputFormat.format(date);
}
