import 'dart:convert';
import 'package:Taskapp/view/tasks/MistaskCreation.dart';
import 'package:Taskapp/view/tasks/widgets/taskdetailsModal.dart';
import 'package:Taskapp/view/tasks/taskDetails.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../common_widgets/round_textfield.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import 'package:intl/intl.dart';

class MyTaskScreen extends StatefulWidget {
  final VoidCallback refreshCallback;
  final Map<String, String?> selectedFilters;

  const MyTaskScreen({super.key, required this.refreshCallback, required this.selectedFilters});

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
      String? orgId = prefs.getString("selectedOrgId"); // Get the selected organization ID

      if (orgId == null) {
        // If the user hasn't switched organizations, use the organization ID obtained during login time
        orgId = prefs.getString('org_id') ?? "";
      }

      print("OrgId: $orgId");


      if (orgId == null) {
        throw Exception('orgId not found locally');
      }

      // Use the selected filters to build the query parameters
      Map<String, String?> queryParameters = {
        'org_id': orgId,
        ...widget.selectedFilters,
      };

      final url = Uri.http('43.205.97.189:8000', '/api/Task/myTasks', queryParameters);

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(url, headers: headers);

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
            taskId: taskData['id'],
            uniqueId: taskData['unique_id'] ?? '',
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

  void filterMyTasks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMyTasks=List.from( mytasks );
      } else {
        filteredMyTasks= mytasks.where((task){
          final taskName=task.taskName.toLowerCase();
          final status =task.status.toLowerCase();
          final taskid=task.uniqueId?.toLowerCase();
          final lowercaseQuery = query.toLowerCase();
          return taskName.contains(lowercaseQuery) || status.contains(lowercaseQuery) || taskid!.contains(lowercaseQuery);
        }).toList();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMyTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Removes the back button
        iconTheme: IconThemeData(
          color: AppColors.whiteColor,
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // To separate the search field and the "Add Projects" button
          crossAxisAlignment: CrossAxisAlignment.center, // Align items vertically to the center
          children: <Widget>[
            // Search Field
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                height: 55,
                width: 160,
                child: SingleChildScrollView(
                  child: RoundTextField(
                    onChanged: (query) {
                      filterMyTasks(query);
                    },
                    hintText: 'Search',
                    icon: "assets/images/search_icon.png",
                  ),
                ),
              ),
            ),

            // "Add Projects" Button
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MisTaskCreationScreen()),
                );

                if (result == true) {
                  // Refresh the data by calling your fetchTeamProjects method
                  // Or any other method to refresh
                  fetchMyTasks();
                }
              },
              child: Row(
                children: [
                  Icon(Icons.add_circle, color: AppColors.secondaryColor2),
                  Text(
                    "Add Projects",
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.secondaryColor2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Container(
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
                                        width: 110,
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
                              icon: Icon(Icons.remove_red_eye, color: AppColors.secondaryColor2),
                              onPressed: () {
                                _showViewTaskDialog(task);
                              },
                            ), // Add a Spacer to push the menu image to the end
                            GestureDetector(
                              onTap: () async {
                                final result = await showModalBottomSheet<bool>(
                                  context: context,
                                  builder: (context) {
                                    return TaskDetailsModal(task: task);
                                  },
                                );

                                if (result == true) {
                                  await fetchMyTasks();
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







