import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

class EditTaskPage extends StatefulWidget {
  final String initialTitle;
  final String initialProject;
  final String initialAssignedTo;
  final String initialStatus;
  final String initialDescription;
  final String initialPriority;

  EditTaskPage({
    required this.initialTitle,
    required this.initialProject,
    required this.initialAssignedTo,
    required this.initialStatus,
    required this.initialDescription, required this.initialPriority,
  });

  @override
  _EditTaskPageState createState() => _EditTaskPageState();
}

class _EditTaskPageState extends State<EditTaskPage> {
  late TextEditingController titleController;
  late TextEditingController projectController;
  late TextEditingController assignedToController;
  late TextEditingController statusController;
  late TextEditingController descriptionController;
  late TextEditingController priorityController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    projectController = TextEditingController(text: widget.initialProject);
    assignedToController = TextEditingController(text: widget.initialAssignedTo);
    statusController = TextEditingController(text: widget.initialStatus);
    descriptionController = TextEditingController(text: widget.initialDescription);
    priorityController = TextEditingController(text: widget.initialPriority);
  }

  @override
  void dispose() {
    titleController.dispose();
    projectController.dispose();
    assignedToController.dispose();
    statusController.dispose();
    descriptionController.dispose();
    priorityController.dispose();
    super.dispose();
  }

  void saveChanges() {
    // Implement the logic to save the edited task
    // You can access the edited values using the TextEditingController values
    final editedTitle = titleController.text;
    final editedProject = projectController.text;
    final editedAssignedTo = assignedToController.text;
    final editedStatus = statusController.text;
    final editedDescription = descriptionController.text;
    final editedPriority = priorityController.text;

    // Perform the necessary operations to save the changes
    // e.g., update the task in the database or send an API request

    // Optionally, you can navigate back to the task details page or show a success message
    _showUpdatedDialog();
  }

  void _showUpdatedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Changes Saved'),
          content: Text('Your changes has been updated successfully.'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Task'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor)
              ),
            ),
            TextField(
              controller: projectController,
              decoration: InputDecoration(
                labelText: 'Project',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor)
              ),
            ),
            TextField(
              controller: assignedToController,
              decoration: InputDecoration(
                labelText: 'Assigned To',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor)
              ),
            ),
            TextField(
              controller: statusController,
              decoration: InputDecoration(
                labelText: 'Status',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor)
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor)
              ),
            ),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: 'Priority',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor)
              ),
            ),
            SizedBox(height: 16.0),
            SizedBox(
                height: 30,
                width: 60,
                child: RoundButton(title: "Save Changes", onPressed: saveChanges)),
          ],
        ),
      ),
    );
  }
}
