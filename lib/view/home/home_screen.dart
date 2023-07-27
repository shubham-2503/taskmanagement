import 'dart:convert';
import 'package:Taskapp/models/project_model.dart';
import 'package:Taskapp/view/activity/activity_screen.dart';
import 'package:Taskapp/view/projects/projectCreation.dart';
import 'package:Taskapp/view/reports/reports.dart';
import 'package:Taskapp/view/signup/inviteTeammates.dart';
import 'package:Taskapp/view/subscription/chooseplan.dart';
import 'package:Taskapp/view/subscription/subscriptions.dart';
import 'package:Taskapp/view/tasks/completedTasks.dart';
import 'package:Taskapp/view/tasks/openTasks.dart';
import 'package:Taskapp/view/tasks/taskDetails.dart';
import 'package:Taskapp/view/projects/taskcreation.dart';
import 'package:Taskapp/view/tasks/tasks.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/teams/teamList.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_button.dart';
import '../../models/project_team_model.dart';
import '../../models/task_model.dart';
import '../../models/user.dart';
import '../notification/notification_screen.dart';
import 'package:http/http.dart' as http;
import '../projects/projectDashScreen.dart';
import '../tasks/taskCreation.dart';
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
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    fetchMyProjects(); // Fetch projects when the screen is loaded
    fetchMyTasks();
    fetchUserName();// Fetch tasks when the screen is loaded
  }


  Future<void> fetchMyProjects() async {
    try {
      final url = 'http://43.205.97.189:8000/api/Project/myProjects';

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final List<Future<Project>> fetchedProjects = responseData.map((projectData) async {
          // Convert the 'status' field to a string representation
          String status = projectData['status'] == true ? 'Active' : 'In-Active';
          String projectId = projectData['project_id'] ?? '';

          List<User> users = (projectData['users'] as List<dynamic>).map((userData) {
            return User.fromJson(userData); // Create User object from JSON data
          }).toList();

          return Project(
            id: projectId,
            name: projectData['projectName'] ?? '',
            owner: projectData['created_by'] ?? '',
            status: status,
            dueDate: projectData['due_Date'] is bool ? null : projectData['due_Date'],
            // tasks: tasks,
            // teams: teams,
            users: users,
          );
        }).toList();
        setState(() {
          totalMyProjects = responseData.length;
          isProjectsFetched = true;
        });

      } else {
        print('Error fetching projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching projects: $e');
    }
  }

  Future<void> fetchUserName() async {
    try {
      final url = 'http://43.205.97.189:8000/api/User/myProfile';

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

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
          });
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
      final url = 'http://43.205.97.189:8000/api/Task/myTasks';

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
        final List<Task> fetchedTasks = responseData.map((taskData) {
          return Task(
            taskName: taskData['task_name'] ?? '', // Changed to 'task_name'
            assignedTo: taskData['assignee'] ?? '', // Changed to 'assignee'
            status: taskData['status'] ?? '',
            description: taskData['description'] ?? '',
            priority: taskData['priority'] ?? '',
            dueDate: taskData['dueDate'], // 'dueDate' remains the same
          );
        }).toList();
        setState(() {
          tasks = fetchedTasks;
          totalMyTasks = responseData.length;
          totalCompletedTasks = tasks.where((task) => task.status == 'Completed').length;
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
    var media = MediaQuery
        .of(context)
        .size;

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
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ClipRect(
                          child: Image.asset(
                            "assets/images/user.png",
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 8,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              "Welcome Back,",
                              style: TextStyle(
                                color: AppColors.midGrayColor,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              userName,
                              style: TextStyle(
                                color: AppColors.blackColor,
                                fontSize: 20,
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w700,
                              ),
                            )
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CompletedTaskScreen()));
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
                                "assets/images/completed-task.png",
                                color: AppColors.secondaryColor2,
                                width:35,
                                height:35,
                              ),
                            ),
                          ),
                          const SizedBox(height: 11,),
                          Text("Completed Task",style: TextStyle(
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
                  child: Row(
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

