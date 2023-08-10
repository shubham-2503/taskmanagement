import 'package:Taskapp/Providers/project_provider.dart';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/projects/myTeamProjects/my_team_projects.dart';
import 'package:Taskapp/view/projects/projectCreation.dart';
import 'package:Taskapp/view/projects/myProjects/project_assigned.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project_model.dart';
import '../../utils/app_colors.dart';

class ProjectDashScreen extends StatefulWidget {
  @override
  _ProjectDashScreenState createState() => _ProjectDashScreenState();
}

class _ProjectDashScreenState extends State<ProjectDashScreen> {
  String selectedOption = 'myTeamProjects';

  void refreshScreen() {
    setState(() {});
  }

  Widget getCategoryWidget(List<Project> projects, Function() refreshCallback) {
    switch (selectedOption) {
      case 'myTeamProjects':
        return MyTeamProjectScreen(
          projects: projects,
          refreshCallback: refreshCallback,
        );
      case 'assignedProjects':
        return AssignedToMe(
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
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: AppColors.primaryColor2,
        ),
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
                          title: "My Team\nProjects",
                          onPressed: () {
                            setState(() {
                              selectedOption = 'myTeamProjects';
                            });
                            refreshScreen(); // Refresh the screen after changing the option
                          },
                        ),
                      ),
                      SizedBox(width: 30),
                      SizedBox(
                        height: 40,
                        width: 100,
                        child: RoundButton(
                          title: "Assigned \nProjects",
                          onPressed: () {
                            setState(() {
                              selectedOption = 'assignedProjects';
                            });
                            refreshScreen(); // Refresh the screen after changing the option
                          },
                        ),
                      ),
                      SizedBox(width: 10,),
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
      floatingActionButton: FloatingActionButton(
        tooltip: "Add New Project",
        backgroundColor: AppColors.secondaryColor2,
        onPressed: () async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProjectCreationScreen(),
            ),
          ).then((result) {
            // The result will contain data sent back from the Create Project screen
            if (result != null && result is Project) {
              // Update the project list with the newly created project using projectProvider
              Provider.of<ProjectDataProvider>(context, listen: false).addProject(result);
            }
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
