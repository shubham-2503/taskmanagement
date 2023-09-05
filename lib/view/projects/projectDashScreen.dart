import 'dart:convert';

import 'package:Taskapp/Providers/project_provider.dart';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:Taskapp/view/projects/myProjectFilterProvider.dart';
import 'package:Taskapp/view/projects/myProjects/createdbyMe.dart';
import 'package:Taskapp/view/projects/myTeamProjects/my_team_projects.dart';
import 'package:Taskapp/view/projects/projectCreation.dart';
import 'package:Taskapp/view/projects/myProjects/project_assigned.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common_widgets/round_textfield.dart';
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

class _ProjectDashScreenState extends State<ProjectDashScreen> with SingleTickerProviderStateMixin{
  String selectedOption = 'TeamProjects';
  bool _shouldRefresh = false;
  Map<String, String?> selectedFilters = {};
  late TabController _tabController;

  void refreshScreen() {
    setState(() {});
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
          refreshCallback: refreshCallback,
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
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        switch (_tabController.index) {
          case 0:
            selectedOption = 'TeamProjects';
            break;
          case 1:
            selectedOption = 'MyProjects';
            break;
          case 2:
            selectedOption = 'CreatedByMe';
            break;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>DashboardScreen()));
        return true; // Allow the back action to proceed
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: AppColors.primaryColor2,
          ),
          elevation: 0,
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(height: 50,width: 150,child:  RoundTextField(
                onChanged: (query) {}, hintText: 'Search',
                icon: "assets/images/search_icon.png",
              ),),
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(
                  'Team Projects',
                  style: TextStyle(
                    color: AppColors.secondaryColor2, // Change the text color as needed
                    fontSize: 13, // Change the font size as needed
                    fontWeight: FontWeight.bold, // Change the font weight as needed
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'My Projects',
                  style: TextStyle(
                    color: AppColors.secondaryColor2, // Change the text color as needed
                    fontSize: 13, // Change the font size as needed
                    fontWeight: FontWeight.bold, // Change the font weight as needed
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Created By Me',
                  style: TextStyle(
                    color: AppColors.secondaryColor2, // Change the text color as needed
                    fontSize: 13, // Change the font size as needed
                    fontWeight: FontWeight.bold, // Change the font weight as needed
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Consumer2<ProjectDataProvider,ProjectsFilterNotifier>(
          builder: (context, projectProvider,filterProvider, child) {
            final selectedFilters = filterProvider.selectedFilters;
            return Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Column(
                children: [
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       SizedBox(width: 10),
                  //       SizedBox(
                  //         height: 40,
                  //         width: 100,
                  //         child: RoundButton(
                  //           title: "Team\nProjects",
                  //           onPressed: () {
                  //             setState(() {
                  //               selectedOption = 'TeamProjects';
                  //             });
                  //             refreshScreen();
                  //           },
                  //         ),
                  //       ),
                  //       SizedBox(width: 30),
                  //       SizedBox(
                  //         height: 40,
                  //         width: 100,
                  //         child: RoundButton(
                  //           title: "My Projects",
                  //           onPressed: () {
                  //             setState(() {
                  //               selectedOption = 'MyProjects';
                  //             });
                  //             refreshScreen();
                  //           },
                  //         ),
                  //       ),
                  //       SizedBox(width: 10),
                  //       SizedBox(
                  //         height: 40,
                  //         width: 110,
                  //         child: RoundButton(
                  //           title: "Created By\n Me",
                  //           onPressed: () {
                  //             setState(() {
                  //               selectedOption = 'createdbyMe';
                  //             });
                  //             refreshScreen();
                  //           },
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Expanded(
                  //   child: getCategoryWidget(projectProvider.projects, refreshScreen),
                  // ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        MyTeamProjectScreen(refreshCallback: refreshScreen, projects: [], ),
                        AssignedToMe(refreshCallback: refreshScreen, projects: [],),
                        CreatedbyMe(refreshCallback: refreshScreen, projects: [],),
                      ],
                    ),
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
