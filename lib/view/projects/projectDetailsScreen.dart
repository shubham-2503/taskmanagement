import 'dart:convert';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/tasks/editCreatetasks.dart';
import 'package:http/http.dart' as http;
import 'package:Taskapp/view/projects/Projecttaskcreation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/project_model.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import 'myProjects/editMyProjects.dart';
import 'package:intl/intl.dart';


class ProjectDetailsScreen extends StatefulWidget {
  final Project project;
  final String? projectId;
  final String projectName;
  final String assigneeTo;
  final String assigneeTeam;
  final String? status;
  final String createdBy;
  String? dueDate;
  final List<String>? attachments;
  final bool active;


  ProjectDetailsScreen({
    required this.projectName,
    required this.assigneeTo,
    required this.assigneeTeam,
    this.status,
    this.dueDate, required this.projectId,
    required this.createdBy, this.attachments, required this.active, required this.project,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  String? _selectedStatus;
  bool _isActive = true;
  List<Task> tasks = [];
  late Project project;

  @override
  void initState() {
    super.initState();
    final projectId = widget.projectId;
    fetchProjectTasks(widget.projectId!);
  }

  Future<void> updateTask(Map<String, dynamic> taskData) async {
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

    final String url = 'http://43.205.97.189:8000/api/Task/editTasks?org_id=$orgId';
    final Map<String, String> headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $storedData',
      'Content-Type': 'application/json',
    };

    try {
      final http.Response response = await http.patch(Uri.parse(url), headers: headers, body: jsonEncode(taskData));

      print("Payload (taskData): ${jsonEncode(taskData)}");
      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        // Task update was successful
        // Handle the response as needed
        // Get the UUIDs of the assigned users from their names
        List<String> assignedUserUuids = await _getUserUuidsFromNames(taskData["assigned_user"]);

         // Update the "assigned_user" field in the taskData map with the list of UUIDs
        taskData["assigned_user"] = assignedUserUuids;

        print("Tasks Updated Successfully");
      } else {
        // Task update failed
        // Handle the error response as needed
        print("Tasks failed: ${response.statusCode}");
      }
    } catch (e) {
      // An error occurred during the PATCH request
      print('Error updating task: $e');
    }
  }

  Future<void> fetchProjectTasks(String projectId) async {
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

      final url = 'http://43.205.97.189:8000/api/Task/myProjectTask?project_id=$projectId&org_id=$orgId';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      print("response: ${response.body}");
      print("Statuscode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          tasks = responseData.map((taskData) {
            List<String> assignedToUsers = (taskData['users'] as List<dynamic>)
                .map((userData) => userData['user_name'].toString())
                .toList();
            List<String> assignedTeam = (taskData['teams'] as List<dynamic>)
                .map((teamData) => teamData['teamName'].toString())
                .toList();

            return Task(
              taskId: taskData['id'], // This should be the taskId received from the API
              taskName: taskData['task_name'] ?? '',
              description: taskData['description'],
              assignedTo: assignedToUsers,
              assignedTeam: assignedTeam,
              status: taskData['status'],
              owner: taskData['created_by'],
              priority: taskData['priority'] ?? '',
              dueDate: taskData['due_Date'] ?? '',
            );
          }).toList();
        });

      } else {
        print('Error fetching tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'InProgress':
        return Colors.blue;
      case 'Completed':
        return Colors.red;
      case 'ToDo':
        return AppColors.primaryColor2;
      case 'transferred':
        return Colors.black54;
      default:
        return Colors.grey; // Default color if status doesn't match any case
    }
  }

  Future<void> fetchProjectDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://43.205.97.189:8000/api/Task/taskDetails?taskId=${widget.project.id}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          final projectJson = data.firstWhere(
                (project) => project['id'] == widget.project.id,
            orElse: () => null,
          );

          if (projectJson != null) {
            final projectDetail = Project.fromJson(projectJson);

            setState(() {
              project = projectDetail;
            });
          }
        }
      } else {
        print('API Error: Status Code ${response.statusCode}');
        // Handle error scenario
      }
    } catch (e) {
      print('Exception in fetchProjectDetails: $e');
      // Handle exception
    }
  }

  @override
   Widget build(BuildContext context) {
    final ProjectId = widget.projectId;
    final projectName = widget.projectName;
    final assignee = widget.assigneeTo;
    final assigneeteam = widget.assigneeTeam;
    final dueDate = widget.dueDate;
    final status = widget.status;
    final owner = widget.createdBy;
    final attachment = widget.attachments;
    bool active = widget.active;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 50, left: 10, right: 10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        InkWell(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            child: Icon(Icons.arrow_back_ios)),
                        Image.asset("assets/images/magic.png", width: 30,),
                        SizedBox(width: 5,),
                        Text(
                          "Project Name: $projectName",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondaryColor2
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () async {
                            print("Assigned Team: $assigneeteam");
                            await showModalBottomSheet(
                            context: context,
                            // isScrollControlled: true,
                            builder: (BuildContext context) {
                              return EditMyProject(project: widget.project);
                            },
                            );
                            // After closing the modal, you can refresh your data here
                            // For example, you can call a function to reload the projects
                           fetchProjectDetails();
                          },
                          icon: Icon(Icons.edit, color: AppColors.primaryColor1),
                        ),
                        SizedBox(width: 2,),
                        IconButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProjectTaskCreationScreen(ProjectId: ProjectId!, ProjectName: widget.projectName)),
                            );
                            if (result == true) {
                              // Refresh the data by calling your fetchTeamProjects method
                              fetchProjectTasks(ProjectId!); // Or any other method to refresh data
                            }
                          },
                          icon: Icon(Icons.add_task, color: AppColors.secondaryColor1),
                        ),
                        IconButton(
                          onPressed: () async {},
                          icon: Icon(Icons.add_circle, color: AppColors.secondaryColor1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Row(
                children: [
                  Icon(Icons.timelapse,color: AppColors.secondaryColor2,),
                  SizedBox(width: 10,),
                  Text(
                    'Status: ',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text("$status"),
                  Visibility(
                    visible: attachment != null && assigneeteam.isNotEmpty,
                    child: Row(
                      children: [
                        Image.asset("assets/images/att.png", width: 30, height: 20,),
                        Text(
                          'Attachments',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Row(
                children: [
                  Image.asset("assets/images/pers.png", width: 30, height: 20,),
                  Text(
                    'Assignee To: ',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(assignee, style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryColor2
                  ),),
                ],
              ),
              SizedBox(height: 12.0),
              Visibility(
                visible: assigneeteam != null && assigneeteam.isNotEmpty,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/pers.png",
                            width: 30,
                            height: 20,
                          ),
                          Text(
                            'Assignee Team: ',
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        assigneeteam,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryColor2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.create,color: AppColors.secondaryColor2,),
                  Text(
                    'Created By: ',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(owner, style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryColor2
                  ),),
                  Image.asset("assets/icons/date.png", width: 30, height: 20,),
                  Text(
                    'Due Date: ',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                  Text(dueDate!.isNotEmpty ? dueDate : 'No Due Date', style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primaryColor2
                  ),),
                ],
              ),
              SizedBox(height: 16.0),
              Visibility(
                visible: tasks.isNotEmpty,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Image.asset("assets/icons/activity_select_icon.png", width: 30, height: 20,),
                        SizedBox(width: 10,),
                        Text(
                          'Tasks',
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                      SizedBox(height: 20,),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppColors.primaryColor2.withOpacity(0.3),
                            AppColors.primaryColor1.withOpacity(0.3)
                          ]),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: tasks.length,
                                itemBuilder: (context, index) {
                                  Task task = tasks[index];
                                  Color statusColor = getStatusColor(task.status);
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: statusColor,
                                              radius: 6,
                                            ),
                                            SizedBox(width: 10,),
                                            Text(
                                              task.taskName,
                                              style: TextStyle(
                                                color: AppColors.secondaryColor2,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      IconButton(
                                        onPressed: () {
                                          // Show modal when the icon is pressed
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return Container(
                                                padding: EdgeInsets.all(16),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    ListTile(
                                                      onTap: () {
                                                        // Close the modal
                                                        Navigator.pop(context);
                                                        // Show the popup dialog with task details and options
                                                        showModalBottomSheet(
                                                          context: context,
                                                          // isScrollControlled: true,
                                                          builder: (BuildContext context) {
                                                            return EditCreatedByTask(task: task,);
                                                          },
                                                        );
                                                      },
                                                      title: Text('Edit Tasks'),
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        // Close the modal
                                                        Navigator.pop(context);
                                                        // Show the popup dialog with task details
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            Task task = tasks[index]; // Assuming tasks is a List containing the task object
                                                            return AlertDialog(
                                                              title: Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  RichText(
                                                                    text: TextSpan(
                                                                      text: "Task: ",
                                                                      style: TextStyle(
                                                                          color: AppColors.secondaryColor2,
                                                                          fontSize: 18,
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
                                                                ],
                                                              ),
                                                              content: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  RichText(
                                                                    text: TextSpan(
                                                                      text: "Description: ",
                                                                      style: TextStyle(
                                                                          color: AppColors.secondaryColor2,
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.bold
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text: "${task.description}",
                                                                          style: TextStyle(
                                                                            // Add any specific styles for the plan name here, if needed
                                                                            color: AppColors.blackColor,
                                                                            fontSize: 12,
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
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.bold
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text: "${formatDate(task.dueDate) ?? ''}",
                                                                          style: TextStyle(
                                                                            // Add any specific styles for the plan name here, if needed
                                                                            color: AppColors.blackColor,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  RichText(
                                                                    text: TextSpan(
                                                                      text: "Status: ",
                                                                      style: TextStyle(
                                                                          color: AppColors.secondaryColor2,
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.bold
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text: "${task.status}",
                                                                          style: TextStyle(
                                                                            // Add any specific styles for the plan name here, if needed
                                                                            color: AppColors.blackColor,
                                                                            fontSize: 12,
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
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.bold
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text: "${task.owner}",
                                                                          style: TextStyle(
                                                                            // Add any specific styles for the plan name here, if needed
                                                                            color: AppColors.blackColor,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  RichText(
                                                                    text: TextSpan(
                                                                      text: "AssignedTo: ",
                                                                      style: TextStyle(
                                                                          color: AppColors.secondaryColor2,
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.bold
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text: "${task.assignedTo.join(", ")}",
                                                                          style: TextStyle(
                                                                            // Add any specific styles for the plan name here, if needed
                                                                            color: AppColors.blackColor,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  RichText(
                                                                    text: TextSpan(
                                                                      text: "Priority: ",
                                                                      style: TextStyle(
                                                                          color: AppColors.secondaryColor2,
                                                                          fontSize: 12,
                                                                          fontWeight: FontWeight.bold
                                                                      ),
                                                                      children: [
                                                                        TextSpan(
                                                                          text: "${task.priority}",
                                                                          style: TextStyle(
                                                                            // Add any specific styles for the plan name here, if needed
                                                                            color: AppColors.blackColor,
                                                                            fontSize: 12,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              actions: [
                                                                RoundButton(title: "Cancel", onPressed: (){
                                                                  Navigator.pop(context);
                                                                })
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      title: Text('View Tasks'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        icon: Icon(Icons.more_vert),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


Future<List<String>> _getUserUuidsFromNames(List<String> userNames) async {

  String _userEndpoint = "http://43.205.97.189:8000/api/UserAuth/getOrgUsers";
  final http.Response response = await http.get(Uri.parse(_userEndpoint));
  if (response.statusCode == 200) {
    List<dynamic> users = jsonDecode(response.body);
    List<String> uuids = [];
    for (var userName in userNames) {
      for (var user in users) {
        if (user["name"] == userName) {
          uuids.add(user["id"]);
          break; // Found the user, no need to continue searching
        }
      }
    }
    return uuids;
  }
  // Return an empty list if user data is not available or API call fails
  return [];
}

Future<String> _getPriorityUuidFromName(String priorityName) async {
  String _priorityEndpoint = "http://43.205.97.189:8000/api/Platform/getPriorities";
  final http.Response response = await http.get(Uri.parse(_priorityEndpoint));
  if (response.statusCode == 200) {
    List<dynamic> priorities = jsonDecode(response.body);
    for (var priority in priorities) {
      if (priority["name"] == priorityName) {
        return priority["id"];
      }
    }
  }
  // Return an empty string if priority name is not found
  return "";
}

Future<String> _getStatusUuidFromName(String statusName) async {
  String _statusEndpoint = "http://43.205.97.189:8000/api/Platform/getStatus";

  final http.Response response = await http.get(Uri.parse(_statusEndpoint));
  if (response.statusCode == 200) {
    List<dynamic> statuses = jsonDecode(response.body);
    for (var status in statuses) {
      if (status["name"] == statusName) {
        return status["id"];
      }
    }
  }
  // Return an empty string if status name is not found
  return "";
}

String? formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }

  final dateTime = DateTime.parse(dateString);
  final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

  return formattedDate;
}