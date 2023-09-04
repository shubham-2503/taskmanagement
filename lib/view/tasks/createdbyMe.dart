import 'dart:convert';
import 'package:Taskapp/view/tasks/MistaskCreation.dart';
import 'package:Taskapp/view/tasks/taskDetails.dart';
import 'package:Taskapp/view/tasks/taskModal.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../common_widgets/round_textfield.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';



class CreatedByMe extends StatefulWidget {
  final VoidCallback refreshCallback;
  final Map<String, String?> selectedFilters;

  const CreatedByMe({super.key, required this.refreshCallback, required this.selectedFilters});

  @override
  State<CreatedByMe> createState() => _CreatedByMeState();
}

class _CreatedByMeState extends State<CreatedByMe> {
  List<Task> filteredTasks = [];
  List<Task> ByMytasks = [];

  Future<void> fetchCreatedByMeTasks() async {
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

      final url = Uri.http('43.205.97.189:8000', '/api/Task/createdByMe', queryParameters);

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


          return Task(
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

        setState(() {
          ByMytasks = fetchedTasks;
          filteredTasks = fetchedTasks;
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
      if (query.length >= 3) {
        print("Filtering with query: $query");
        filteredTasks = ByMytasks.where((mytask) =>
            mytask.taskName.toLowerCase().contains(query.toLowerCase())).toList();
      } else {
        // Filter with an empty query or a query with less than 3 characters
        filteredTasks = ByMytasks.toList();
      }
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchCreatedByMeTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColors.whiteColor,
        ),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MisTaskCreationScreen()),
                  );

                  if (result == true) {
                    fetchCreatedByMeTasks();
                  }
                },
                icon: Icon(Icons.add_circle, color: AppColors.secondaryColor2),
              ),
              Text("Add tasks",style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor2
              ),),
            ],
          ),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            Text(
              'Created By Me',
              style: TextStyle(
                  color: AppColors.secondaryColor2,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTasks.length,
                itemBuilder: (BuildContext context, int index) {
                  Task task = filteredTasks[index];
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
                            Spacer(),
                            IconButton(
                              icon: Icon(Icons.remove_red_eye, color: AppColors.secondaryColor2),
                              onPressed: () {
                                _showViewTaskDialog(task);
                              },
                            ),// Add a Spacer to push the menu image to the end
                            GestureDetector(
                              onTap: () async {
                                bool? shouldRefresh = await showModalBottomSheet<bool>(
                                  context: context,
                                  builder: (context) {
                                    return TaskDetailsModal(task: task);
                                  },
                                );

                                if (shouldRefresh ?? false) {
                                  await fetchCreatedByMeTasks();
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
                  trailing: IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      color: AppColors.secondaryColor2,
                    ),
                    onPressed: () async {
                      // Handle delete action
                    },
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
                        trailing: IconButton(
                          icon: Icon(
                            Icons.remove_circle,
                            color: AppColors.secondaryColor2,
                          ),
                          onPressed: () async {
                            // Handle delete action
                          },
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

String? formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }

  final dateTime = DateTime.parse(dateString);
  final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

  return formattedDate;
}



