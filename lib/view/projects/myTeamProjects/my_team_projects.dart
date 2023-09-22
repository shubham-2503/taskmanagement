import 'dart:async';
import 'dart:convert';
import 'package:Taskapp/Providers/project_provider.dart';
import 'package:Taskapp/view/projects/myProjects/editMyProjects.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../../common_widgets/round_textfield.dart';
import '../../../models/project_model.dart';
import '../../../models/project_team_model.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Project> projects = [];
  late List<Project> filteredprojects = [];
  int projectCount = 0;

  @override
  void initState() {
    super.initState();
    print("InitState is called");
    fetchTeamProjects();
  }

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
            uniqueId: projectData['unique_id'] ?? '',
            name: projectData['projectName'] ?? '',
            owner: projectData['created_by'] ?? '',
            status: projectData['status'] ?? " ",
            dueDate: projectData['due_Date'] is bool ? null : projectData['due_Date'],
            teams: teams,
            users: users,
            active: projectData['active'] ?? false,
          );
        }).toList();

        // Use Provider to update projects list
        final projectProvider = Provider.of<ProjectDataProvider>(context, listen: false);
        projectProvider.updateProjects(fetchedProjects);

        // Store the projectId locally using SharedPreferences
        final List<String> projectIds = fetchedProjects.map((project) => project.id).toList();
        await prefs.setStringList('projectIds', projectIds);
        print("ProjectID: $projectIds");
        // Manually reorder the projects list to move inactive projects to the bottom

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
          return projectName.contains(lowercaseQuery) || status.contains(lowercaseQuery) ||  projectId.contains(lowercaseQuery);
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
                      fetchTeamProjects();
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
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProjectCreationScreen(Count: projectCount)),
                );

                if (result == true) {
                  // Refresh the data by calling your fetchTeamProjects method
                  fetchTeamProjects(); // Or any other method to refresh data
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
                                    await fetchTeamProjects();
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
                IconButton( onPressed: () async {
                  bool edited = await Navigator.push(context,MaterialPageRoute(builder: (context)=>EditMyProject(project: widget.project)));

                  if (edited == true) {
                    // Fetch tasks using your API call here
                    await fetchTeamProjects();
                  }
                }, icon: Icon(Icons.edit,color: AppColors.secondaryColor2,))
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
