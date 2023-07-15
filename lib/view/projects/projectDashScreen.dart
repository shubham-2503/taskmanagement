import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/projects/my_team_projects.dart';
import 'package:Taskapp/view/projects/projectCreation.dart';
import 'package:Taskapp/view/projects/project_assigned.dart';
import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';
import 'createdProject.dart';
class Project {
  final String name;
  final String category;
  final String details;

  Project(this.name, this.category, this.details);
}

class ProjectDashScreen extends StatefulWidget {
  @override
  _ProjectDashScreenState createState() => _ProjectDashScreenState();
}

class _ProjectDashScreenState extends State<ProjectDashScreen> {
  String selectedOption = 'createdProjects';

  Widget getCategoryWidget() {
    switch (selectedOption) {
      case 'createdProjects':
        return CreatedProjectScreen();
      case 'myTeamProjects':
        return MyTeamProjectScreen();
      case 'assignedProjects':
        return AssignedToMe();
      default:
        return CreatedProjectScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 90.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(onPressed: (){
                    Navigator.pop(context);
                  }, icon: Icon(Icons.arrow_back_ios,color: AppColors.secondaryColor2,)),
                  SizedBox(
                    height: 50,
                    width: 100,
                    child: RoundButton(
                        title: "Created\nProjects",
                      onPressed: () {
                        setState(() {
                          selectedOption = 'createdProjects';
                        });
                      },),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    width: 100,
                    child: RoundButton(
                      title: "My Team\nProjects",
                      onPressed: () {
                        setState(() {
                          selectedOption = 'myTeamProjects';
                        });
                      },),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    width: 100,
                    child: RoundButton(
                      title: "Assigned \nProjects",
                      onPressed: () {
                        setState(() {
                          selectedOption = 'assignedProjects';
                        });
                      },),
                  ),
                  SizedBox(width: 10,),
                ],
              ),
            ),
            Expanded(
              child: getCategoryWidget(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add New Project",
        backgroundColor:AppColors.secondaryColor2,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context)=>ProjectCreationScreen(),));
        },
        child:Icon(Icons.add,)),
      );
  }
}
