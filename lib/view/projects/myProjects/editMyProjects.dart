import 'dart:convert';
import 'package:Taskapp/View_model/api_services.dart';
import 'package:http/http.dart' as http;
import 'package:Taskapp/common_widgets/round_button.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/teams.dart';
import '../../../models/user.dart';
import '../../../utils/app_colors.dart';

class EditMyProjectPage extends StatefulWidget {
  final String initialTitle;
  final String initialAssignedTo;
  final String initialAssignedTeam;
  final String initialStatus;
  final String initialDueDate;

  EditMyProjectPage({
    required this.initialTitle,
    required this.initialAssignedTo,
    required this.initialAssignedTeam,
    required this.initialStatus,
    required this.initialDueDate,
  });

  @override
  _EditMyProjectPageState createState() => _EditMyProjectPageState();
}

class _EditMyProjectPageState extends State<EditMyProjectPage> {
  late TextEditingController titleController;
  late TextEditingController assignedToController;
  TextEditingController assignedTeamController = TextEditingController();
  late TextEditingController statusController;
  late TextEditingController dueDateController;
  late DateTime selectedDueDate;
  ApiRepo apiRepo = ApiRepo();
  List<User> users =[];
  List<Team> teams = [];


  Future<void> _updateProject() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('jwtToken');
      final projectId = prefs.getStringList('projectIds');// Replace with your locally stored ProjectId

      final url = 'http://43.205.97.189:8000/api/Project/updateProject/$projectId';

      final headers = {
        'accept': '*/*',
        'Authorization': 'Bearer $storedData',
        'Content-Type': 'application/json',
      };

      final body = jsonEncode({
        "name": titleController.text,
        "end_date": dueDateController.text,
        "team_id": assignedTeamController.text,
        "user_id": assignedToController.text,
      });

      final response = await http.patch(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        // Show a success dialog
        _showUpdatedDialog();
      } else {
        print('Error updating project: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating project: $e');
    }
  }


  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    assignedToController = TextEditingController(text: widget.initialAssignedTo);
    assignedTeamController = TextEditingController(text: widget.initialAssignedTeam); // Add this line
    statusController = TextEditingController(text: widget.initialStatus);

    try {
      selectedDueDate = DateTime.parse(widget.initialDueDate);
    } catch (e) {
      // Handle invalid date format gracefully, defaulting to today's date
      selectedDueDate = DateTime.now();
    }
    dueDateController = TextEditingController(text: widget.initialDueDate);
  }

  Future<List<User>> fetchUsers() async {
    try {
      // Call the fetchUsers function from api_service.dart
      final users = await apiRepo.fetchUsers();
      return users ?? []; // If users is null, return an empty list
    } catch (e) {
      print('Error while fetching users: $e');
      return []; // Return an empty list in case of an error
    }
  }

  void _showMembersDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Assignee Members'),
              content: FutureBuilder<List<User>>(
                future: fetchUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    users = snapshot.data!; // Assign the fetched users to the instance variable
                    return SingleChildScrollView(
                      child: Column(
                        children: users.map((user) {
                          bool isSelected = users.contains(user);

                          return CheckboxListTile(
                            title: Text(user.userName),
                            value: users.contains(user), // Check if the user is already in the users list
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  users.add(user); // Add the user to the list if the checkbox is checked
                                } else {
                                  users.remove(user); // Remove the user from the list if the checkbox is unchecked
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return Text('No members found.');
                  }
                },
              ),
              actions: [
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    setState(() {
                      // Close the dialog
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Team>> fetchTeams() async {
    try {
      // Call the fetchTeams function from api_service.dart
      final teams = await apiRepo.fetchTeams();
      return teams ?? []; // If teams is null, return an empty list
    } catch (e) {
      print('Error while fetching teams: $e');
      return []; // Return an empty list in case of an error
    }
  }

  void _showTeamsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Assignee Teams'),
              content: FutureBuilder<List<Team>>(
                future: fetchTeams(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    teams = snapshot.data!; // Assign the fetched teams to the instance variable
                    return SingleChildScrollView(
                      child: Column(
                        children: teams.map((team) {
                          bool isSelected = teams.contains(team);

                          return CheckboxListTile(
                            title: Text(team.name),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  if (!teams.contains(team)) {
                                    teams.add(team);
                                  }
                                } else {
                                  if (teams.contains(team)) {
                                    teams.remove(team);
                                  }
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return Text('No teams found.');
                  }
                },
              ),
              actions: [
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    setState(() {
                      // Close the dialog
                      Navigator.of(context).pop();
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  void dispose() {
    titleController.dispose();
    assignedToController.dispose();
    assignedTeamController.dispose();
    statusController.dispose();
    dueDateController.dispose();
    super.dispose();
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

                // Pass the updated project data back to the AssignedToMe screen
                // Navigator.pop(
                //   context,
                //   Project(
                //     title: titleController.text,
                //     assignedTo: assignedToController.text,
                //     assignedTeam: assignedTeamController.text,
                //     status: statusController.text,
                //     dueDate: dueDateController.text,
                //   ),
                // );
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
                decoration: InputDecoration(
                  labelText: 'Assigned To',
                  labelStyle: TextStyle(fontSize: 12, color: AppColors.grayColor),
                ),
                onTap: _showMembersDialog,
              ),
              TextField(
                controller: assignedTeamController,
                decoration: InputDecoration(
                  labelText: 'Assigned Team',
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
                child: RoundButton(title: "Save Changes", onPressed: _updateProject),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
