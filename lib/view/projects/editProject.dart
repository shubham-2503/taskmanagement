import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class EditProjectPage extends StatefulWidget {
  final String initialTitle;
  final String initialAssignedTo;
  final String initialStatus;
  final String initialDueDate;

  EditProjectPage({
    required this.initialTitle,
    required this.initialAssignedTo,
    required this.initialStatus,
    required this.initialDueDate,
  });

  @override
  _EditProjectPageState createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
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
    dueDateController = TextEditingController(text: widget.initialDueDate);
    selectedDueDate = DateTime.parse(widget.initialDueDate);
  }

  @override
  void dispose() {
    titleController.dispose();
    assignedToController.dispose();
    statusController.dispose();
    dueDateController.dispose();
    super.dispose();
  }

  void saveChanges() {
    // Implement the logic to save the edited task
    // You can access the edited values using the TextEditingController values
    final editedTitle = titleController.text;
    final editedAssignedTo = assignedToController.text;
    final editedStatus = statusController.text;
    final editedDueDate = selectedDueDate.toString();

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
              decoration: InputDecoration(
                labelText: 'Assigned To',
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
    );
  }
}
