import 'package:Taskapp/Providers/project_provider.dart';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/dashboard/dashboard_screen.dart';
import 'package:Taskapp/view/projects/myProjects/createdbyMe.dart';
import 'package:Taskapp/view/projects/myTeamProjects/my_team_projects.dart';
import 'package:Taskapp/view/projects/projectCreation.dart';
import 'package:Taskapp/view/projects/myProjects/project_assigned.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project_model.dart';
import '../../utils/app_colors.dart';

class ProjectDashScreen extends StatefulWidget {
  static String routeName = "/ProjectDashScreen";

  @override
  _ProjectDashScreenState createState() => _ProjectDashScreenState();
}

class _ProjectDashScreenState extends State<ProjectDashScreen> {
  String selectedOption = 'TeamProjects';
  bool _shouldRefresh = false;

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
        body: Consumer<ProjectDataProvider>(
          builder: (context, projectProvider, child) {
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
