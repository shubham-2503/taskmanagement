import 'dart:convert';
import 'package:Taskapp/view/tasks/taskDetails.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../common_widgets/round_button.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';


class TeamTaskScreen extends StatefulWidget {
  const TeamTaskScreen({super.key});

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
      final String? orgId = prefs.getString('selectedOrgId');

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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchTeamTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      task.taskName,
                                      style: TextStyle(
                                          color: AppColors.secondaryColor2,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Owner: ',
                                          style: TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                            task.owner!,
                                          style: TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Text(
                                          'Status: ',
                                          style: TextStyle(
                                              color: AppColors.secondaryColor2,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          task.status,
                                          style: TextStyle(
                                              color: statusColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Text(
                                          'Priority: ',
                                          style: TextStyle(
                                              color: AppColors.secondaryColor2,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          task.priority,
                                          style: TextStyle(
                                              color: priorityColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Row(
                                      children: [
                                        Text(
                                          'Due Date: ',
                                          style: TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          formatDate(task.dueDate) ?? '',
                                          style: TextStyle(
                                              color: AppColors.secondaryColor2,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 30,
                                          child: RoundButton(
                                              title: "View More",
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TaskDetailsScreen(
                                                          taskId: task.taskId ?? "", // Provide a default value if taskId is null
                                                          taskTitle: task.taskName ?? "", // Provide a default value if taskName is null
                                                          assignedTo: task.assignedTo.join('\n') ?? "", // Provide a default value if assignedTo is null
                                                          assignedTeam: task.assignedTeam ?? "", // Provide a default value if assignedTeam is null
                                                          priority: task.priority ?? "", // Provide a default value if priority is null
                                                          description: task.description ?? "", // Provide a default value if description is null
                                                          dueDate: task.dueDate ?? "",
                                                        status: task.status ?? " ",
                                                        owner: task.owner ?? " ",),
                                                  ),
                                                );
                                              }),
                                        ),
                                        SizedBox(
                                          width: 30,
                                        ),
                                        SizedBox(
                                          width: 120,
                                          height: 30,
                                          child: RoundButton(
                                              title: "Assigned To",
                                              onPressed: () {
                                                String assignedToUsers = task.assignedTo.join('\n'); // Join the list into a single string with line breaks
                                                _showViewMembersDialog(context, assignedToUsers, task.assignedTeam ?? "");
                                              }),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 15,
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

void _showViewMembersDialog(BuildContext context,String assignedToUsers, String assignedTeam) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display the "Assigned To" users
              Text(
                'Assigned To User:',
                style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                title: InkWell(
                  onTap: (){

                  },
                  child: Text(
                    assignedToUsers,
                    style: TextStyle(
                      color: AppColors.primaryColor2,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              if (assignedTeam.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assigned Team:',
                      style: TextStyle(
                        color: AppColors.secondaryColor2,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        assignedTeam,
                        style: TextStyle(
                          color: AppColors.primaryColor2,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    },
  );
}

String? formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }

  final dateTime = DateTime.parse(dateString);
  final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

  return formattedDate;
}



