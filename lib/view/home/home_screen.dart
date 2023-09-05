import 'dart:async';
import 'dart:convert';
import 'package:Taskapp/Providers/project_provider.dart';
import 'package:Taskapp/utils/noInternetDialog.dart';
import 'package:Taskapp/view/projects/projectCreation.dart';
import 'package:Taskapp/view/signup/inviteTeammates.dart';
import 'package:Taskapp/view/tasks/completedTasks.dart';
import 'package:Taskapp/view/tasks/openTasks.dart';
import 'package:Taskapp/view/tasks/tasks.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/teams/teamList.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Providers/taskProvider.dart';
import '../../common_widgets/round_button.dart';
import '../../models/task_model.dart';
import '../notification/notification_screen.dart';
import 'package:http/http.dart' as http;
import '../projects/projectDashScreen.dart';
import '../tasks/MistaskCreation.dart';
import '../teams/createTeams.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/HomeScreen";

  const HomeScreen({Key? key,}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late StreamSubscription subscription;
  var isDeviceConnected=false;
  bool isAlertSet =false;
  bool _shouldRefresh = false;
  late ProjectCountManager projectCountManager;
  int totalCompletedTasks = 0;
  List<Task> tasks = [];
  int totalProjectCount = 0;
  int totalMyTasks = 0;
  bool isProjectsFetched = false;
  bool isTasksFetched = false;
  bool isTasksCompleted = false;
  String userName = "";
  String orgName = "";
  ValueNotifier<int> totalMyProjectsNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> totalCompletedTasksNotifier = ValueNotifier<int>(0);
  ValueNotifier<int> totalMyTasksNotifier = ValueNotifier<int>(0);
  ValueNotifier<String> userNameNotifier = ValueNotifier<String>("");
  ValueNotifier<String> orgNameNotifier = ValueNotifier<String>("");

  void refreshScreen() {
    print("RefreshScreen");
    fetchUserNameAndOrganization();
  }

  getConnectivity()=>
      subscription = Connectivity().onConnectivityChanged.listen(
              (ConnectivityResult result)async {
            isDeviceConnected = await InternetConnectionChecker().hasConnection;
            if (!isDeviceConnected && isAlertSet == false) {
             showDialog(context: context,  builder: (BuildContext context) {
               return NoInternetConnection(); // Use your custom widget here
             },);
              setState(() => isAlertSet = true);
            }
            else if (isDeviceConnected && isAlertSet) {
              Navigator.pop(context);
              setState(() => isAlertSet = false);
            }
          }
      );

  @override
  void dispose()
  {
    subscription.cancel();
    super.dispose();

  }

  showDialogBox() async {
    showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please check your Internet connectivity'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.pop(context, 'cancel');
              setState(() => isAlertSet = false);
              isDeviceConnected = await InternetConnectionChecker().hasConnection;
              if (!isDeviceConnected) {
                showDialogBox();
                setState(() => isAlertSet = true);
              }else{
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToProjectDashScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProjectDashScreen()),
    );

    if (result == true) {
      setState(() {
        _shouldRefresh = true; // Update the flag to indicate a refresh
      });
    }
  }


  @override
  void initState() {
    super.initState();
    print("InitState Called");
    totalMyProjectsNotifier.value = 0;
    totalMyTasksNotifier.value = 0;
    totalCompletedTasksNotifier.value = 0;
    userNameNotifier.value = "";
    orgNameNotifier.value = "";
    _updateProjectCountLocally();
    _updateTasksCountLocally();
    refreshScreen(); // Initial data fetching
    getConnectivity();
  }

  @override
  void didUpdateWidget(covariant oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("didUpdateWidget called");
    refreshScreen();
  }

  Future<void> fetchUserNameAndOrganization() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId =
          prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      print("OrgId: $orgId");
      final url = 'http://43.205.97.189:8000/api/User/myProfile?org_id=$orgId';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);
      print("StatusCode: ${response.statusCode}");
      print("API Response Data: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty) {
          final Map<String, dynamic> userData = responseData[0];
          setState(() {
            userName = userData['name'] ??
                'Admin'; // Set the value of userName in the class scope

            orgId = orgId ?? "";
          });
        }

        // Fetch organization name using orgId
        final orgUrl =
            'http://43.205.97.189:8000/api/Organization/MyOrganizations';
        final orgResponse = await http.get(Uri.parse(orgUrl), headers: headers);

        if (orgResponse.statusCode == 200) {
          final List<dynamic> orgData = jsonDecode(orgResponse.body);
          final org = orgData.firstWhere(
              (element) => element['org_id'] == orgId,
              orElse: () => null);
          if (org != null) {
            final orgName = org['name'];
            print("OrgName: $orgName");
            setState(() {
              this.orgName =
                  orgName; // Set the value of orgName in the class scope
            });
          } else {
            print('Organization not found with the given orgId.');
          }
        } else {
          print('Error fetching organization name: ${orgResponse.statusCode}');
        }
      } else {
        print('Error fetching user name: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }
  }

  Future<void> _updateProjectCountLocally() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ProjectCountManager projectCountManager = ProjectCountManager(prefs);
      await projectCountManager.updateProjectCount();
      int count = await projectCountManager.fetchTotalProjectCount();
      print("Total project count: $count"); // Debugging print
      projectCountManager.updateProjectCount(); // Call the updateProjectCount function
      setState(() {
        totalProjectCount = count;
      });
    } catch (e) {
      print("Error updating project count locally: $e");
    }
  }

  Future<void> _updateTasksCountLocally() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      TaskCountManager taskCountManager = TaskCountManager(prefs);

      if (taskCountManager == null) {
        print("taskCountManager is null");
        return;
      }

      await taskCountManager.updateTaskCount();
      await taskCountManager.updateCompletedTaskCount(); // Add this line to update completed task count
      int totalTaskCount = await taskCountManager.fetchTotalTaskCount();
      int completedTaskCount = await taskCountManager.fetchCompletedTaskCount(); // Fetch completed task count
      print("Total Task count: $totalTaskCount"); // Debugging print
      print("Completed Task count: $completedTaskCount"); // Debugging print

      setState(() {
        totalMyTasks = totalTaskCount;
        totalCompletedTasks = completedTaskCount; // Set the completed task count state
      });
    } catch (e) {
      print("Error updating task count locally: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(120),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.primaryColor1,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(40),
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 40, // Adjust the width as per your requirement
                          height:
                              80, // Adjust the height as per your requirement
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors
                                .secondaryColor2, // Set the desired background color for the oval (e.g., red)
                          ),
                          child: Text(
                            userName.isNotEmpty
                                ? userName[0]
                                : 'A', // Use 'A' or any default value
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome Back,",
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              orgName,
                              style: TextStyle(
                                color: AppColors.secondaryColor2,
                                fontSize: 15,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, NotificationScreen.routeName);
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>NotificationApp()));
                        },
                        icon: Image.asset(
                          "assets/icons/notification_icon.png",
                          width: 25,
                          height: 25,
                          fit: BoxFit.fitHeight,
                        )),
                    SizedBox(
                      width: 1,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 70),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeamsFormedScreen(),
                            ));
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor1,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: const Color(0xffE0E0E0))),
                            child: Center(
                              child: Image.asset(
                                "assets/images/group.png",
                                color: AppColors.secondaryColor2,
                                width: 35,
                                height: 35,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 11,
                          ),
                          Text(
                            "My Teams",
                            style: TextStyle(
                              color: AppColors.secondaryColor2,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        _navigateToProjectDashScreen(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor1,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: const Color(0xffE0E0E0))),
                            child: Center(
                              child: Image.asset(
                                "assets/images/survey.png",
                                color: AppColors.secondaryColor2,
                                width: 35,
                                height: 35,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 11,
                          ),
                          Text(
                            "Total Projects",
                            style: TextStyle(
                              color: AppColors.secondaryColor2,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskScreen(),
                            ));
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor1,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: const Color(0xffE0E0E0))),
                            child: Center(
                              child: Image.asset(
                                "assets/images/to-do-list.png",
                                color: AppColors.secondaryColor2,
                                width: 35,
                                height: 35,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 11,
                          ),
                          Text(
                            "My Tasks",
                            style: TextStyle(
                              color: AppColors.secondaryColor2,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: AppColors.primaryColor1.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Open Tasks",
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: 75,
                            height: 30,
                            child: RoundButton(
                              title: "check",
                              type: RoundButtonType.primaryBG,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OpenTaskScreen()));
                              },
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
                            "Completed Tasks",
                            style: TextStyle(
                              color: AppColors.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            width: 75,
                            height: 30,
                            child: RoundButton(
                              title: "check",
                              type: RoundButtonType.primaryBG,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            CompletedTaskScreen()));
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffE1E3E9),
                      border: Border.all(color: const Color(0xffE1E3E9))),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Total Projects",
                            style: TextStyle(
                              color: AppColors.secondaryColor2,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xffE1E3E9),
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: Center(
                              child: Text(
                                "$totalProjectCount",
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(
                        height: 0,
                        color: AppColors.blackColor,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(
                            "Total Completed Task",
                            style: TextStyle(
                              color: AppColors.secondaryColor2,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xffE1E3E9),
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: Center(
                              child: Text(
                                "$totalCompletedTasks",
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      const Divider(
                        height: 0,
                        color: AppColors.blackColor,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          Text(
                            "Tasks Assigned To Me",
                            style: TextStyle(
                              color: AppColors.secondaryColor2,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            decoration: BoxDecoration(
                                color: const Color(0xffE1E3E9),
                                borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: Center(
                              child: Text(
                                "$totalMyTasks",
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: media.width * 0.07),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _showcreateBottomSheet(context);
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor1,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: const Color(0xffE0E0E0))),
                            child: Center(
                              child: Image.asset(
                                "assets/images/create.png",
                                color: AppColors.secondaryColor2,
                                width: 35,
                                height: 25,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 11,
                          ),
                          Text(
                            "Create",
                            style: TextStyle(
                              color: AppColors.secondaryColor2,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 90,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InviteTeammatesScreen(),
                            ));
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor1,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: const Color(0xffE0E0E0))),
                            child: Center(
                              child: Image.asset(
                                "assets/images/invite.png",
                                color: AppColors.secondaryColor2,
                                width: 35,
                                height: 25,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 11,
                          ),
                          Text(
                            "Invite",
                            style: TextStyle(
                              color: AppColors.secondaryColor2,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showcreateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _buildcreateBottomSheet(context);
      },
    );
  }

  Widget _buildcreateBottomSheet(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.create),
              title: Text('Create Project'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProjectCreationScreen(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Create Tasks'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MisTaskCreationScreen(),
                    ));
              },
            ),
            ListTile(
              leading: Icon(Icons.group_rounded),
              title: Text('Create Team'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamCreationPage(),
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
