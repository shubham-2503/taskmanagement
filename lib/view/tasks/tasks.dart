import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/projects/myTeamProjects/my_team_projects.dart';
import 'package:Taskapp/view/projects/projectCreation.dart';
import 'package:Taskapp/view/projects/myProjects/project_assigned.dart';
import 'package:Taskapp/view/tasks/myTasks.dart';
import 'package:Taskapp/view/tasks/taskCreation.dart';
import 'package:Taskapp/view/tasks/teamTask.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class Project {
  final String name;
  final String category;
  final String details;

  Project(this.name, this.category, this.details);
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String selectedOption = 'TeamTasks';

  Widget getCategoryWidget() {
    switch (selectedOption) {
      case 'TeamTask':
        return TeamTaskScreen();
      case 'MyTask':
        return MyTaskScreen();
      default:
        return TeamTaskScreen();
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
                      title: "My Team\nTask",
                      onPressed: () {
                        setState(() {
                          selectedOption = 'TeamTask';
                        });
                      },),
                  ),
                  SizedBox(width: 30),
                  SizedBox(
                    height: 50,
                    width: 100,
                    child: RoundButton(
                      title: "My Task",
                      onPressed: () {
                        setState(() {
                          selectedOption = 'MyTask';
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
          tooltip: "Add New Task",
          backgroundColor:AppColors.secondaryColor2,
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>MisTaskCreationScreen(),));
          },
          child:Icon(Icons.add,)),
    );
  }
}
