import 'dart:convert';
import 'package:Taskapp/view/activity/activity_screen.dart';
import 'package:Taskapp/view/projects/projectCreation.dart';
import 'package:Taskapp/view/projects/projectDashScreen.dart';
import 'package:Taskapp/view/reports/reports.dart';
import 'package:Taskapp/view/signup/inviteTeammates.dart';
import 'package:Taskapp/view/tasks/taskCreation.dart';
import 'package:Taskapp/view/tasks/taskDetails.dart';
import 'package:Taskapp/view/projects/taskcreation.dart';
import 'package:Taskapp/view/tasks/tasks.dart';
import 'package:Taskapp/view/teams/createTeams.dart';
import 'package:Taskapp/utils/app_colors.dart';
import 'package:Taskapp/view/teams/teamList.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_button.dart';
import '../../models/task_model.dart';
import '../notification/notification_screen.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  static String routeName = "/HomeScreen";

  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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
                              "Admin",
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
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskDetailsScreen(projectName: "Project B", taskTitle: "Task 4", assignee: "Bob",status: "Completed",)));
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
                                "assets/images/cross.png",
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
                                "assets/images/employee-benefit.png",
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
                            Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskDetailsScreen(projectName: "Alpha", taskTitle: "Task 1", assignee: "John",status: "Open",)));
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
                            child: Center(child: Text("5"),
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
                            decoration:  BoxDecoration(
                                color: const Color(0xffDEE5FF),
                                borderRadius: BorderRadius.circular(8)
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                            child: Center(child: Text("2"),
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
                            decoration:  BoxDecoration(
                                color: const Color(0xffDEE5FF),
                                borderRadius: BorderRadius.circular(8)
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
                            child: Center(child: Text("9"),
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
              leading: Icon(Icons.remove_red_eye),
              title: Text('View Tasks'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskScreen(),));
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Activity'),
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ActivityScreen(),));
              },
            ),
            ListTile(
              leading:Icon(Icons.subscriptions) ,
              title: Text('Subscriptions'),
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

