import 'package:Taskapp/view/projects/editProject.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import 'createdProject.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final String projectName;
  final String assignee;
  final String? status;
  final List<Task>? tasks;
  String? dueDate;

  ProjectDetailsScreen({
    required this.projectName,
    required this.assignee,
    this.status,
    this.tasks,
    this.dueDate,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    final projectName = widget.projectName;
    final assignee = widget.assignee;
    final tasks = widget.tasks;
    final dueDate = widget.dueDate;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 60, left: 20, right: 20),
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
                      Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProjectPage(initialTitle: projectName, initialAssignedTo: assignee, initialStatus: _selectedStatus ?? " ", initialDueDate: dueDate ?? "" )));
                    }, icon: Icon(Icons.edit,color: AppColors.primaryColor1,)),
                    IconButton(onPressed: (){}, icon: Icon(Icons.delete,color: AppColors.secondaryColor2,)),
                  ],
                ),
              ],
            ),
            SizedBox(height: 30,),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Container(
                width: 130,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor2,
                ),
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration.collapsed(hintText: ''),
                  value: _selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  selectedItemBuilder: (BuildContext context) {
                    return [
                      Text(
                        'In-Active',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Active',
                        style: TextStyle(color: Colors.white),
                      ),
                    ];
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'In-Active',
                      child: Text(
                        'In-Active',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Active',
                      child: Text(
                        'Active',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
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
                  'Assignee',
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
              child: Text('Jane Smith', style: TextStyle(
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
              child: Text('2023-07-12 10:30 AM', style: TextStyle(
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
                if (tasks != null)
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: tasks.map((task) => Text(task.name,style: TextStyle(
                            color: AppColors.secondaryColor2,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),)).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

