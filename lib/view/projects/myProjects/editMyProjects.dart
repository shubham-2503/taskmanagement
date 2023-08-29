import 'dart:convert';

import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:Taskapp/common_widgets/round_textfield.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../models/project_model.dart';
import '../../../utils/app_colors.dart';

class EditMyProject extends StatefulWidget {
  final Project project;
  const EditMyProject({super.key, required this.project});

  @override
  State<EditMyProject> createState() => _EditMyProjectState();
}

class _EditMyProjectState extends State<EditMyProject> {
  late Project project; // Define the Project variable

  @override
  void initState() {
    super.initState();
    project = widget.project;
    fetchProjectDetails();
  }

  Future<void> fetchProjectDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          'http://43.205.97.189:8000/api/Task/taskDetails?taskId=${widget.project.id}',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          final projectJson = data.firstWhere(
                (project) => project['id'] == widget.project.id,
            orElse: () => null,
          );

          if (projectJson != null) {
            final projectDetail = Project.fromJson(projectJson);

            setState(() {
              project = projectDetail;
            });
          }
        }
      } else {
        print('API Error: Status Code ${response.statusCode}');
        // Handle error scenario
      }
    } catch (e) {
      print('Exception in fetchProjectDetails: $e');
      // Handle exception
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Project"),
      ),
      body: project != null
          ? Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("Title",
                  style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: RoundTextField(hintText: project.name),
              ),
              Visibility(
                visible: project.description.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text("Description",
                        style: TextStyle(
                          color: AppColors.secondaryColor2,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      child: RoundTextField(hintText:project.description),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("Due Date",
                  style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: RoundTextField(hintText: project.dueDate!),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("Status",
                  style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: RoundTextField(hintText: project.status),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: Text("Active",
                  style: TextStyle(
                    color: AppColors.secondaryColor2,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                child: RoundTextField(hintText: project.active.toString()),
              ),
              SizedBox(height: 30,),
              Center(
                child: SizedBox(
                  height: 40,
                  width: 120,
                  child: RoundButton(title: "Update Project", onPressed: (){}),
                ),
              ),
            ],
          ),
        ),
      )
          : Center(
        child: CircularProgressIndicator(), // Show loading indicator while fetching
      ),
    );
  }
}
