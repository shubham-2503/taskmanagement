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

class OpenTaskScreen extends StatefulWidget {
  const OpenTaskScreen({super.key});

  @override
  State<OpenTaskScreen> createState() => _OpenTaskScreenState();
}

class _OpenTaskScreenState extends State<OpenTaskScreen> {
  TextEditingController _mentionController = TextEditingController();
  List<Task> filteredOpenTasks = [];
  List<Task> opentasks = [];

  Future<void> fetchOpenTasks() async {
    try {
      final url = 'http://43.205.97.189:8000/api/Task/myTasks'; // Replace this with the correct API endpoint for fetching all tasks

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
        List<Task> fetchedTasks = responseData.map((taskData) {
          return Task(
            taskName: taskData['task_name'] ?? '',
            assignedTo: taskData['assignee'] ?? '',
            status: taskData['status'] ?? '',
            description: taskData['description'] ?? '',
            priority: taskData['priority'] ?? '',
            dueDate: taskData['dueDate'],
          );
        }).toList();

        // Filter tasks that are in "Open" status (ToDo tasks)
        List<Task> openTasks = fetchedTasks.where((task) => task.status == 'ToDo').toList();
        setState(() {
          opentasks = openTasks;
          filteredOpenTasks = openTasks;
        });

        // Store the tasks locally using SharedPreferences
        final String openTasksKey = 'openTasksKey';
        final String openTasksJson = jsonEncode(openTasks); // Convert the list of tasks to a JSON string
        prefs.setString(openTasksKey, openTasksJson);

        print("Open tasks: $openTasks");
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
    fetchOpenTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            children: [
              Text(
                'Open Tasks',
                style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredOpenTasks.length,
                  itemBuilder: (BuildContext context, int index) {
                    Task task = filteredOpenTasks[index];
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
                        priorityColor = AppColors.primaryColor2;
                        break;
                      case 'Low':
                        priorityColor = Colors.green;
                        break;
                      case 'Critical':
                        priorityColor = Colors.red;
                        break;
                      case 'Medium':
                        priorityColor = Colors.blue;
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
                                          'Assignee: ',
                                          style: TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          task.assignedTo ?? 'N/A',
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
                                          child: RoundButton(
                                              title: "View More",
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TaskDetailsScreen(
                                                          taskTitle: '',
                                                          assignee: '',
                                                        ),
                                                  ),
                                                );
                                              }),
                                        ),
                                        SizedBox(
                                          width: 30,
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
    return 'Invalid Date'; // Return a placeholder for invalid date formats
  }
}
