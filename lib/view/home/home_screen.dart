import 'dart:async';
import 'dart:convert';
import 'package:Taskapp/organization_proivider.dart';
import 'package:Taskapp/view/projects/projectCreation.dart';
import 'package:Taskapp/view/reports/reports.dart';
import 'package:Taskapp/view/signup/inviteTeammates.dart';
import 'package:Taskapp/view/subscription/subscriptions.dart';
import 'package:Taskapp/view/tasks/completedTasks.dart';
import 'package:Taskapp/view/tasks/openTasks.dart';
import 'package:Taskapp/view/tasks/tasks.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/teams/teamList.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_button.dart';
import '../../models/task_model.dart';
import '../notification/notification_screen.dart';
import 'package:http/http.dart' as http;
import '../projects/projectDashScreen.dart';
import '../tasks/MistaskCreation.dart';
import '../teams/createTeams.dart';


class HomeScreen extends StatefulWidget {
  static String routeName = "/HomeScreen";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int totalCompletedTasks = 0;
  List<Task> tasks = [];
  int totalMyProjects = 0;
  int totalMyTasks = 0;
  bool isProjectsFetched = false;
  bool isTasksFetched = false;
  bool isTasksCompleted = false;
  String userName="";
  String orgName= "";
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    fetchMyProjects(); // Fetch projects when the screen is loaded
    fetchMyTasks();
    fetchUserNameAndOrganization();// Fetch tasks when the screen is loaded
    // _timer = Timer.periodic(Duration(seconds: 1), (Timer t) async{
    //   await fetchMyProjects();
    //   await fetchUserNameAndOrganization();
    //   await fetchMyTasks();
    // });
  }


  Future<void> fetchMyProjects() async {
    try {
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

      final url = 'http://43.205.97.189:8000/api/Project/myProjects?org_id=$orgId';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final List<Future<Null>> fetchedProjects = responseData.map((projectData) async {
          // Remaining code remains the same
        }).toList();
        setState(() {
          totalMyProjects = fetchedProjects.length;
          // Other code remains the same
        });
      } else {
        print('Error fetching projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching projects: $e');
    }
  }

  Future<void> fetchUserNameAndOrganization() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      print("OrgId: $orgId");
      final url = 'http://43.205.97.189:8000/api/User/myProfile';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        if (responseData.isNotEmpty) {
          final Map<String, dynamic> userData = responseData[0];
          setState(() {
            userName = userData['name'] ?? 'Admin'; // Set the value of userName in the class scope

            orgId = orgId ?? "";
          });
        }

        // Fetch organization name using orgId
        final orgUrl = 'http://43.205.97.189:8000/api/Organization/MyOrganizations';
        final orgResponse = await http.get(Uri.parse(orgUrl), headers: headers);

        if (orgResponse.statusCode == 200) {
          final List<dynamic> orgData = jsonDecode(orgResponse.body);
          final org = orgData.firstWhere((element) => element['org_id'] == orgId, orElse: () => null);
          if (org != null) {
            final orgName = org['name'];
            print("OrgName: $orgName");
            setState(() {
              this.orgName = orgName; // Set the value of orgName in the class scope
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

  Future<void> fetchMyTasks() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        // If the user hasn't switched organizations, use the organization ID obtained during login time
        orgId = prefs.getString('org_id') ?? "";
      }


      print("OrgId: $orgId");

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      print("OrgId: $orgId");
      final url = 'http://43.205.97.189:8000/api/Task/myTasks?org_id=$orgId';


      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      print("StatusCode: ${response.statusCode}");
      print("Response: ${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final List<Task> fetchedTasks = responseData.map((taskData) {
          final List<dynamic> users = taskData['users'];
          final List<String> assignedUsers = users.isNotEmpty
              ? users.map((user) => user['user_name'] as String).toList()
              : [];
          final List<String> assignedTo = assignedUsers;
          return Task(
            taskName: taskData['task_name'] ?? '',
            assignedTo: assignedTo, // Update key from 'assignee' to 'created_by'
            status: taskData['status'] ?? '',
            description: taskData['description'] ?? '',
            priority: taskData['priority'] ?? '',
            dueDate: taskData['dueDate'],
          );
        }).toList();
        setState(() {
          tasks = fetchedTasks;
          totalMyTasks = responseData.length;
          totalCompletedTasks = tasks.where((task) => task.status.toLowerCase() == 'completed').length;
          print('Total My Tasks: $totalMyTasks');
          print('Total Completed Tasks: $totalCompletedTasks');
          isTasksFetched = true;
          isTasksCompleted = true;
        });
      } else {
        print('Error fetching tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    print("Home screen build");
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
                          width: 50, // Adjust the width as per your requirement
                          height: 80, // Adjust the height as per your requirement
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.secondaryColor2, // Set the desired background color for the oval (e.g., red)
                          ),
                          // child: Text(
                          //   userName.substring(0,1), // Check if userName is not empty before using substring
                          //   style: TextStyle(
                          //     color: Colors.white,
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                        ),
                        SizedBox(width: 8,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start,
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
                        },
                        icon: Image.asset(
                          "assets/icons/notification_icon.png",
                          width: 25,
                          height: 25,
                          fit: BoxFit.fitHeight,
                        )),
                    SizedBox(width: 1,),
                    IconButton(
                        onPressed: () {
                          _showBottomSheet(context);
                        },
                        icon: Image.asset(
                          "assets/images/menu.png",
                          width: 25,
                          height: 25,
                          fit: BoxFit.fitHeight,
                        )),
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
                      onTap: () async{
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>TeamsFormedScreen(),));
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width:  50,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor1,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xffE0E0E0))),
                            child: Center(
                              child: Image.asset(
                                "assets/images/group.png",
                                color: AppColors.secondaryColor2,
                                width:35,
                                height:35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 11,),
                          Text("My Teams",style: TextStyle(
                            color: AppColors.secondaryColor2,
                            fontSize: 12,
                          ),),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async{
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>ProjectDashScreen(),));
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width:  50,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor1,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xffE0E0E0))),
                            child: Center(
                              child: Image.asset(
                                "assets/images/survey.png",
                                color: AppColors.secondaryColor2,
                                width:35,
                                height:35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 11,),
                          Text("Total Projects",style: TextStyle(
                            color: AppColors.secondaryColor2,
                            fontSize: 12,
                          ),),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskScreen(),));
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width:  50,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor1,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xffE0E0E0))),
                            child: Center(
                              child: Image.asset(
                                "assets/images/to-do-list.png",
                                color: AppColors.secondaryColor2,
                                width:35,
                                height:35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 11,),
                          Text("My Tasks",style: TextStyle(
                            color: AppColors.secondaryColor2,
                            fontSize: 12,
                          ),),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40,),
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
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>OpenTaskScreen()));
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20,),
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
                                Navigator.push(context, MaterialPageRoute(builder: (context)=>CompletedTaskScreen()));
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 40,),
                Container(
                  padding:  const EdgeInsets.symmetric(horizontal:  10,vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color(0xffE1E3E9),
                      border: Border.all(color: const Color(0xffE1E3E9))
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text("Total Projects",style: TextStyle(
                            color: AppColors.secondaryColor2,
                            fontSize: 14,
                          ),),
                          const Spacer(),
                          Container(
                            decoration:  BoxDecoration(
                                color: const Color(0xffE1E3E9),
                                borderRadius: BorderRadius.circular(8)
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                            child: Center(child: Text(totalMyProjects.toString(),),
                            ),
                          )],
                      ),
                      const SizedBox(height: 20,),
                      const Divider(
                        height: 0,
                        color: AppColors.blackColor,
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          Text("Total Completed Task",style: TextStyle(
                            color: AppColors.secondaryColor2,
                            fontSize: 14,
                          ),),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                            child: Center(child: Text(totalCompletedTasks.toString()),
                            ),
                          )],
                      ),
                      const SizedBox(height: 20,),
                      const Divider(
                        height: 0,
                        color: AppColors.blackColor,
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          Text("Tasks Assigned To me",style: TextStyle(
                            color: AppColors.secondaryColor2,
                            fontSize: 14,
                          ),),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                            child: Center(child: Text(totalMyTasks.toString(),),
                            ),
                          )],
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
                            width:  50,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor1,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xffE0E0E0))),
                            child: Center(
                              child: Image.asset(
                                "assets/images/create.png",
                                color: AppColors.secondaryColor2,
                                width:35,
                                height:25,
                              ),
                            ),
                          ),
                          const SizedBox(height: 11,),
                          Text("Create",style: TextStyle(
                            color: AppColors.secondaryColor2,
                            fontSize: 14,
                          ),),
                        ],
                      ),
                    ),
                    SizedBox(width:90,),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>InviteTeammatesScreen(),));
                      },
                      child: Column(
                        children: [
                          Container(
                            height: 50,
                            width:  50,
                            decoration: BoxDecoration(
                                color: AppColors.primaryColor1,
                                shape: BoxShape.circle,
                                border: Border.all(color: const Color(0xffE0E0E0))),
                            child: Center(
                              child: Image.asset(
                                "assets/images/invite.png",
                                color: AppColors.secondaryColor2,
                                width:35,
                                height:25,
                              ),
                            ),
                          ),
                          const SizedBox(height: 11,),
                          Text("Invite",style: TextStyle(
                            color: AppColors.secondaryColor2,
                            fontSize: 14,
                          ),),
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

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return _buildBottomSheet(context);
      },
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:Icon(Icons.subscriptions) ,
              title: Text('Subscriptions'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>SubscriptionsPlan()));
              },
            ),
            ListTile(
              leading: Icon(Icons.report),
              title: Text('Reports'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ReportScreen(),));
              },
            ),
            ListTile(
              leading: Icon(Icons.feedback),
              title: Text('My Teams'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TeamsFormedScreen(),));
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('settings'),
            ),
          ],
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
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ProjectCreationScreen(),));
              },
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Create Tasks'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>MisTaskCreationScreen(),));
              },
            ),
            ListTile(
              leading:Icon(Icons.group_rounded) ,
              title: Text('Create Team'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TeamCreationPage(),));
              },
            ),
          ],
        ),
      ),
    );
  }
}

