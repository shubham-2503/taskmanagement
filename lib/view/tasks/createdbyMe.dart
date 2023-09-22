import 'package:Taskapp/view/tasks/widgets/taskdetailsModal.dart';
import 'dart:convert';
import 'package:Taskapp/view/tasks/MistaskCreation.dart';
import 'package:Taskapp/view/tasks/editCreatetasks.dart';
import 'package:Taskapp/view/tasks/taskDetails.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../common_widgets/round_button.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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

        // Apply a custom sorting function to move "Completed" tasks to the bottom
        fetchedTasks.sort((a, b) {
          if (a.status == "Completed" && b.status != "Completed") {
            return 1; // Move "Completed" task to the bottom
          } else if (a.status != "Completed" && b.status == "Completed") {
            return -1; // Keep "Completed" task at the bottom
          } else {
            return 0; // Keep the order as is
          }
        });

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
                                    ByMytasks.removeWhere((task) => task.taskId == taskId);
                                    filteredTasks.removeWhere((task) => task.taskId == taskId);
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
                      fetchCreatedByMeTasks();
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
    fetchCreatedByMeTasks();
  }


  void filterMyTasks(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTasks=List.from( ByMytasks );
      } else {
        filteredTasks= ByMytasks.where((task){
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
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
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
                  fetchCreatedByMeTasks();
                }
              },
              child: Row(
                children: [
                  Icon(Icons.add_circle, color: AppColors.secondaryColor2),
                  Text(
                    "Add Tasks",
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
                                  await fetchCreatedByMeTasks();
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
                GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskDetailsScreen(task: task)));
                  },
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_red_eye, color: AppColors.primaryColor2),
                        onPressed: () {
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskDetailsScreen(task: task)));
                        },
                      ),
                      Text(
                        'Comments & History',
                        style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}



