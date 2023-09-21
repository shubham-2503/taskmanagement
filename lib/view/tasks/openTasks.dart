import 'dart:convert';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:Taskapp/view/tasks/taskDetails.dart';
import 'package:Taskapp/view/tasks/widgets/taskdetailsModal.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Task> filteredOpenTasks = [];
  List<Task> opentasks = [];

  Future<void> fetchOpenTasks() async {
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

      final url = 'http://43.205.97.189:8000/api/Task/myTasks?org_id=$orgId'; // Replace this with the correct API endpoint for fetching all tasks

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
              ? users.map((user) => user['user_name'].toString()).toList()
              : [];
          final List<String> assignedTo = assignedUsers; // Assign the list of users directly

          // Extract the team name from the "teams" list.
          // Extract the team name from the "teams" list.
          final List<dynamic> teams = taskData['teams'];
          final List<String> assignedTeams = teams.isNotEmpty
              ? teams.map((team) => team['teamName'].toString()).toList()
              : [];
          // Assuming the 'assignedTo' and 'assignedTeam' properties of 'task' are either List<String> or comma-separated strings.
          print("AssignedTeam: $assignedTeams");

          return Task(
            uniqueId: taskData['unique_id'] ?? '',
            taskId: taskData['id'],
            taskName: taskData['task_name'] ?? '',
            assignedTo: assignedTo,
            status: taskData['status'] ?? '',
            description: taskData['description'] ?? '',
            priority: taskData['priority'] ?? '',
            dueDate: taskData['due_Date'],
            createdBy: taskData['created_by'] ?? '',
            assignedTeam: assignedTeams, // New field containing the team name
          );
        }).toList();

        // Filter tasks that are not in "Completed" status
        List<Task> openTasks = fetchedTasks.where((task) => task.status != 'Completed').toList();
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

  void filterOpenTasks(String query) {
    setState(() {
      if (query.length >= 3) {
        print("Filtering with query: $query");
        filteredOpenTasks = opentasks.where((opentask) =>
            opentask.taskName.toLowerCase().contains(query.toLowerCase())).toList();
      } else {
        // Filter with an empty query or a query with less than 3 characters
        filteredOpenTasks = opentasks.toList();
      }
    });
  }


  void _deleteTask(String taskId) async {
    try {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    SharedPreferences prefs =
                    await SharedPreferences.getInstance();
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

                    final response = await http.delete(
                      Uri.parse(
                          'http://43.205.97.189:8000/api/Task/tasks/$taskId'),
                      headers: {
                        'accept': '*/*',
                        'Authorization': "Bearer $storedData",
                      },
                    );

                    print("Delete API response: ${response.body}");
                    print("Delete StatusCode: ${response.statusCode}");

                    if (response.statusCode == 200) {
                      showDialog(
                        context: _scaffoldKey.currentContext ?? context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Thank You'),
                            content: Text("Task deleted successfully."),
                            actions: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    opentasks.removeWhere((task) => task.taskId == taskId);
                                    filteredOpenTasks.removeWhere((task) => task.taskId == taskId);
                                  });
                                },
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                      color: AppColors.blackColor, fontSize: 20),
                                ),
                              )
                            ],
                          );
                        },
                      );
                      fetchOpenTasks();
                      print('Task deleted successfully.');
                    } else {
                      print('Failed to delete task.');
                      // Handle other status codes, if needed
                    }
                  } catch (e) {
                    print('Error deleting task: $e');
                  }
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      ).then((value) {

      });
    } catch (e) {
      print('Error showing delete confirmation dialog: $e');
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
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardScreen()));
        return true; // Allow the back action to proceed
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(height: 50,width: 150,child:  RoundTextField(
                onChanged: (query) => filterOpenTasks(query), hintText: 'Search',
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
                              vertical: 8, horizontal: 0),
                          padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 7),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 5),
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            'Task Id: ',
                                            style: TextStyle(
                                                color: AppColors.blackColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            width:110,
                                            child: Text(
                                              task.uniqueId?? '',
                                              style: TextStyle(
                                                  color: AppColors.secondaryColor2,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Task Name: ',
                                            style: TextStyle(
                                                color: AppColors.blackColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            width: 90,
                                            child: Text(
                                              task.taskName.length >10
                                                  ? task.taskName.substring(0,10) + '...'
                                                  : task.taskName,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: AppColors.secondaryColor2,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Status: ',
                                            style: TextStyle(
                                                color: AppColors.blackColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            task.status,
                                            style: TextStyle(
                                                color: AppColors.secondaryColor2,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.remove_red_eye, color: AppColors.secondaryColor2,size: 20,),
                                  onPressed: () {
                                    _showViewTaskDialog(task);
                                  },
                                ),
                                SizedBox(width: 1,),// Add a Spacer to push the menu image to the end
                                IconButton(
                                  icon: Icon(Icons.edit, color: AppColors.secondaryColor2, size: 20,),
                                  onPressed: () async {
                                    bool? edited = await showModalBottomSheet<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return TaskDetailsModal(task: task,);
                                      },
                                    );

                                    if (edited == true) {
                                      await fetchOpenTasks();
                                    }
                                  },
                                ),
                                SizedBox(width: 1,),
                                IconButton(
                                  icon: Icon(Icons.delete, color: AppColors.secondaryColor2,size: 20,),
                                  onPressed: () {
                                    _deleteTask(task.taskId!);
                                  },
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
      ),
    );
  }
  void _showViewTaskDialog(Task task) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Display the task name
                Center(
                  child: Text(
                    '${task.taskName}',
                    style: TextStyle(
                      color: AppColors.secondaryColor2,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Display assigned users
                Text(
                  'Assigned Users:',
                  style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ...task.assignedTo!.map((user) => ListTile(
                  title: Text(
                    user,
                    style: TextStyle(
                      color: AppColors.primaryColor2,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
                SizedBox(height: 16),
                // Display assigned teams if applicable
                if (task.assignedTeam != null && task.assignedTeam!.isNotEmpty)
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
                      ...task.assignedTeam!.map((team) => ListTile(
                        title: Text(
                          team,
                          style: TextStyle(
                            color: AppColors.primaryColor2,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      )),
                    ],
                  ),
                SizedBox(height: 16),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_red_eye, color: AppColors.primaryColor2),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskDetailsScreen(task: task)));
                      },
                    ),
                    Text(
                      'TaskDetails',
                      style: TextStyle(
                        color: AppColors.secondaryColor2,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
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
}




