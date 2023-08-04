import 'dart:convert';
import 'package:Taskapp/view/tasks/taskDetails.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../common_widgets/round_button.dart';
import '../../common_widgets/round_textfield.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';

class MyTaskScreen extends StatefulWidget {
  const MyTaskScreen({super.key});

  @override
  State<MyTaskScreen> createState() => _MyTaskScreenState();
}

class _MyTaskScreenState extends State<MyTaskScreen> {
  List<Task> filteredMyTasks = [];
  List<Task> mytasks = [];

  Future<void> fetchMyTasks() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final String? orgId = prefs.getString('selectedOrgId');

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

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
            assignedTo: assignedTo,
            status: taskData['status'] ?? '',
            description: taskData['description'] ?? '',
            priority: taskData['priority'] ?? '',
            dueDate: taskData['due_Date'],
            createdBy: taskData['created_by'] ?? '',
            assignedTeam: assignedTeam, // New field containing the team name
          );
        }).toList();

        setState(() {
          mytasks = fetchedTasks;
          filteredMyTasks = fetchedTasks;
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
    fetchMyTasks();
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
                'My Tasks',
                style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredMyTasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    Task task = filteredMyTasks[index];
                    // Determine color based on the task's status
                    Color statusColor = Colors.grey; // Default color
                    switch (task.status) {
                      case 'InProgress':
                        statusColor = Colors.blue;
                        break;
                      case 'Completed':
                        statusColor = Colors.red;
                        break;
                      case 'ToDo':
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
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 2),
                        padding:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 9),
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 15, horizontal: 20),
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
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Owner: ',
                                          style: TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          task.createdBy!,
                                          style: TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
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
                                    SizedBox(
                                      height: 5,
                                    ),
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
                                    SizedBox(
                                      height: 5,
                                    ),
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
                                    SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 30,
                                          child:RoundButton(
                                      title: "View More",
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TaskDetailsScreen(
                                              taskId: task.taskId ?? "", // Provide a default value if taskId is null
                                              taskTitle: task.taskName ?? "", // Provide a default value if taskName is null
                                              assignedTo: task.assignedTo.join('\n') ?? "", // Provide a default value if assignedTo is null
                                              assignedTeam: task.assignedTeam ?? "", // Provide a default value if assignedTeam is null
                                              priority: task.priority ?? "", // Provide a default value if priority is null
                                              description: task.description ?? "", // Provide a default value if description is null
                                              dueDate: task.dueDate ?? "",
                                              status: task.status ?? " ",
                                              owner: task.createdBy ?? " ",// Provide a default value if dueDate is null
                                            ),
                                          ),
                                        );
                                      },
                                    ),
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
                                            },
                                          ),
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

void _showViewMembersDialog(BuildContext context, String assignedToUsers, String assignedTeam) {
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
              SizedBox(height: 8),
              if (assignedToUsers.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: assignedToUsers.split(',').length,
                  itemBuilder: (context, index) {
                    String user = assignedToUsers.split(',')[index].trim();
                    return ListTile(
                      title: Row(
                        children: [
                          Text(
                            user,
                            style: TextStyle(
                              color: AppColors.primaryColor2,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              // Implement the logic to remove the user
                            },
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
                    SizedBox(height: 8),
                    ListTile(
                      title: Row(
                        children: [
                          Text(
                            assignedTeam,
                            style: TextStyle(
                              color: AppColors.primaryColor2,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              // Implement the logic to remove the team
                            },
                            child: Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                              size: 20,
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
      );
    },
  );
}

String formatDate(String? dateString) {
  print('Raw Date String: $dateString');
  if (dateString == null || dateString.isEmpty) {
    return 'N/A'; // Return "N/A" for null or empty date strings
  }
  try {
    final dateTime = DateTime.parse(dateString);
    final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return formattedDate;
  } catch (e) {
    print('Error parsing date: $e');
    return 'Invalid Date'; // Return a placeholder for invalid date formats
  }
}
