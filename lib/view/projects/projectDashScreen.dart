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

                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
