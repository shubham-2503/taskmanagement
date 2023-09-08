import 'dart:async';
import 'dart:convert';
import 'package:Taskapp/Providers/project_provider.dart';
import 'package:Taskapp/view/projects/myProjects/editMyProjects.dart';
import 'package:Taskapp/view/projects/projectDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../common_widgets/round_button.dart';
import '../../../common_widgets/round_textfield.dart';
import '../../../models/project_model.dart';
import '../../../models/project_team_model.dart';
import '../../../models/task_model.dart';
import '../../../models/user.dart';
import '../../../utils/app_colors.dart';
import 'package:intl/intl.dart';

import '../projectCreation.dart';

class MyTeamProjectScreen extends StatefulWidget {
  final VoidCallback refreshCallback;
  final List<Project> projects;

  const MyTeamProjectScreen({super.key, required this.refreshCallback, required this.projects});
  @override
  _MyTeamProjectScreenState createState() => _MyTeamProjectScreenState();
}

class _MyTeamProjectScreenState extends State<MyTeamProjectScreen> {
  List<Project> projects = [];
  late List<Project> filteredprojects = [];
  int projectCount = 0;

  Future<void> fetchTeamProjects() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId");

      if (orgId == null) {
        orgId = prefs.getString('org_id') ?? "";
      }

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }
      final url = 'http://43.205.97.189:8000/api/Project/myTeamProjects?org_id=$orgId';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final List<Project> fetchedProjects = responseData.map((projectData) {
          projectCount = responseData.length;
          print("Count: ${projectCount}");
          String status = projectData['status'] == true ? 'Active' : 'In-Active';
          String projectId = projectData['project_id'] ?? '';

          List<Team> teams = (projectData['teams'] as List<dynamic>).map((teamData) {
            return Team(
              id: teamData['teamId'] ?? '',
              teamName: teamData['teamName'] ?? '',
            );
          }).toList();

          List<User> users = (projectData['users'] as List<dynamic>).map((userData) {
            return User.fromJson(userData);
          }).toList();

          return Project(
            description: projectData['description'] ?? '',
            id: projectId,
            name: projectData['projectName'] ?? '',
            owner: projectData['created_by'] ?? '',
            status: projectData['status'] ?? " ",
            dueDate: projectData['due_Date'] is bool ? null : projectData['due_Date'],
            teams: teams,
            users: users,
            active: projectData['active'] ?? " ",
          );
        }).toList();

        // Use Provider to update projects list
        final projectProvider = Provider.of<ProjectDataProvider>(context, listen: false);
        projectProvider.updateProjects(fetchedProjects);

        // Update filtered projects as well
        setState(() {
          filteredprojects = List.from(fetchedProjects);
        });

        // Store the projectId locally using SharedPreferences
        final List<String> projectIds = fetchedProjects.map((project) => project.id).toList();
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
    print("InitState is called");
    fetchTeamProjects();
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

  void filterProjects(String query) {
    setState(() {
      if (query.length >= 3) {
        print("Filtering with query: $query");
        filteredprojects = projects.where((project) =>
            project.name.toLowerCase().contains(query.toLowerCase())).toList();
      } else {
        // Reset the filteredprojects list when query length is less than 3
        filteredprojects = projects.toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColors.whiteColor
        ),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProjectCreationScreen(Count: projectCount,)),
              );

              if (result == true) {
                // Refresh the data by calling your fetchTeamProjects method
                fetchTeamProjects(); // Or any other method to refresh data
              }
            },
            icon: Icon(Icons.add_circle, color: AppColors.secondaryColor2),
          ),
          Text("Add Projects",style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryColor2
          ),),
        ],
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            children: [
              Text(
                'My Team Projects',
                style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontWeight: FontWeight.bold,
                    fontSize: 20),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredprojects.length,
                  itemBuilder: (BuildContext context, int index) {
                    Project project = filteredprojects[index];
                    Color statusColor = Colors.black;
                    if (project.status == 'Active') {
                      statusColor = Colors.orange;
                    } else if (project.status == 'In-Active') {
                      statusColor = Colors.green;
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
                                          'Project Name: ',
                                          style: TextStyle(
                                              color: AppColors.blackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          project.name,
                                          style: TextStyle(
                                              color: AppColors.secondaryColor2,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
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
                                          project.status,
                                          style: TextStyle(
                                              color: AppColors.secondaryColor2,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    // Row(
                                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     SizedBox(
                                    //         width: 100,
                                    //         height: 30,
                                    //         child: RoundButton(
                                    //           title: "View More",
                                    //           onPressed: () async {
                                    //             final SharedPreferences prefs =
                                    //                 await SharedPreferences
                                    //                     .getInstance();
                                    //             final List<String>? projectIds =
                                    //                 prefs.getStringList(
                                    //                     'projectIds');
                                    //             if (projectIds != null) {
                                    //               // Find the index of the selected project in the list of stored projectIds
                                    //               int projectIndex = projectIds
                                    //                   .indexOf(project.id);
                                    //               if (projectIndex != -1) {
                                    //                 bool edited = await Navigator.push(
                                    //                   context,
                                    //                   MaterialPageRoute(
                                    //                     builder: (context) =>
                                    //                         ProjectDetailsScreen(
                                    //                           active: project.active!,
                                    //                       projectId: projectIds[
                                    //                           projectIndex], // Use the selected projectId from the list
                                    //                       projectName: project.name,
                                    //                       assigneeTo: project.users
                                    //                               ?.map((user) =>
                                    //                                   user.userName)
                                    //                               .join(', ') ??
                                    //                           '',
                                    //                       status: project.status,
                                    //                       dueDate: formatDate(
                                    //                               project
                                    //                                   .dueDate) ??
                                    //                           '',
                                    //                       createdBy: project.owner,
                                    //                       assigneeTeam: project
                                    //                               .teams
                                    //                               ?.map((user) =>
                                    //                                   user.teamName)
                                    //                               .join(', ') ??
                                    //                           '',
                                    //                       attachments: [], project: project,
                                    //                     ),
                                    //                   ),
                                    //                 );
                                    //                 if(edited == true){
                                    //                   await fetchTeamProjects();
                                    //                 }
                                    //               }
                                    //             }
                                    //           },
                                    //         )),
                                    //     SizedBox(width: 20,),
                                    //     SizedBox(
                                    //       width: 100,
                                    //       height: 30,
                                    //       child: RoundButton(
                                    //           title: "Delete",
                                    //           onPressed: () async {
                                    //             _deleteProject("${project.id}");
                                    //           }),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.remove_red_eye, color: AppColors.secondaryColor2),
                                onPressed: () {
                                  _showViewProjectDialog(project);
                                },
                              ), // Add a Spacer to push the menu image to the end
                              GestureDetector(
                                onTap: () async {
                                  bool? shouldRefresh = await showModalBottomSheet<bool>(
                                    context: context,
                                    builder: (context) {
                                      return ProjectDetailsModal(project: project);
                                    },
                                  );

                                  if (shouldRefresh ?? false) {
                                    await fetchTeamProjects();
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


  void _showViewProjectDialog(Project project) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Center(
                      child: Text(
                        '${project.name}',
                        style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
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
                ...project.users!.map((user) => ListTile(
                  title: Text(
                    user.userName,
                    style: TextStyle(
                      color: AppColors.primaryColor2,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
                SizedBox(height: 16),
                // Display assigned teams if applicable
                if (project.teams != null && project.teams!.isNotEmpty)
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
                      ...project.teams!.map((team) => ListTile(
                        title: Text(
                          team.teamName,
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
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProjectDetailsModal extends StatefulWidget {
  final Project project;

  ProjectDetailsModal({required this.project});

  @override
  State<ProjectDetailsModal> createState() => _ProjectDetailsModalState();
}

class _ProjectDetailsModalState extends State<ProjectDetailsModal> {
  List<Project> projects = [];

  Future<void> fetchTeamProjects() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId");

      if (orgId == null) {
        orgId = prefs.getString('org_id') ?? "";
      }

      if (orgId == null) {
        throw Exception('orgId not found locally');
      }
      final url = 'http://43.205.97.189:8000/api/Project/myTeamProjects?org_id=$orgId';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        final List<Project> fetchedProjects = responseData.map((projectData) {
          String status = projectData['status'] == true ? 'Active' : 'In-Active';
          String projectId = projectData['project_id'] ?? '';

          List<Team> teams = (projectData['teams'] as List<dynamic>).map((teamData) {
            return Team(
              id: teamData['teamId'] ?? '',
              teamName: teamData['teamName'] ?? '',
            );
          }).toList();

          List<User> users = (projectData['users'] as List<dynamic>).map((userData) {
            return User.fromJson(userData);
          }).toList();

          return Project(
            description: projectData['description'] ?? '',
            id: projectId,
            name: projectData['projectName'] ?? '',
            owner: projectData['created_by'] ?? '',
            status: projectData['status'] ?? " ",
            dueDate: projectData['due_Date'] is bool ? null : projectData['due_Date'],
            teams: teams,
            users: users,
            active: projectData['active'] ?? " ",
          );
        }).toList();

        // Use Provider to update projects list
        final projectProvider = Provider.of<ProjectDataProvider>(context, listen: false);
        projectProvider.updateProjects(fetchedProjects);

        // Store the projectId locally using SharedPreferences
        final List<String> projectIds = fetchedProjects.map((project) => project.id).toList();
        await prefs.setStringList('projectIds', projectIds);
        print("ProjectID: $projectIds");
      } else {
        print('Error fetching projects: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching projects: $e');
    }
  }

  void _deleteProject(String projectId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ProjectCountManager projectCountManager = ProjectCountManager(prefs);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this Project?'),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close the confirmation dialog

                  try {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
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
                      Uri.parse('http://43.205.97.189:8000/api/Project/deleteProject/$projectId'),
                      headers: {
                        'accept': '*/*',
                        'Authorization': "Bearer $storedData",
                      },
                    );

                    print("Delete API response: ${response.body}");
                    print("Delete StatusCode: ${response.statusCode}");

                    if (response.statusCode == 200) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Thank You'),
                            content: Text("Project deleted successfully."),
                            actions: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context,true);
                                  Navigator.pop(context,true);
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
                      print('Project deleted successfully.');
                      setState(() {
                        Navigator.pop(context);
                        Navigator.pop(context, true); // Sending a result back to the previous screen
                      });
                    } else {
                      print('Failed to delete Project.');
                      // Handle other status codes, if needed
                    }
                  } catch (e) {
                    print('Error deleting project: $e');
                  }
                },
                child: Text('Delete'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error showing delete confirmation dialog: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Project Name",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.secondaryColor2),
            ),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${widget.project.name}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Due Date",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.secondaryColor2),
            ),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${formatDate(widget.project.dueDate)}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Status",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.secondaryColor2),
            ),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${widget.project.status}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              "Active",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.secondaryColor2),
            ),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "${widget.project.active}",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 30,width: 70,child: RoundButton(
                  onPressed: () async {
                    bool edited = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditMyProject(project: widget.project)),
                    ) ?? false; // Provide a default value of false if edited is null

                    if (edited == true) {
                      // Fetch tasks using your API call here
                      await fetchTeamProjects();
                    }
                  },
                  title: "Edit",
                ),),
                SizedBox(width: 50,),
                SizedBox(height: 30,width: 70,child: RoundButton(
                  onPressed: (){
                    _deleteProject("${widget.project.id}");
                  },
                  title: "Delete",
                ),),
              ],
            ),
          ],
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
