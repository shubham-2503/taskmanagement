import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/app_colors.dart';
import 'my_team_projects.dart';

class EditTeamProjectPage extends StatefulWidget {
  final String initialTitle;
  final String initialAssignedTo;
  final String initialStatus;
  final String initialDueDate;

  EditTeamProjectPage({
    required this.initialTitle,
    required this.initialAssignedTo,
    required this.initialStatus,
    required this.initialDueDate,
  });

  @override
  _EditTeamProjectPageState createState() => _EditTeamProjectPageState();
}

class _EditTeamProjectPageState extends State<EditTeamProjectPage> {
  late TextEditingController titleController;
  late TextEditingController assignedToController;
  late TextEditingController statusController;
  late TextEditingController dueDateController;
  late DateTime selectedDueDate;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    assignedToController = TextEditingController(text: widget.initialAssignedTo);
    statusController = TextEditingController(text: widget.initialStatus);

    try {
      selectedDueDate = DateTime.parse(widget.initialDueDate);
    } catch (e) {
      // Handle invalid date format gracefully, defaulting to today's date
      selectedDueDate = DateTime.now();
    }
    dueDateController = TextEditingController(text: widget.initialDueDate);
  }


  @override
  void dispose() {
    titleController.dispose();
    assignedToController.dispose();
    statusController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  void saveChanges() async {
    // Collect the edited values from the TextEditingController fields
    final editedTitle = titleController.text;
    final editedAssignedTo = assignedToController.text;
    final editedStatus = statusController.text;
    final editedDueDate = selectedDueDate.toUtc().toIso8601String();

    // Prepare the data to be sent in the request body
    final Map<String, dynamic> projectData = {
      "name": editedTitle,
      "start_date": editedDueDate,
      "end_date": editedDueDate, // You can modify this based on your requirement
    };

    // Convert the data to JSON
    final jsonData = jsonEncode(projectData);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('jwtToken');

    // Make the PATCH request to the server
    final url = 'http://43.205.97.189:8000/api/Project/updateProject';
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData', // Replace with your actual access token
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );

    print("StatusCode: ${response.statusCode}");
    print("Response: ${response.body}");
    if (response.statusCode == 200) {
      _showUpdatedDialog();
    } else {
      // Error, show a dialog with an error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to update the project. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }


  void _showUpdatedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Changes Saved'),
          content: Text('Your changes have been updated successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pop(context); // Go back to the previous screen
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDueDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDueDate,
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDueDate = pickedDate;
        dueDateController.text = selectedDueDate.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Project'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
                ),
              ),
              TextField(
                controller: assignedToController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Created by',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
                ),
              ),
              TextField(
                controller: statusController,
                decoration: InputDecoration(
                  labelText: 'Status',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
                ),
              ),
              GestureDetector(
                onTap: _selectDueDate,
                child: AbsorbPointer(
                  child: TextField(
                    controller: dueDateController,
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              SizedBox(
                height: 30,
                width: 60,
                child: RoundButton(title: "Save Changes", onPressed: saveChanges),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
