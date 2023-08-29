import 'dart:convert';

import 'package:Taskapp/Providers/taskProvider.dart';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/tasks/myTasks.dart';
import 'package:Taskapp/view/tasks/MistaskCreation.dart';
import 'package:Taskapp/view/tasks/teamTask.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_textfield.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/filter_options_modal.dart';
import '../dashboard/dashboard_screen.dart';
import 'createdbyMe.dart';


class TaskScreen extends StatefulWidget {

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String selectedOption = 'AllTasks';


  void refreshScreen() {
    setState(() {}); // This triggers a rebuild of the widget
  }

  Map<String, String?> selectedFilters = {};

  Widget getCategoryWidget() {
    switch (selectedOption) {
      case 'TeamTask':
        return TeamTaskScreen(refreshCallback: refreshScreen, selectedFilters: selectedFilters,);
      case 'MyTask':
        return MyTaskScreen(refreshCallback: refreshScreen, selectedFilters: selectedFilters,);
      case 'CreatedByMe':
        return CreatedByMe(refreshCallback: refreshScreen, selectedFilters: selectedFilters,);
      default:
        return MyTaskScreen(refreshCallback: refreshScreen, selectedFilters: selectedFilters,);
    }
  }

  Future<void> fetchAndRefreshTasks() async {
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');
    String? orgId = prefs.getString("selectedOrgId");
    if (orgId == null) {
      orgId = prefs.getString('org_id') ?? "";
    }

    final Uri createdByMeUri = Uri.parse('http://43.205.97.189:8000/api/Task/createdByMe?org_id=$orgId');
    final Uri myTasksUri = Uri.parse('http://43.205.97.189:8000/api/Task/myTasks?org_id=$orgId');
    final Uri teamsTaskUri = Uri.parse('http://43.205.97.189:8000/api/Task/teamsTask?org_id=$orgId');


    final createdByMeResponse = await http.get(
      createdByMeUri,
      headers: {'accept': '*/*', 'Authorization': 'Bearer $storedData'},
    );

    final myTasksResponse = await http.get(
      myTasksUri,
      headers: {'accept': '*/*', 'Authorization': 'Bearer $storedData'},
    );

    final teamsTaskResponse = await http.get(
      teamsTaskUri,
      headers: {'accept': '*/*', 'Authorization': 'Bearer $storedData'},
    );

    if (createdByMeResponse.statusCode == 200 &&
        myTasksResponse.statusCode == 200 &&
        teamsTaskResponse.statusCode == 200) {
      final List<dynamic> createdByMeData = jsonDecode(createdByMeResponse.body);
      final List<dynamic> myTasksData = jsonDecode(myTasksResponse.body);
      final List<dynamic> teamsTaskData = jsonDecode(teamsTaskResponse.body);

      final List<Task> tasks = [
        ...createdByMeData.map((data) => Task.fromJson(data)),
        ...myTasksData.map((data) => Task.fromJson(data)),
        ...teamsTaskData.map((data) => Task.fromJson(data)),
      ];

      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.setTasks(tasks);
    } else {
      print('API Error: ${createdByMeResponse.statusCode}, ${myTasksResponse.statusCode}, ${teamsTaskResponse.statusCode}');
      // Handle the error and display an error message to the user
    }
  } catch (e) {
    print('Exception: $e');
    // Handle the error and display an error message to the user
  }
}

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardScreen()));
        return true; // Allow the back action to proceed
      },
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: AppColors.primaryColor2,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(height: 50,width: 150,child:  RoundTextField(
                onChanged: (query) {}, hintText: 'Search',
                icon: "assets/images/search_icon.png",
              ),),
            ),
          ],
        ),
        body: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
         final tasks = taskProvider.tasks; // Get the list of tasks from TaskProvider
        // Build your UI using the tasks list
          return Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 10),
                      SizedBox(
                        height: 50,
                        width: 100,
                        child: RoundButton(
                          title: "Team Task",
                          onPressed: () {
                            setState(() {
                              selectedOption = 'TeamTask';
                            });
                          },),
                      ),
                      SizedBox(width: 30),
                      SizedBox(
                        height: 50,
                        width: 100,
                        child: RoundButton(
                          title: "My Task",
                          onPressed: () {
                            setState(() {
                              selectedOption = 'MyTask';
                            });
                          },),
                      ),
                      SizedBox(width: 30),
                      SizedBox(
                        height: 50,
                        width: 120,
                        child: RoundButton(
                          title: "Created By Me",
                          onPressed: () {
                            setState(() {
                              selectedOption = 'CreatedByMe';
                            });
                          },),
                      ),
                      SizedBox(width: 10,),
                    ],
                  ),
                ),
                Expanded(
                  child: getCategoryWidget(),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              Map<String, String?> selectedOption = await showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return FilterOptionsModal();
                                },
                              );
                              if (selectedOption != null) {
                                // Handle selectedOption and update filters
                                print("SelectedOption: $selectedOption");
                                setState(() {
                                  selectedFilters[selectedOption.keys.first] = selectedOption.values.first;
                                });
                              }
                            },
                            icon: Icon(Icons.filter_alt_sharp, color: AppColors.secondaryColor2),
                          ),
                          Text("Filters",style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.secondaryColor2
                          ),),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );},),
      ),
    );
  }
}
