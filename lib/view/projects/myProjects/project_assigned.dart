import 'dart:async';
import 'dart:convert';
import 'package:Taskapp/view/projects/projectDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common_widgets/round_button.dart';
import '../../../models/project_model.dart';
import '../../../models/project_team_model.dart';
import '../../../models/task_model.dart';
import '../../../models/user.dart';
import '../../../utils/app_colors.dart';
import 'package:intl/intl.dart';

class AssignedToMe extends StatefulWidget {
  @override
  _AssignedToMeState createState() => _AssignedToMeState();
}

class _AssignedToMeState extends State<AssignedToMe> {

  List<Project> projects = [];

  Future<void> fetchMyProjects() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final String? orgId = prefs.getString('selectedOrgId');

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }
      final url = 'http://43.205.97.189:8000/api/Project/myProjects?org_id=$orgId';


      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final List<Future<Project>> fetchedProjects = responseData.map((projectData) async {
          String projectId = projectData['project_id'] ?? '';

          // List<Task> tasks = await fetchProjectTasks(projectData['project_id']); // Fetch tasks for the project
          List<Team> teams = (projectData['teams'] as List<dynamic>).map((teamData) {
            return Team(
              id: teamData['teamId'] ?? '',
              teamName: teamData['teamName'] ?? '',
            );
          }).toList();

          List<User> users = (projectData['users'] as List<dynamic>).map((userData) {
            return User.fromJson(userData); // Create User object from JSON data
          }).toList();

          return Project(
            id: projectId,
            name: projectData['projectName'] ?? '',
            owner: projectData['created_by'] ?? '',
            dueDate: projectData['due_Date'] is bool ? null : projectData['due_Date'],
            // tasks: tasks,
            teams: teams,
            users: users, status: projectData['status'] ?? " ",
          );
        }).toList();

        final List<Project> projectsWithTasks = await Future.wait(fetchedProjects);

        setState(() {
          projects = projectsWithTasks;
        });

        // Store the projectId locally using SharedPreferences
        final List<String> projectIds = projectsWithTasks.map((project) => project.id).toList();
        await prefs.setStringList('projectIds', projectIds);
        print("ProjectID: $projectIds");

      } else {
        print('Error fetching projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching projects: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMyProjects();
    projects.sort((a, b) {
      return _getStatusOrder(a.status).compareTo(_getStatusOrder(b.status));
    });
  }

  int _getStatusOrder(String status) {
    // Define the order of statuses based on your requirements
    switch (status) {
      case 'ToDo':
        return 1;
      case 'InProgress':
        return 2;
      case 'Completed':
        return 3;
      case 'Transferred':
        return 4;
      default:
        return 5;
    }
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
                'Projects Assigned',
                style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),
              ),
              Text(
                'To Me',
                style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: projects.length,
                  itemBuilder: (BuildContext context, int index) {
                    Project project = projects[index];
                    Color statusColor = Colors.black;
                    if (project.status == 'Active') {
                      statusColor = Colors.orange;
                    } else if (project.status == 'In-Active') {
                      statusColor = Colors.green;
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
                                      project.name,
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
                                          project.owner,
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
                                          project.status,
                                          style: TextStyle(
                                              color: statusColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5,),
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center, // Align children at the center
                                      spacing: 5, // Add some spacing between the elements
                                      children: [
                                        Text(
                                          'Assigned To: ',
                                          style: TextStyle(
                                            color: AppColors.secondaryColor2,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          project.users!.map((user) => user.userName).join(', '),
                                          style: TextStyle(
                                            color: AppColors.blackColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                                          formatDate(project.dueDate) ?? '',
                                          style: TextStyle(
                                              color: AppColors.secondaryColor2,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10,),
                                    SizedBox(
                                        width: 100,
                                        height: 30,
                                        child: RoundButton(
                                          title: "View More",
                                          onPressed: () async {
                                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                                            final List<String>? projectIds = prefs.getStringList('projectIds');
                                            if (projectIds != null) {
                                              // Find the index of the selected project in the list of stored projectIds
                                              int projectIndex = projectIds.indexOf(project.id);
                                              if (projectIndex != -1) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ProjectDetailsScreen(
                                                      projectId: projectIds[projectIndex], // Use the selected projectId from the list
                                                      projectName: project.name,
                                                      assigneeTo: project.users!.map((user) => user.userName).join(', '),
                                                      dueDate: formatDate(project.dueDate) ?? '',
                                                      createdBy: project.owner,
                                                      assigneeTeam: project.teams!.map((user) => user.teamName).join(', '),
                                                      attachments: [],
                                                    ),
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                        )
                                    )
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
String? formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) {
    return null;
  }

  final dateTime = DateTime.parse(dateString);
  final formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);

  return formattedDate;
}
