import 'dart:async';
import 'dart:convert';
import 'package:Taskapp/view/projects/projectCreation.dart';
import 'package:Taskapp/view/projects/projectDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Providers/project_provider.dart';
import '../../../common_widgets/round_button.dart';
import '../../../common_widgets/round_textfield.dart';
import '../../../models/project_model.dart';
import '../../../models/project_team_model.dart';
import '../../../models/task_model.dart';
import '../../../models/user.dart';
import '../../../utils/app_colors.dart';
import 'package:intl/intl.dart';

import 'editMyProjects.dart';

class AssignedToMe extends StatefulWidget {
  final VoidCallback refreshCallback;
  final List<Project> projects;

  const AssignedToMe({super.key, required this.refreshCallback, required this.projects,});
  @override
  _AssignedToMeState createState() => _AssignedToMeState();
}

class _AssignedToMeState extends State<AssignedToMe> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Project> projects = [];
  late List<Project> filteredprojects = [];
  late Future<void> fetchDataFuture;
  int projectCount = 0;

  Future<void> fetchMyProjects() async {
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
      };

      final url = Uri.http('43.205.97.189:8000', '/api/Project/myProjects', queryParameters);

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        projectCount = responseData.length;
        print("Count: ${projectCount}");
        final List<Project> fetchedProjects = responseData.map((projectData) {
          projectCount = responseData.length;
          print("Count: ${projectCount}");
          String status = projectData['status'] == true ? 'Active' : 'In-Active';
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
            description: projectData['description'] ?? '',
            id: projectId,
            uniqueId: projectData['unique_id'] ?? '',
            name: projectData['projectName'] ?? '',
            owner: projectData['created_by'] ?? '',
            dueDate: projectData['due_Date'] is bool ? null : projectData['due_Date'],
            // tasks: tasks,
            teams: teams,
            users: users, status: projectData['status'] ?? " ",
            active: projectData['active'] ?? " ",
          );
        }).toList();

        // Use Provider to update projects list
        final projectProvider = Provider.of<ProjectDataProvider>(context, listen: false);
        projectProvider.updateProjects(fetchedProjects);


        final activeProjects = fetchedProjects.where((project) => project.active == true).toList();

        // Apply a custom sorting function to move "Completed" projects to the bottom
        activeProjects.sort((a, b) {
          if (a.status == "Completed" && b.status != "Completed") {
            return 1; // Move "Completed" project to the bottom
          } else if (a.status != "Completed" && b.status == "Completed") {
            return -1; // Keep "Completed" project at the bottom
          } else {
            return 0; // Keep the order as is
          }
        });
        final inactiveProjects = fetchedProjects.where((project) => project.active == false).toList();
        setState(() {
          projects = [...activeProjects, ...fetchedProjects.where((project) => project.active == false).toList(), ...inactiveProjects];
          filteredprojects = List.from(projects);
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

  void filterProjects(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the query is empty, show all projects
        filteredprojects = List.from(projects);
      } else {
        // If the query is not empty, filter projects based on project name or status
        filteredprojects = projects.where((project) {
          final projectName = project.name.toLowerCase();
          final status = project.status.toLowerCase();
          final projectId=project.uniqueId!.toLowerCase();
          final lowercaseQuery = query.toLowerCase();
          return projectName.contains(lowercaseQuery) || status.contains(lowercaseQuery)|| projectId.contains(lowercaseQuery);
        }).toList();
      }
    });
  }

  void _deleteProject(String projectId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ProjectCountManager projectCountManager = ProjectCountManager(prefs);
      showDialog(
        context: context, // Use the original context for the first dialog
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
                  Navigator.of(context).pop(); // Close the first dialog
                  try {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    final storedData = prefs.getString('jwtToken');
                    String? orgId = prefs.getString("selectedOrgId");

                    if (orgId == null) {
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
                      // Use the scaffold's context for the second dialog
                      showDialog(
                        context: _scaffoldKey.currentContext ?? context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Thank You'),
                            content: Text("Project deleted successfully."),
                            actions: [
                              InkWell(
                                onTap: () async {
                                  Navigator.pop(context); // Close the second dialog
                                  setState(() {
                                    projects.removeWhere((project) => project.id == projectId);
                                    filteredprojects.removeWhere((project) => project.id == projectId);
                                  });
                                },
                                child: Text(
                                  "OK",
                                  style: TextStyle(
                                    color: AppColors.blackColor,
                                    fontSize: 20,
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                      );
                      fetchMyProjects();
                      print('Project deleted successfully.');
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
  void initState() {
    super.initState();
    fetchMyProjects();
    projects.sort((a, b) {
      return _getStatusOrder(a.status).compareTo(_getStatusOrder(b.status));
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Manually fetch data when user visits the screen
    fetchDataFuture = fetchMyProjects();
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
                      // Call a method to filter projects based on the query
                      filterProjects(query);
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
                  MaterialPageRoute(builder: (context) => ProjectCreationScreen(Count: projectCount)),
                );

                if (result == true) {
                  // Refresh the data by calling your fetchTeamProjects method
                  fetchMyProjects(); // Or any other method to refresh data
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
           child: Padding(
             padding: const EdgeInsets.only(top: 30),
             child: Column(
               children: [
                 Text(
                   'My Projects',
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
                       List<Color> gradientColors = project.active!
                           ? [
                         AppColors.primaryColor2.withOpacity(0.3),
                         AppColors.primaryColor1.withOpacity(0.3),
                       ]
                           : [
                         Colors.grey, // Set the background color to grey for inactive projects
                         Colors.grey, // Set the background color to grey for inactive projects
                       ];
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
                               gradient: LinearGradient(colors: gradientColors),
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
                                             'Project ID: ',
                                             style: TextStyle(
                                               color: AppColors.blackColor,
                                               fontSize: 14,
                                               fontWeight: FontWeight.bold,
                                             ),
                                           ),
                                           Container(
                                             width: 110,
                                             child: Text(
                                               project.uniqueId ?? "", // Use the null-aware operator to handle null values
                                               overflow: TextOverflow.ellipsis,
                                               style: TextStyle(
                                                 color: AppColors.secondaryColor2,
                                                 fontSize: 14,
                                                 fontWeight: FontWeight.bold,
                                               ),
                                             ),
                                           ),
                                         ],
                                       ),
                                       Row(
                                         children: [
                                           Text(
                                             'Project Name: ',
                                             style: TextStyle(
                                                 color: AppColors.blackColor,
                                                 fontSize: 14,
                                                 fontWeight: FontWeight.bold),
                                           ),
                                           Container(
                                             width:90,
                                             child: Text(
                                               project.name.length >10
                                                   ? project.name.substring(0,10) + '...'
                                                   : project.name,
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
                                             project.status,
                                             style: TextStyle(
                                                 color: AppColors.secondaryColor2,
                                                 fontSize: 14,
                                                 fontWeight: FontWeight.w500),
                                           ),
                                         ],
                                       ),

                                     ],
                                   ),
                                 ),
                                 // SizedBox(width: 20,),
                                 Spacer(),
                                 IconButton(
                                   icon: Icon(Icons.remove_red_eye, color: AppColors.secondaryColor2,size: 20,),
                                   onPressed: () {
                                     _showViewProjectDialog(project);
                                   },
                                 ),
                                 SizedBox(width: 1,),// Add a Spacer to push the menu image to the end
                                 IconButton(
                                   icon: Icon(Icons.edit, color: AppColors.secondaryColor2, size: 20,),
                                   onPressed: () async {
                                     bool? edited = await showModalBottomSheet<bool>(
                                       context: context,
                                       builder: (BuildContext context) {
                                         return ProjectDetailsModal(project: project);
                                       },
                                     );

                                     if (edited == true) {
                                       await fetchMyProjects();
                                     }
                                   },
                                 ),
                                 SizedBox(width: 1,),
                                 IconButton(
                                   icon: Icon(Icons.delete, color: AppColors.secondaryColor2,size: 20,),
                                   onPressed: () {
                                     _deleteProject(project.id);
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

  Future<void> fetchMyProjects() async {
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
      };

      final url = Uri.http('43.205.97.189:8000', '/api/Project/myProjects', queryParameters);

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(url, headers: headers);

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
            description: projectData['description'] ?? '',
            id: projectId,
            name: projectData['projectName'] ?? '',
            owner: projectData['created_by'] ?? '',
            dueDate: projectData['due_Date'] is bool ? null : projectData['due_Date'],
            // tasks: tasks,
            teams: teams,
            users: users, status: projectData['status'] ?? " ",
            active: projectData['active'] ?? " ",
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
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Project Name",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: AppColors.secondaryColor2),
                ),
                IconButton(onPressed: () async {
                  bool edited = await Navigator.push(context,MaterialPageRoute(builder: (context)=>EditMyProject(project: widget.project)));

                  if (edited == true) {
                    // Fetch tasks using your API call here
                    await fetchMyProjects();
                  }
                }, icon: Icon(Icons.edit,color: AppColors.secondaryColor2,)),
              ],
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
