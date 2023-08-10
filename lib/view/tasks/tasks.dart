import 'package:Taskapp/Providers/taskProvider.dart';
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/view/tasks/myTasks.dart';
import 'package:Taskapp/view/tasks/MistaskCreation.dart';
import 'package:Taskapp/view/tasks/teamTask.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_colors.dart';
import 'allTasks.dart';


class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String selectedOption = 'AllTasks';

  void refreshScreen() {
    setState(() {}); // This triggers a rebuild of the widget
  }

  Widget getCategoryWidget() {
    switch (selectedOption) {
      case 'TeamTask':
        return TeamTaskScreen(refreshCallback: refreshScreen);
      case 'MyTask':
        return MyTaskScreen(refreshCallback: refreshScreen);
      case 'AllTask':
        return AllTaskScreen(refreshCallback: refreshScreen);
      default:
        return AllTaskScreen(refreshCallback: refreshScreen);
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
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
      final tasks = taskProvider.tasks; // Get the list of tasks from TaskProvider
      // Build your UI using the tasks list
      return Padding(
          padding: const EdgeInsets.only(top: 5.0),
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
                        title: "All Task",
                        onPressed: () {
                          setState(() {
                            selectedOption = 'AllTask';
                          });
                        },),
                    ),
                    SizedBox(width: 30),
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
        );},),
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
