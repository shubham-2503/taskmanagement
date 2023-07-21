import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/projects/myTeamProjects/my_team_projects.dart';
import 'package:Taskapp/view/projects/projectCreation.dart';
import 'package:Taskapp/view/projects/myProjects/project_assigned.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

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
  String selectedOption = 'myTeamProjects';

  Widget getCategoryWidget() {
    switch (selectedOption) {
      case 'myTeamProjects':
        return MyTeamProjectScreen();
      case 'assignedProjects':
        return AssignedToMe();
      default:
        return MyTeamProjectScreen();
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
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0),
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IconButton(onPressed: (){
                  //   Navigator.pop(context);
                  // }, icon: Icon(Icons.arrow_back_ios,color: AppColors.secondaryColor2,)),
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
                  SizedBox(width: 30),
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
