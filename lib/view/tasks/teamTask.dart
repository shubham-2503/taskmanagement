import 'dart:convert';
import 'package:Taskapp/view/tasks/taskDetails.dart';
import 'package:Taskapp/view/tasks/taskModal.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../common_widgets/round_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/dialogUtils.dart';


class TeamTaskScreen extends StatefulWidget {
  final VoidCallback refreshCallback;
  const TeamTaskScreen({super.key, required this.refreshCallback});

  @override
  State<TeamTaskScreen> createState() => _TeamTaskScreenState();
}

class _TeamTaskScreenState extends State<TeamTaskScreen> {
  List<Task> filteredTeamTasks = [];
  List<Task> teamTasks = [];

  Future<void> fetchTeamTasks() async {
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
      final url = 'http://43.205.97.189:8000/api/Task/teamsTask?org_id=$orgId';

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
          // Extract the user's name from the "users" list.
          final List<dynamic> users = taskData['users'];
          final List<String> assignedUsers = users.isNotEmpty
              ? users.map((user) => user['user_name'] as String).toList()
              : [];
          final List<String> assignedTo = assignedUsers; // Use List<String> instead of String

          // Extract the team name from the "teams" list.
          final List<dynamic> teams = taskData['teams'];
          final String assignedTeam =
          teams.isNotEmpty ? teams[0]['teamName'] as String : '';
          // Assuming the 'assignedTo' and 'assignedTeam' properties of 'task' are either List<String> or comma-separated strings.


          return Task(
            taskId: taskData['id'],
            taskName: taskData['task_name'] ?? '',
            owner: taskData['created_by'] ?? '',
            assignedTo:assignedTo,
            assignedTeam: assignedTeam,
            status: taskData['status'] ?? '',
            description: taskData['description'] ?? '',
            priority: taskData['priority'] ?? '',
            dueDate: taskData['due_Date'] is bool ? null : taskData['due_Date'],
          );
        }).toList();

        setState(() {
          teamTasks = fetchedTasks;
          filteredTeamTasks = fetchedTasks;
        });
      } else {
        print('Error fetching tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  void filterTeamTasks(String query) {
    setState(() {
      if (query.length >= 3) {
        print("Filtering with query: $query");
        filteredTeamTasks = teamTasks.where((teamtask) =>
            teamtask.taskName.toLowerCase().contains(query.toLowerCase())).toList();
      } else {
        // Filter with an empty query or a query with less than 3 characters
        filteredTeamTasks = teamTasks.toList();
      }
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTeamTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColors.whiteColor,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(height: 50,width: 150,child:  RoundTextField(
              onChanged: (query) => filterTeamTasks(query), hintText: 'Search',
              icon: "assets/images/search_icon.png",
            ),),
          )
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            children: [
              Text(
                'My Team Tasks',
                style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTeamTasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    Task task = filteredTeamTasks[index];
                    // Determine color based on the task's status
                    Color statusColor = Colors.grey; // Default color
                    switch (task.status) {
                      case 'InProgress':
                        statusColor = Colors.blue;
                        break;
                      case 'Completed':
                        statusColor = Colors.red;
                        break;
                      case 'To Do':
                        statusColor = AppColors.primaryColor2;
                        break;
                      case 'transferred':
                        statusColor = Colors.black54;
                        break;
                    // Add more cases for different statuses if needed
                    }
                    // Determine color based on the task's priority
                    Color priorityColor = Colors.grey; // Default color
                    switch (task.priority) {
                      case 'High':
                        priorityColor = Color(0xFFE1B297);
                        break;
                      case 'Low':
                        priorityColor = Colors.green;
                        break;
                      case 'Critical':
                        priorityColor = Colors.red;
                        break;
                      case 'Medium':
                        priorityColor = Colors.yellow;
                        break;
                    // Add more cases for different priorities if needed
                    }
                    return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                        padding: EdgeInsets.symmetric(vertical: 8,horizontal: 9),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              AppColors.primaryColor2.withOpacity(0.3),
                              AppColors.primaryColor1.withOpacity(0.3)
                            ]),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(
                                    task.taskName,
                                    style: TextStyle(
                                      color: AppColors.secondaryColor2,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Spacer(), // Add a Spacer to push the menu image to the end
                              GestureDetector(
                                onTap: () async {
                                  bool? shouldRefresh = await showModalBottomSheet<bool>(
                                    context: context,
                                    builder: (context) {
                                      return TaskDetailsModal(task: task);
                                    },
                                  );

                                  if (shouldRefresh ?? false) {
                                    await fetchTeamTasks();
                                  }
                                },
                                child: Image.asset(
                                  "assets/images/menu.png",
                                  width: 40,
                                  height: 20,
                                ),
                              ),
                            ],
                          ),
                        ));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _showTaskDetailsBottomSheet(BuildContext context, Task task) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: double.infinity,
        width: double .infinity,
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                text: "Task Name: ",
                style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
                children: [
                  TextSpan(
                    text: "${task.taskName}",
                    style: TextStyle(
                      // Add any specific styles for the plan name here, if needed
                      color: AppColors.blackColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: "Task Description: ",
                style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
                children: [
                  TextSpan(
                    text: "${task.description}",
                    style: TextStyle(
                      // Add any specific styles for the plan name here, if needed
                      color: AppColors.blackColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: "DueDate: ",
                style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
                children: [
                  TextSpan(
                    text: "${task.dueDate}",
                    style: TextStyle(
                      // Add any specific styles for the plan name here, if needed
                      color: AppColors.blackColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: "Owner: ",
                style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
                children: [
                  TextSpan(
                    text: "${task.owner}",
                    style: TextStyle(
                      // Add any specific styles for the plan name here, if needed
                      color: AppColors.blackColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                text: "Assignee: ",
                style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
                children: [
                  TextSpan(
                    text: "${task.assignedTo}",
                    style: TextStyle(
                      // Add any specific styles for the plan name here, if needed
                      color: AppColors.blackColor,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: task.assignedTeam?.isNotEmpty == true,
              child: RichText(
                text: TextSpan(
                  text: "Assignee Team: ",
                  style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: "${task.assignedTeam}",
                      style: TextStyle(
                        // Add any specific styles for the plan name here, if needed
                        color: AppColors.blackColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ); // Pass the 'task' object to the modal
    },
  );
}

void _showViewMembersDialog(BuildContext context, String assignedToUsers, String assignedTeam,String taskId) async {
  showViewMembersDialog(context, assignedToUsers, assignedTeam,taskId);
}


String? formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }

  final dateTime = DateTime.parse(dateString);
  final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

  return formattedDate;
}



