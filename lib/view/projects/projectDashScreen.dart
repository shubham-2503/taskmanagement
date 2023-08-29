import 'dart:convert';

import 'package:Taskapp/Providers/project_provider.dart';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:Taskapp/view/projects/filter_projects_modals.dart';
import 'package:Taskapp/view/projects/myProjectFilterProvider.dart';
import 'package:Taskapp/view/projects/myProjects/createdbyMe.dart';
import 'package:Taskapp/view/projects/myTeamProjects/my_team_projects.dart';
import 'package:Taskapp/view/projects/projectCreation.dart';
import 'package:Taskapp/view/projects/myProjects/project_assigned.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/project_model.dart';
import '../../utils/app_colors.dart';
import 'package:http/http.dart' as http;

import '../../utils/filter_options_modal.dart';
import '../tasks/tasks.dart';

class ProjectDashScreen extends StatefulWidget {
  static String routeName = "/ProjectDashScreen";

  @override
  _ProjectDashScreenState createState() => _ProjectDashScreenState();
}

class _ProjectDashScreenState extends State<ProjectDashScreen> {
  String selectedOption = 'TeamProjects';
  bool _shouldRefresh = false;
  Map<String, String?> selectedFilters = {};

  void refreshScreen() {
    setState(() {});
  }

  Future<void> fetchAndRefreshProjects() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      String? orgId = prefs.getString("selectedOrgId");
      if (orgId == null) {
        orgId = prefs.getString('org_id') ?? "";
      }

      Uri createdByMeUri =
      Uri.parse('http://43.205.97.189:8000/api/Project/createdByMe?org_id=$orgId');
      Uri myProjectUri =
      Uri.parse('http://43.205.97.189:8000/api/Project/myProjects?org_id=$orgId');
      Uri teamsProjectUri =
      Uri.parse('http://43.205.97.189:8000/api/Project/myTeamProjects?org_id=$orgId');

      if (selectedFilters.containsKey('start_date')) {
        final startDate = selectedFilters['start_date'];
        print('startDate: $startDate'); // Add this line for debugging
        if (startDate != null) {
          createdByMeUri = createdByMeUri.replace(queryParameters: {
            ...createdByMeUri.queryParameters,
            'start_date': startDate,
          });
          myProjectUri = myProjectUri.replace(queryParameters: {
            ...myProjectUri.queryParameters,
            'start_date': startDate,
          });
          teamsProjectUri = teamsProjectUri.replace(queryParameters: {
            ...teamsProjectUri.queryParameters,
            'start_date': startDate,
          });
        }
      }

      if (selectedFilters.containsKey('end_date')) {
        final endDate = selectedFilters['end_date'];
        print('dueDate: $endDate'); // Add this line for debugging
        if (endDate != null) {
          createdByMeUri = createdByMeUri.replace(queryParameters: {
            ...createdByMeUri.queryParameters,
            'due_Date': endDate,
          });
          myProjectUri = myProjectUri.replace(queryParameters: {
            ...myProjectUri.queryParameters,
            'due_Date': endDate,
          });
          teamsProjectUri = teamsProjectUri.replace(queryParameters: {
            ...teamsProjectUri.queryParameters,
            'due_Date': endDate,
          });
        }
      }

      if (selectedFilters.containsKey('priority')) {
        createdByMeUri = createdByMeUri.replace(queryParameters: {
          ...createdByMeUri.queryParameters,
          'priority': selectedFilters['priority']!,
        });
        myProjectUri = myProjectUri.replace(queryParameters: {
          ...myProjectUri.queryParameters,
          'priority': selectedFilters['priority']!,
        });
        teamsProjectUri = teamsProjectUri.replace(queryParameters: {
          ...teamsProjectUri.queryParameters,
          'priority': selectedFilters['priority']!,
        });
      }

      if (selectedFilters.containsKey('status')) {
        createdByMeUri = createdByMeUri.replace(queryParameters: {
          ...createdByMeUri.queryParameters,
          'status': selectedFilters['status']!,
        });
        myProjectUri = myProjectUri.replace(queryParameters: {
          ...myProjectUri.queryParameters,
          'status': selectedFilters['status']!,
        });
        teamsProjectUri = teamsProjectUri.replace(queryParameters: {
          ...teamsProjectUri.queryParameters,
          'status': selectedFilters['status']!,
        });
      }

      final createdByMeResponse = await http.get(
        createdByMeUri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $storedData'},
      );

      final myTasksResponse = await http.get(
        myProjectUri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $storedData'},
      );

      final teamsTaskResponse = await http.get(
        teamsProjectUri,
        headers: {'accept': '*/*', 'Authorization': 'Bearer $storedData'},
      );

      print('API Error: ${createdByMeResponse.statusCode}, ${myTasksResponse.statusCode}, ${teamsTaskResponse.statusCode}');
      print("Api response: ${createdByMeResponse.body}. ${myTasksResponse.body},${teamsTaskResponse.body}");

      if (createdByMeResponse.statusCode == 200 &&
          myTasksResponse.statusCode == 200 &&
          teamsTaskResponse.statusCode == 200) {
        final List<dynamic> createdByMeData =
        jsonDecode(createdByMeResponse.body);
        final List<dynamic> myTasksData = jsonDecode(myTasksResponse.body);
        final List<dynamic> teamsTaskData =
        jsonDecode(teamsTaskResponse.body);

        final List<Project> project = [
          ...createdByMeData.map((data) => Project.fromJson(data)),
          ...myTasksData.map((data) => Project.fromJson(data)),
          ...teamsTaskData.map((data) => Project.fromJson(data)),
        ];

        // Create a new map with the updated values
        Map<String, String?> updatedFilters = Map.from(selectedFilters);

        final projectProvider =
        Provider.of<ProjectDataProvider>(context, listen: false);
        projectProvider.setTasks(project);

        setState(() {
          selectedFilters = updatedFilters; // Update the selectedFilters map
        });
      } else {
        print(
            'API Error: ${createdByMeResponse.statusCode}, ${myTasksResponse.statusCode}, ${teamsTaskResponse.statusCode}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  Widget getCategoryWidget(List<Project> projects, Function() refreshCallback) {
    switch (selectedOption) {
      case 'TeamProjects':
        return MyTeamProjectScreen(
          projects: projects,
          refreshCallback: refreshCallback,
        );
      case 'MyProjects':
        return AssignedToMe(
          projects: projects,
          refreshCallback: refreshCallback, selectedFilters: selectedFilters,
        );
      case 'createdbyMe':
        return CreatedbyMe(
          projects: projects,
          refreshCallback: refreshCallback,
        );
      default:
        return MyTeamProjectScreen(
          projects: projects,
          refreshCallback: refreshCallback,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.push(context, MaterialPageRoute(builder: (context)=>DashboardScreen()));
        return true; // Allow the back action to proceed
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: AppColors.primaryColor2,
          ),
          elevation: 0,
        ),
        body: Consumer2<ProjectDataProvider,ProjectsFilterNotifier>(
          builder: (context, projectProvider,filterProvider, child) {
            final selectedFilters = filterProvider.selectedFilters;
            return Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 10),
                        SizedBox(
                          height: 40,
                          width: 100,
                          child: RoundButton(
                            title: "Team\nProjects",
                            onPressed: () {
                              setState(() {
                                selectedOption = 'TeamProjects';
                              });
                              refreshScreen();
                            },
                          ),
                        ),
                        SizedBox(width: 30),
                        SizedBox(
                          height: 40,
                          width: 100,
                          child: RoundButton(
                            title: "My Projects",
                            onPressed: () {
                              setState(() {
                                selectedOption = 'MyProjects';
                              });
                              refreshScreen();
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        SizedBox(
                          height: 40,
                          width: 110,
                          child: RoundButton(
                            title: "Created By\n Me",
                            onPressed: () {
                              setState(() {
                                selectedOption = 'createdbyMe';
                              });
                              refreshScreen();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: getCategoryWidget(projectProvider.projects, refreshScreen),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: SingleChildScrollView(
                  //     scrollDirection: Axis.horizontal,
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //       children: [
                  //         Row(
                  //           children: [
                  //             IconButton(
                  //               onPressed: () async {
                  //                 Map<String, String?> selectedOption = await showModalBottomSheet(
                  //                   context: context,
                  //                   builder: (BuildContext context) {
                  //                     return ProjectsOptionsModal(
                  //                       onApplyFilters: (Map<String, String?> selectedFilters) {
                  //                         print("Selected Filters: $selectedFilters");
                  //                         filterProvider.updateFilters(selectedFilters); // Update filters using Provider
                  //                         // fetchAndRefreshTasks(); // Fetch and refresh tasks after applying filters\
                  //                         refreshScreen();
                  //                         setState(() {
                  //                           fetchAndRefreshProjects();
                  //                         });
                  //                       },
                  //                     );
                  //                   },
                  //                 );
                  //                 if (selectedOption != null) {
                  //                   print("SelectedOption: $selectedOption");
                  //                 }
                  //               },
                  //               icon: Icon(Icons.filter_alt_sharp, color: AppColors.secondaryColor2),
                  //             ),
                  //             Text(
                  //               "Filters",
                  //               style: TextStyle(
                  //                 fontWeight: FontWeight.bold,
                  //                 color: AppColors.secondaryColor2,
                  //               ),
                  //             ),
                  //             SizedBox(width: 10,),
                  //             if (selectedFilters.isNotEmpty) // Show only if filters are selected
                  //               SelectedFiltersDisplay(
                  //                 selectedFilters: selectedFilters,
                  //                 onRemoveFilter: (filterKey) {
                  //                   setState(() {
                  //                     selectedFilters.remove(filterKey); // Remove the filter
                  //                     Navigator.pushReplacement(context, PageRouteBuilder(
                  //                       pageBuilder: (_, __, ___) => ProjectDashScreen(), // Replace with your screen widget
                  //                       transitionsBuilder: (_, anim, __, child) {
                  //                         return FadeTransition(
                  //                           opacity: anim,
                  //                           child: child,
                  //                         );
                  //                       },
                  //                     ));
                  //                   });
                  //                   // Call your function to update tasks based on filters
                  //                   fetchAndRefreshProjects();
                  //                 },
                  //               ),
                  //           ],
                  //         )
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
