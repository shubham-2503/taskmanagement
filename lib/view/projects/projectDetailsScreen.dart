import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Taskapp/view/projects/myTeamProjects/editProject.dart';
import 'package:Taskapp/view/projects/taskcreation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/task_model.dart';
import '../../utils/app_colors.dart';
import 'myProjects/editMyProjects.dart';


class ProjectDetailsScreen extends StatefulWidget {
  final String? projectId;
  final String projectName;
  final String assigneeTo;
  final String assigneeTeam;
  final String? status;
  final String createdBy;
  String? dueDate;

  ProjectDetailsScreen({
    required this.projectName,
    required this.assigneeTo,
    required this.assigneeTeam,
    this.status,
    this.dueDate, required this.projectId,
    required this.createdBy,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  String? _selectedStatus;
  bool _isActive = true;
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.status ?? 'Active';
    _isActive = widget.status == 'Active' ?? true;

    // Call the API to fetch the tasks using the provided project ID
    fetchProjectTasks(widget.projectId!);
  }

  Future<void> fetchProjectTasks(String projectId) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');

      final url = 'http://43.205.97.189:8000/api/Task/myProjectTask?project_id=$projectId';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
      };

      final response = await http.get(Uri.parse(url), headers: headers);

      print("response: ${response.body}");
      print("Statuscode: ${response.statusCode}");

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          tasks = responseData.map((taskData) {
            String status = taskData['status'] == true ? 'Active' : 'In-Active';

            return Task(
              taskName: taskData['task_name'] ?? '',
              assignedTo: taskData['assigned_to'] ?? '', // Replace 'assigned_to' with the correct field from your API response
              status: status,
              priority: taskData['priority'] ?? '', // Replace 'priority' with the correct field from your API response
              dueDate: taskData['due_date'] ?? '', // Replace 'due_date' with the correct field from your API response
            );
          }).toList();
        });
      } else {
        print('Error fetching tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProjectId = widget.projectId;
    print("ProjectIds: $ProjectId");
    final projectName = widget.projectName;
    final assignee = widget.assigneeTo;
    final assigneeteam = widget.assigneeTeam;
    final dueDate = widget.dueDate;
    final status = widget.status;
    final owner = widget.createdBy;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 60, left: 20, right: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                          onTap: (){
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back_ios)),
                      Image.asset("assets/images/magic.png", width: 30,),
                      SizedBox(width: 5,),
                      Text(
                        projectName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: (){
                        print("Assigned Team: $assigneeteam");
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>EditMyProjectPage(initialTitle: projectName, initialAssignedTo: assignee,initialAssignedTeam:assigneeteam, initialStatus: _selectedStatus ?? " ", initialDueDate: dueDate ?? "" )));
                      }, icon: Icon(Icons.edit,color: AppColors.primaryColor1,)),
                      IconButton(onPressed: (){}, icon: Icon(Icons.delete,color: AppColors.secondaryColor2,)),
                      IconButton(onPressed: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>TaskCreationScreen(initialTitle: projectName,),));
                      }, icon: Icon(Icons.add_task,color: AppColors.secondaryColor1,)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 30,),
              Row(
                children: [
                  Icon(Icons.signal_wifi_statusbar_4_bar),
                  SizedBox(width: 4,),
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(_selectedStatus ?? 'Active', style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryColor2
                ),),
              ),
              SizedBox(height: 26.0),
              Row(
                children: [
                  Image.asset("assets/images/att.png", width: 30, height: 20,),
                  Text(
                    'Attachments',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 26.0),
              Row(
                children: [
                  Image.asset("assets/images/pers.png", width: 30, height: 20,),
                  Text(
                    'Assignee To',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(assignee, style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryColor2
                ),),
              ),
              SizedBox(height: 26.0),
              Row(
                children: [
                  Image.asset("assets/images/pers.png", width: 30, height: 20,),
                  Text(
                    'Assignee Team',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(assigneeteam, style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryColor2
                ),),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Image.asset("assets/images/complete_task.jpeg", width: 30, height: 20,),
                  SizedBox(width: 10,),
                  Text(
                    'Created By',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(owner, style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryColor2
                ),),
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Image.asset("assets/icons/date.png", width: 30, height: 20,),
                  SizedBox(width: 10,),
                  Text(
                    'Due Date',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: Text(dueDate!.isNotEmpty ? dueDate : 'No Due Date', style: TextStyle(
                    fontSize: 15,
                    color: AppColors.primaryColor2
                ),),
              ),
              SizedBox(height: 16.0),
              Column(
                children: [
                  Row(
                    children: [
                      Image.asset("assets/icons/activity_select_icon.png", width: 30, height: 20,),
                      SizedBox(width: 10,),
                      Text(
                        'Tasks',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                    Container(
                      padding: EdgeInsets.all(30.0),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            AppColors.primaryColor2.withOpacity(0.3),
                            AppColors.primaryColor1.withOpacity(0.3)
                          ]),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child:Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tasks"),
                            ListView.builder(
                              shrinkWrap: true,
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                Task task = tasks[index];
                                return Container(
                                  padding: EdgeInsets.all(8.0),
                                  margin: EdgeInsets.symmetric(vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.whiteColor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          task.taskName,
                                          style: TextStyle(
                                            color: AppColors.secondaryColor2,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        task.status,
                                        style: TextStyle(
                                          color: AppColors.blackColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        )
                      ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}